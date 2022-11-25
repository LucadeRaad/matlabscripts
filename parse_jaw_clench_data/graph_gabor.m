function graph_gabor(raw_data, window_size, overlap, displayFFT, filenames)
%GRAPH_GABOR Summary of this function goes here
%   Detailed explanation goes here

assert(overlap < window_size, ...
    'You cannot overlap more than the size than the window! Perhaps swap your window_size/overlap variables?')


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

    more_than_half_eeg_channels = 4;

    if size(output, 2) > more_than_half_eeg_channels
        graph = [zeros(size([matrix, output + 1])), zeros(size(output,1),1)];    

        % Channel 1: F3-LE
        % Channel 2: F4-LE
        % Channel 5: Pz-LE
        % Channel 6: P3-LE

        % These channels are the most correct. Therefore we weigh them the
        % most. Individually they can be 50%-100% correct but are wrong as
        % false negatives so we can "OR" them to remove as many false
        % negatives

        % F3F4 = output(:,1) & output(:,2);

        alg_output = output(:,2) | output(:,4) | output(:,6) | output(:,7); % output(:,1) | output(:,5);% | output(:,6); %   |
        % F3-LE, F4-LE, 

        graph(:,end) = alg_output;

    else
        graph = zeros(size([matrix, output + 1]));
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

