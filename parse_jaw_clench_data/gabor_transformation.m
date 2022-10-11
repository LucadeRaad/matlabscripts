function [slice] = gabor_transformation(matrix, n, overlap)
%GABOR_TRANSFORMATION Creates a sliding window of the matrix based on size
%n
%   Creates a square sliding window of the matrix, creates n sized matrixes

l = length(matrix);

offset = 1;

Fs = 300;            % Sampling frequency for my case frequency is 300 because 300 data points per second                    
T = 1/Fs;             % Sampling period       
L = 300;   % 1 second = 1 millisecond

for x = 1:l / (n - overlap)
    if x == 10
        return
    end

    slice = matrix(offset:offset + n, :);

    fourier = fft(slice);
    
    P2 = abs(fourier/L); 
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    P1(1:10) = [];

    figure (10 + x)
    f = Fs*(0:(L/2))/L;

    f(1:10) = [];
    
    plot(f,P1) 
    title("Single-Sided Amplitude Spectrum of X(t)")
    xlabel("f (Hz)")
    ylabel("|P1(f)|")


% 
%     fourier_min = min(fourier);
% 
%     fourier_max = max(fourier);
% 
%     for asdf = 1:1
%         fprintf('Figure %d column %d min is %.5f max is %.5f\n', x, asdf, fourier_min(asdf), fourier_max(asdf));
%     end
% 
%
%    shift = fftshift(fourier);
%
%     
% 
%     figure (100 + x)
% 
%     stackedplot(shift);

    figure(x)

    stackedplot(slice);
    
    offset = offset + (n - overlap) + 1;
end

