clear;
clc;
close all;
%% NOTE:
% Due to matlab being a good programming language this script assumes the
% current folder (which is shown on the left of the ide) has both the data
% files and the program files.


%parse_eeg('Data_RandomClench');

raw_ordered_eeg = parse_eeg('Data_Clench_RAW');

%% Gabor transformation
% Create a sliding window, do fft(fast fourier transformation) on every
% sliding window, record maybe the mode or slice the fft graph into pieces
% and then recording the pieces 

for index = 1:length(raw_ordered_eeg)
    output = gabor_transformation(raw_ordered_eeg{index}, 500, 0);

    dp = find(output, 1);

    output(1:dp,:) = 0;

    % graph = [test{index}, output];

    graph = zeros(size([raw_ordered_eeg{index}, output]));

    for jindex = 1:width(raw_ordered_eeg{index})
        gindex = jindex - 1;
        gindex = gindex * 2;
        gindex = gindex + 1;

        graph(:,gindex) = raw_ordered_eeg{index}(:,jindex);

        graph(:,gindex + 1) = output(:,jindex);
    end
    
    figure(index);
    stackedplot(graph);

    % ["LE","LE fft","F4","F4 fft","C4","C4 fft","P4","P4 fft","P3","P3 fft","C3", "C3 fft","F3","F3 fft"]
end
