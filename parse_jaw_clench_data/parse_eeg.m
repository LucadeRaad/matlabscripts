function [output] = parse_eeg(file_name)
%PARSE_EEG Takes a .csv from an eeg file and returns a matrix of the data
%   Only records data, no artifacts or other data

rand_clench_struct = dir(fullfile(file_name, '*_raw.csv'));

rand_clench_filenames = struct2cell(rand_clench_struct);
rand_clench_filenames = append(rand_clench_filenames(2,:), '\', rand_clench_filenames(1,:));

data = {length(rand_clench_filenames)};

for index = 1:length(rand_clench_filenames)
    data{index} = readmatrix(rand_clench_filenames{index});

    data{index}(:,9:end) = [];

    data{index}(:,1) = [];
    
    data{index}(:,2:end) = [];
    
    % 

    % figure(i)

    % stackedplot(data{i});
end


output = data;


% output = cat(1, data{:});

end

