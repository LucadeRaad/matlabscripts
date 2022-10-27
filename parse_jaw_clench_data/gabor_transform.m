function output = gabor_transform(matrix, n, overlap, shouldBandPass)
%GABOR_TRANSFORM Creates a sliding window of the matrix based on size
%n
%   Creates a square sliding window of the matrix, creates n sized matrixes

output = zeros(size(matrix));

%output = [matrix, output];



% figure(1500)
% stackedplot(matrix)

offset = 1;

Fs = 300;            % Sampling frequency for my case frequency is 300 because 300 data points per second    

dt = 1/Fs;

freq = 1/(dt*n)*(0:n);

w = width(matrix);

for index = 1:1500%length(matrix) / (n - overlap)
    slice = matrix(offset:offset + n, :);

    if shouldBandPass
        slice = bandpass(slice, [1, 50], 300);
    end

    for jindex = 1:w
        sslice = slice(:, jindex);
        fhat = fft(sslice);

        PSD = fhat.*conj(fhat)/n;
        PSD(1:175,:) = 0;
    
        %avg = mean(PSD);
        avg = trapz(PSD);
        output(offset + n,jindex) = avg;
    end

    offset = offset + (n - overlap);


    %fprintf('figure %d, avg %f\n', index, mean(PSD));

    %     Length = 1:floor(n/2);
    % 
    %     figure(index)
    %     stackedplot(slice);
    %     figure (100 + index)
    %     plot(freq(Length), PSD(Length));
    % 
    %     iPSD = ifft(fhat);
    %     
    %     figure (1000 + index)
    %     plot(freq(Length), iPSD(Length))

    if offset + n > length(matrix)
        break
    end
end

end