%ABF Data Analysis Script
folder = uigetdir(); %Files that need to be analyzed directory

files = dir(fullfile(folder, '*.abf')); %Extracts all abf files from here
data = struct; %Structure for all the data

for i =1:length(files)
    data(i).name = files(i).name;
    data(i).recordings = abfload(append(folder,'/',files(i).name)); 
    data(i).recordings(:,3) = [0:1e-5:(length(data(i).recordings)-1)/1e5];
    data(i).frequency = str2double(extractBetween(data(i).name,1,'hz'));
    data(i).pulse_width = str2double(extractBetween(data(i).name,'hz_','ms'))/1000;
    data(i).amplitude = str2double(extractBetween(data(i).name,'ms_','v'));
    figure
    plot(data(i).recordings([1e5:1.5e5],3),data(i).recordings([1e5:1.5e5],1))
    xlim([1 1.5])
    ylim([-0.2 0.2])
    title(append(num2str(data(i).frequency),' Hz ',num2str(data(i).pulse_width*1000),' ms ',num2str(data(i).amplitude),' V Raw Trace'))
end


