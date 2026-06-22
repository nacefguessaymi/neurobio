import pyabf
import matplotlib.pyplot as plt
import numpy as np
import glob
import os
import re
from scipy.signal import butter, lfilter
import quickspikes as qs

def butter_bandpass(lowcut, highcut, fs, order=5):
    return butter(order, [lowcut, highcut], fs=fs, btype='band')

def butter_bandpass_filter(data, lowcut, highcut, fs, order=5):
    b, a = butter_bandpass(lowcut, highcut, fs, order=order)
    y = lfilter(b, a, data)
    return y


file_path = '/Users/Nacef/Desktop/Juxtacellular_Recording/20240723/'
results_path = file_path + 'Results/'
files = glob.glob(file_path + '*.abf')
file_names = [os.path.basename(file) for file in files]

# Extract frequencies, pulse widths, and voltages from file names
freqs = [float(name[:name.find('hz')]) for name in file_names if 'v.' in name]
pulse_widths = [float(name[name.find('hz_') + 3:name.find('ms')]) for name in file_names if 'v.' in name]
volts = [float(name[name.find('ms_') + 3:name.find('v')]) for name in file_names if 'v.' in name]

# Filter the file names based on the freq, pulse_width, and volt lists
filtered_file_names = [file_names[i] for i in range(len(file_names)) if 'v.abf' in file_names[i]]

# Optical power mapping (in mW)
optical_power_mapping = {
    0.25: 0.00304,
    0.5: 0.0052,
    0.6: 0.00785,
    0.65: 0.01016,
    0.7: 0.01429,
    0.75: 0.02,
    1: 2,
    1.25: 7.05,
    1.5: 12.21,
    1.75: 17.62,
    2: 23.2
}

# Sampling rate in Hz (100 kHz)
sampling_rate = 100000

# Initialization of spike number
spike_count = []
optical_powers = []
p2p = []
# Loop through each filtered file
for i in range(len(filtered_file_names)):
    file_full_path = file_path + file_names[i]
    abf = pyabf.ABF(file_full_path)
    
    
    freq = float(file_names[i][:file_names[i].find('hz')])
    pulse_width = float(file_names[i][file_names[i].find('hz')+3:file_names[i].find('ms')])
    volt = float(file_names[i][file_names[i].find('ms')+3:file_names[i].find('v')])

        
    # Assuming channel 0 is to be used
    abf.setSweep(0, 1)
    t = np.argmax(abf.sweepY > 1)  # Threshold crossing event
    pre_t = max(t - int(0.1 * sampling_rate), 0)  # 100 ms before t
    b = t + int((pulse_width * 10 / 1000) * sampling_rate + (9 / freq) * sampling_rate)
    if b > len(abf.sweepX):
        b = len(abf.sweepX) - 1
    abf.setSweep(0, 0)
    
    data = abf.sweepY[pre_t:b]*1000
    # Apply bandpass filter
    filtered_data = butter_bandpass_filter(data, 100, 8000, sampling_rate)  # Convert from mV to µV

    # Set x-axis values starting from 0
    time_window = abf.sweepX[pre_t:b] - abf.sweepX[pre_t]

    plt.figure(figsize=(12, 8))
    plt.subplot(2, 1, 1)
    plt.plot(time_window, data, color='grey', label="Raw Waveform")
    plt.plot(time_window, filtered_data, color='black', label="Filtered Waveform")
    
    # Add pulse rectangles
    pulse_interval = 1 / freq  # Time between pulses in seconds
    current_time = 0.1  # Since pulses start at t, set initial time to 0
    for j in range(10):  # Assuming there are exactly 10 pulses
        pulse_start = current_time
        pulse_end = pulse_start + (pulse_width / 1000)  # Convert pulse width from ms to seconds
        plt.gca().add_patch(plt.Rectangle((pulse_start, -150), pulse_end - pulse_start, 300, color='red', alpha=0.3, label='Stimulation' if j == 0 else ""))  # Add label only once
        current_time += pulse_interval

    plt.ylabel('Voltage ($\mu$V)')
    plt.xlabel('Time (s)')
    plt.title(f'Optical Power: {optical_power_mapping[volt]} mW, Frequency: {freq} Hz, Pulse Width: {pulse_width} ms')
    plt.legend()

    # Detect and plot spikes
    # Use QuickSpikes to detect spikes
    detector = qs.detector(40, 50)  # Customize the threshold and sign
    spikes = detector.send(filtered_data)  # Convert mV to µV for detection
    spike_window_ms = 2  # milliseconds around the spike to display
    spike_window_samples = int((spike_window_ms / 1000) * sampling_rate)  # Convert ms to number of samples

    plt.subplot(2, 1, 2)
    spike_data = []
    for spike in spikes:
        start_index = max(spike - spike_window_samples, 0)
        end_index = min(spike + spike_window_samples, len(filtered_data))
        spike_time_range = time_window[start_index:end_index] - time_window[start_index]
        spike_data.append(data[start_index:end_index]) 
        plt.plot(spike_time_range * 1000, filtered_data[start_index:end_index], color='black')  # Convert seconds to milliseconds
    plt.ylabel('Voltage ($\mu$V)')
    plt.xlabel('Time (ms)')
    plt.title('Spike Waveforms (Threshold 50 $\mu$V)')

    plt.tight_layout()

    
    
     # Map voltages to optical power and count spikes
    optical_powers.append(optical_power_mapping[volt])
    spike_count.append(len(spikes))
    peak2peaks =  []
    for spike in spike_data: 
        maximum = max(spike)
        minimum = min(spike)
        peak2peaks.append(abs(maximum)+abs(minimum))
    p2p.append(np.mean(peak2peaks))




plt.figure()
plt.bar(optical_powers, spike_count, color='blue')
plt.xlabel('Optical Power (mW)')
plt.ylabel('Number of Spikes')
plt.title('Number of Spikes as a Function of Optical Power')



plt.figure()
plt.bar(optical_powers, p2p)
plt.xlabel('Optical Power (mW)')
plt.ylabel('Peak to peak amplitude ($\mu$V)')
plt.title('Peak to Peak Amplitude as a Function of Optical Power')
plt.show()