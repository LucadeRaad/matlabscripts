clear;
clc;
close all;

%% NOTE:
% Due to matlab being a good programming language this script assumes the
% current folder (which is shown on the left of the ide) has both the data
% files and the program files.

% raw_unordered_eeg names_raw_eeg = parse_eeg('Data_RandomClench', '*_raw.csv', true);

do_bandpass = true;

%[unordered_eeg, names_unordered_eeg] = parse_eeg('Data_RandomClench', '*_raw.csv', do_bandpass);

[ordered_eeg, names_ordered_eeg] = parse_eeg('Data_Clench_RAW', '*_raw.csv', do_bandpass);

%% Gabor transform
% Create a sliding window, do fft(fast fourier transform) on every
% sliding window, record maybe the mode or slice the fft graph into pieces
% and then recording the pieces

window_size = 900;
window_overlap = 0;
display_internal_fft = true;

% You can add a '(1)' to the output from parse_eeg (filtered_unordered_eeg variable) if you only want to see 1
% session, ie:
% graph_gabor(unordered_eeg(1), window_size, window_overlap, display_internal_fft, names_unordered_eeg);
graph_gabor(ordered_eeg(1), window_size, window_overlap, display_internal_fft, names_ordered_eeg);





