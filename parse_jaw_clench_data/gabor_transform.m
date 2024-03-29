function output = gabor_transform(matrix, window_size, overlap, displayFFT)
%GABOR_TRANSFORM Creates a sliding window of the matrix based on size
%n
%   Creates a square sliding window of the matrix, creates n sized matrixes

displayFFT = logical(displayFFT);

output = zeros(size(matrix));

offset = 1;

% The indexes for the slices that the FFT output is put into. Modifying
% this variable can change the size of the windows that are seen on figures
% 1000 + x.
slice_indexes = [1, 6, 11, 16, 21, 26, 31, 36, 41, 46, 51];

% Sampling frequency as there is 300 data points per second
Fs = 300;

dt = 1/Fs;

freq_incr = 1 / (dt * window_size);

% Creates the vector of frequencies that is the x axis. Goes from lowest
% frequency 0 to highest frequency which is the size of the window
freq = freq_incr * (0:window_size);

w = width(matrix);

Length = 1:floor(window_size/2);

% cutoff = cast(window_size * (3/4), "uint8");

for index = 1:length(matrix) / (window_size - overlap)
    slice = matrix(offset:offset + window_size, :);

    for jindex = 1:w
        sslice = slice(:, jindex);

        % Compute the power spectrum (power per frequency)
        % FFT creates fhat. Fhat is a matrix of complex values that have a
        % magnitude and a phase. The magnitude tells you the occurences of
        % the frequency(sine and cosine). Phase tells you if the magnitude
        % is more sine or cosine. This equation does the equivalent of
        % magnitude of fhat squared.
        fhat = fft(sslice);
        
        PSD = fhat.*conj(fhat)/window_size;

        graphPSD = PSD;

        if displayFFT
            % Figure 1 is the data, figure 100 + x is the data with 1 fast
            % fourier transform figure 1000 + x is the fast fourier transform
            % but turned into windows that are the mean of the data between
            % the fft windows.

            figure(index)
            t = stackedplot(slice);
            t.Title = sprintf('Figure %d unfiltered data', index);
            t.XLabel = 'Data Points (300 samples per second)';
            t.DisplayLabels = "Microvolts";

            % The reasoning behind the labeling of the Y axis is from this
            % post:
            % https://stackoverflow.com/questions/1523814/units-of-a-fourier-transform-fft-when-doing-spectral-analysis-of-a-signal

            figure (100 + index)
            plot(freq(Length), graphPSD(Length));
            title(sprintf('Figure %d Fast Fourier Transform', index))
            xlabel('Frequency (Hz)')
            ylabel('Power Density')

            % The slice format makes it easier to see the trends in the FFT 

            graphPSD = Slice_FFT(slice_indexes, freq_incr, graphPSD);

            figure (1000 + index)
            plot(freq(Length), graphPSD(Length));
            title(sprintf('Figure %d FFT sliced', index))
            xlabel('Frequency (Hz)')
            ylabel('Power Density')
        end
        
        %% Calculate jaw clench by finding the index of the max and min, if the min is before the max its a jaw clench

        % Turn PSD into equally sized slices that are the average of that
        % slice
        [~, slice_values] = Slice_FFT(slice_indexes, freq_incr, PSD);

        % First value is always noise!
        slice_values = slice_values(2:end);

        [~, slice_min_index] = min(slice_values);
        [~, slice_max_index] = max(slice_values);

        output(offset: offset + window_size, jindex) = slice_max_index > slice_min_index;
    end
    
    offset = offset + (window_size - overlap);

    if offset + window_size > length(matrix)
        break
    end
end

end

% Turns the FFT data into slices. The slice size is defined in the
% function. Each slice's value is the mean of the slice's range in the
% passed in FFT.
function [PSD, matrix] = Slice_FFT(slice_indexes, freq_incr, PSD)
prev_index = slice_indexes(1);

matrix = zeros(length(slice_indexes) - 1, 1);

for a = 2:length(slice_indexes)
    arb_index_s = round(prev_index / freq_incr);
    arb_index_e = round(slice_indexes(a) / freq_incr);
    
    slice_value = mean(PSD(arb_index_s : arb_index_e));

    matrix(a - 1) = slice_value;
    
    PSD(arb_index_s : arb_index_e) = slice_value;
    
    prev_index = slice_indexes(a);
end
end