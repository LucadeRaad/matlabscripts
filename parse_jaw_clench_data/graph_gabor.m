function graph_gabor(raw_data, window_size, overlap, displayFFT, filenames)
%GRAPH_GABOR Summary of this function goes here
%   Detailed explanation goes here

assert(overlap < window_size, ...
    'You cannot overlap more than the size than the window! Perhaps swap your window_size/overlap variables?')

if displayFFT
    if window_size - overlap < 600
        
        window_size = 600;

        overlap = 0;

        disp("Changing window_size and overlap to 600 and 0 to make sure not too many windows are formed!")
    end
end

for index = 1:length(raw_data)
    matrix = raw_data{index};

    % displayFFT is more for testing so we resize matrix for easier
    % visualization, so we can just look at the first column
    if displayFFT
        matrix = matrix(:,1);
    end

    output = gabor_transform(matrix, window_size, overlap, displayFFT);

    dp = find(output, 1);
    output(1:dp,:) = 0;

    if displayFFT
        graph = zeros(size([matrix, output + 1]));
    else
        graph = [zeros(size([matrix, output + 1])), zeros(size(output,1),1)];
        
        % Channel 2: F4-LE
        % Channel 4: C4-LE
        % Channel 6: P3-LE
        % Channel 7: P4-LE

        % These channels are the most correct. We OR them because they have
        % many false negatives which result in partial correctness but
        % combined they fill in each other's gaps.

        alg_output = output(:,2) | output(:,4) | output(:,6) | output(:,7);

        graph(:,end) = alg_output;
    end

    % We will now take the data, and put it next to its channel eg. output
    % column 1 right below data column 1 for easier viewing.

    for jindex = 1:width(matrix)
        gindex = jindex - 1;
        gindex = gindex * 2;
        gindex = gindex + 1;
        
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
    t = stackedplot(graph);
    t.Title = sprintf('Figure %d unfiltered data(%s)', index, filenames{index});
    t.XLabel = 'Data Points (300 samples per second)';

    if displayFFT
        t.DisplayLabels = ["Microvolts", "Algorithm Output"];
    else
        t.DisplayLabels = ["F3 - LE (Microvolts)", "F3 - LE Algorithm Output", ... 
                           "F4 - LE (Microvolts)", "F4 - LE Algorithm Output", ...
                           "C3 - LE (Microvolts)", "C3 - LE Algorithm Output", ...
                           "C4 - LE (Microvolts)", "C4 - LE Algorithm Output", ...
                           "Pz - LE (Microvolts)", "Pz - LE Algorithm Output", ...
                           "P3 - LE (Microvolts)", "P3 - LE Algorithm Output", ...
                           "P4 - LE (Microvolts)", "P4 - LE Algorithm Output", ...
                           "All Algorithm Output"];
    end
end
end

