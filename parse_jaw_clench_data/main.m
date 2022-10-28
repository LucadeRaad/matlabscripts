clear;
clc;
close all;

%% NOTE:
% Due to matlab being a good programming language this script assumes the
% current folder (which is shown on the left of the ide) has both the data
% files and the program files.

% raw_unordered_eeg = parse_eeg('Data_RandomClench', '*_raw.csv');

filtered_unordered_eeg = parse_eeg('Data_RandomClench', '*_filtered.csv');

raw_ordered_eeg = parse_eeg('Data_Clench_RAW', '*_filtered.csv');

%% Gabor transform
% Create a sliding window, do fft(fast fourier transformation) on every
% sliding window, record maybe the mode or slice the fft graph into pieces
% and then recording the pieces

graph_gabor(filtered_unordered_eeg(3), 900, 0, 1);

%graph_gabor(raw_ordered_eeg);
