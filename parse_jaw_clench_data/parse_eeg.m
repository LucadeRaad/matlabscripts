function data = parse_eeg(file_name)
%PARSE_EEG Takes a .csv from an eeg file and returns a matrix of the data
%   Only records data, no artifacts or other data

rand_clench_struct = dir(fullfile(file_name, '*_filtered.csv'));

filenames = struct2cell(rand_clench_struct);
filenames = append(filenames(2,:), '\', filenames(1,:));

data = {length(filenames)};

for index = 1:length(filenames)
    data{index} = readmatrix(filenames{index});

    data{index}(:,9:end) = [];

    data{index}(:,1) = [];
    
    % for testing
    %data{index}(:,2:end) = [];
end

% output = cat(1, data{:});

end

