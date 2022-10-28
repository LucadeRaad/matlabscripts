function graph_gabor(raw_data, n, overlap, displayFFT)
%GRAPH_GABOR Summary of this function goes here
%   Detailed explanation goes here

if overlap > n
    disp("You cannot overlap more than the size than the window! Perhaps swap your n/overlap variables?")

    return
end

for index = 1:length(raw_data)
    matrix = raw_data{index};

    % displayFFT is more for testing so we resize matrix for easier
    % visualization, we just look at the first column
    if displayFFT
        matrix = matrix(:,1);
    end

    output = gabor_transform(matrix, n, overlap, displayFFT);

    dp = find(output, 1);

    output(1:dp,:) = 0;

    graph = zeros(size([matrix, output]));

    for jindex = 1:width(matrix)
        gindex = jindex - 1;
        gindex = gindex * 2;
        gindex = gindex + 1;

        %graph(:,gindex) = EEGFILTFFT(graph(:,gindex), 300, 1, 50); % bandpass(graph(:,gindex), [1, 50], 300);
        
        graph(:,gindex) = matrix(:,jindex);

        graph(:,gindex + 1) = output(:,jindex);
    end

    figIndex = index;

    % There will be many other graphs but we want to also see the bigger
    % picture so we put the final graph at a really big number so it
    % doesn't overwrite anything
    if displayFFT
        figIndex = figIndex + 10000;
    end

    figure(figIndex);
    stackedplot(graph);
    
end


end

