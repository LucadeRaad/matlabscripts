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

% Creates the vector of frequencies that is the x axis. Goes from lowest
% frequency 0 to highest frequency which is the size of the window
freq = 1/(dt*window_size)*(0:window_size);

w = width(matrix);

Length = 1:floor(window_size/2);

cutoff = window_size * (3/4);

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


            % the first bit of the fourier transform has noise at the
            % beginning that we can discard when we want to use the data
            % to make desisions.
            graphPSD(1:30, :) = 0;
    
            figure (1000 + index)
            plot(freq(Length), graphPSD(Length));
            title(sprintf('Figure %d Fast Fourier Transform (low band pass filtered)', index))
            xlabel('Frequency (Hz)')
            ylabel('Power Density')
        end

        PSD(1:cutoff,:) = 0;

        avg = trapz(PSD);
        output(offset + window_size,jindex) = avg;
    end
    
    offset = offset + (window_size - overlap);

    if offset + window_size > length(matrix)
        break
    end
end

end