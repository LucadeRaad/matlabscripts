function output = gabor_transform(matrix, window_size, overlap, displayFFT)
%GABOR_TRANSFORM Creates a sliding window of the matrix based on size
%n
%   Creates a square sliding window of the matrix, creates n sized matrixes

displayFFT = logical(displayFFT);

output = zeros(size(matrix));

offset = 1;

% Sampling frequency for my case frequency is 300 because 300 data points per second
Fs = 300;

dt = 1/Fs;

slice_indexes = [1, 6, 11, 16, 21, 26, 31, 36, 41, 46, 51];

freq_incr = 1/(dt * window_size);

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
            % Figure 1 is the data, figure 10 + x is the data with 1 fast
            % fourier transform figure 100 + x is the fast fourier transform
            % but with the first values removed like a band pass filter

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


            % View the data in a format that shows 

            graphPSD = AlgorithmOutput(slice_indexes, freq_incr, graphPSD);

            figure (1000 + index)
            plot(freq(Length), graphPSD(Length));
            title(sprintf('Figure %d FFT sliced', index))
            xlabel('Frequency (Hz)')
            ylabel('Power Density')
        end

        %% Calculate mean/meadian/mode and then find a jaw clench

        % Turn PSD into equally sized slices that are the average of that
        % slice
        PSD = AlgorithmOutput(slice_indexes, freq_incr, PSD);

        % The first slice is always large due to how the eeg collects data
        % so we can use it as a "constant"
        first_index = round(slice_indexes(1) / freq_incr);
    
        % The end of the first section and now we take the rest into one
        % big chunk and see if they compare
        second_index = round(slice_indexes(3) / freq_incr);
        third_index = round(slice_indexes(end) / freq_incr);

        low_change = trapz(PSD(first_index : second_index));

        high_change = trapz(PSD(second_index + 1 : third_index));

        alg_output = (high_change / low_change) >= 1.5;

        output(offset: offset + window_size, jindex) = alg_output;
    end
    
    offset = offset + (window_size - overlap);

    if offset + window_size > length(matrix)
        break
    end
end

end

function PSD = AlgorithmOutput(slice_indexes, freq_incr, PSD)
prev_index = slice_indexes(1);

for a = 2:length(slice_indexes)
    arb_index_s = round(prev_index / freq_incr);
    arb_index_e = round(slice_indexes(a) / freq_incr);
    
    slice_value = mean(PSD(arb_index_s : arb_index_e));
    
    PSD(arb_index_s : arb_index_e) = slice_value;
    
    prev_index = slice_indexes(a);
end
end