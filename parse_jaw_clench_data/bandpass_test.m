clear;
clc;
close all;

filtered_unordered_eeg = parse_eeg('Data_Clench_RAW', '*_filtered.csv', false);
filtered_unordered_eeg = filtered_unordered_eeg(1);
filtered_unordered_eeg = cat(1, filtered_unordered_eeg{:});
filtered_unordered_eeg = filtered_unordered_eeg(:,1);

raw_unordered_eeg = parse_eeg('Data_Clench_RAW', '*_raw.csv', false);
raw_unordered_eeg = raw_unordered_eeg(1);
raw_unordered_eeg = cat(1, raw_unordered_eeg{:});
raw_unordered_eeg = raw_unordered_eeg(:,1);

% filtered_raw_eeg = bandpass(raw_unordered_eeg, [1, 50], 300);

figure(1);
t = stackedplot(raw_unordered_eeg);
t.Title = sprintf('Raw data through bandpass');
t.XLabel = 'Data Points (300 samples per second)';

t.DisplayLabels = ["Microvolts"];

figure(2);
t = stackedplot(filtered_unordered_eeg);
t.Title = sprintf('Already filtered data');
t.XLabel = 'Data Points (300 samples per second)';

t.DisplayLabels = ["Microvolts"];

% Sampling frequency for my case frequency is 300 because 300 data points per second
Fs = 300;

dt = 1/Fs;

fhat = fft(raw_unordered_eeg);

t = 0:dt:1;

n = length(raw_unordered_eeg);

dF = Fs/n;

lower_freq = 81;

upper_freq = 3995;

% Compute the power spectrum (power per frequency)
% FFT creates fhat. Fhat is a matrix of complex values that have a
% magnitude and a phase. The magnitude tells you the occurences of
% the frequency(sine and cosine). Phase tells you if the magnitude
% is more sine or cosine. This equation does the equivalent of
% magnitude of fhat squared.
PSD = fhat.*conj(fhat)/n;

freq = 1/(dt*n)*(0:n);

L = 1:floor(n/2);

% figure(3)
% plot(freq(L), PSD(L));
% xlabel('Frequency (Hz)')
% ylabel('Power Density')
% 
% BPF = ((lower_freq < abs(raw_unordered_eeg)) & (abs(raw_unordered_eeg) < upper_freq));
% 
% 
% f = (-Fs/2:dF:Fs/2-dF)';
% 
% figure(4)
% plot(f, BPF);
% xlabel('Data Points (300 samples per second)')
% xlabel("Microvolts")

