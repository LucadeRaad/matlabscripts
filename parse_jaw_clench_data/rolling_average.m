clear;
clc;
close all;

do_bandpass = true;

buffer_size = 1000;
channels = 7;

window_size = 100;
overlap = 0;

raw_unordered_eeg = parse_eeg('Data_RandomClench', '*_raw.csv', do_bandpass);
raw_unordered_eeg = raw_unordered_eeg(1);

graph_gabor(raw_unordered_eeg, window_size, overlap, false);

raw_unordered_eeg = cat(1, raw_unordered_eeg{:});

offset = 1;
rolling_avg = zeros(buffer_size, 1);
setup_time = 2;

for index = 0:length(raw_unordered_eeg) / (window_size - overlap)
    slice = raw_unordered_eeg(offset:offset + window_size, :);

    % slice = bandpass(slice, [1, 50], 300);

    buffer_index = mod(index, buffer_size) + 1;

%     for c = 1:channels
%         buffer(buffer_index, c) = mean(slice(:, c));
%     end

    new_avg = mean(slice, 'all');

    if (index > setup_time && new_avg)

    end

    rolling_avg(buffer_index) = new_avg;

    offset = offset + (window_size - overlap);

    if offset + window_size > length(raw_unordered_eeg)
        break
    end
end

disp(rolling_avg)