clear;
clc;
close all;
%% NOTE:
% Due to matlab being a good programming language this script assumes the
% current folder (which is shown on the left of the ide) has both the data
% files and the program files.


%parse_eeg('Data_RandomClench');

test = parse_eeg('Data_Clench_RAW');

%% Gabor transformation
% Create a sliding window, do fft(fast fourier transformation) on every
% sliding window, record maybe the mode or slice the fft graph into pieces
% and then recording the pieces 

% The x function is the sliding window for fft

gabor_transformation(test{1}, 300, 0);
