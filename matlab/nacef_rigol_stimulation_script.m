instrreset
dir = uigetdir;

amplitudes - (0.1:0.1:0.7,0.75:0.25:2);
frequencics - 5:5:30］：
pulse_widths -
[5:5:301/1000;
trials = 10;
pulses = 10;
for iiii=1:1:length(amplitudes)
  for iii=1:1:length(frequencies)
    for i=1:1:length(pulse widths)
      for i=1:1:trials
        rigol_stim laser (dir, frequencies (111), amplitudes (1111) , pulse_widths (11) , pulses, 1) :
@function experiment - rigol_stim laser (dir, freq, amp, pulse_width, pulses, trial)
  devices - visadevlist; Lists all visa available connections
  port = devices. ResourceName (1): Defines signal generator
  = visa ("ni',port):
  period - pulses/trea;
  s = sprintE(' :SOUR1: APPL: PULS NI, Nt, If, Af', freq, amp, amp/2, 0): Sets the signal generator to pulse with frequenc
  32 - sprintI (' :SOUR1: FUNC: PULS:WIDT If',pulse_width); Sets pulse width in g
  53 = sprintf (' :SOUR1: BURS:MODE: TRIG'): Sets to burst mode
  35 - sprintf (' :SOUR1: BURS: INT If', freq*10): \Defines burst period
  34 - sprintf (': SOUR1: BURS:NCYC F', pulses); Defines stimulation pulse number fopen (v): *Opens connection port
  ¿printi (v,s);
  [printf (v, 32) ; tprintf (v, 33) :
  fprintf (v, 34) :
  fprinti (v, 35) :
  pause (1): Gives a sec
  recordClampex('start'%starts clampex recording)
