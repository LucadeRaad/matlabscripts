function data = parse_eeg(dir_name, match)
%PARSE_EEG Takes a .csv from an eeg file and returns a matrix of the data
%   Only records data, no artifacts or other data

rand_clench_struct = dir(fullfile(dir_name, match));

filenames = struct2cell(rand_clench_struct);
filenames = append(filenames(2,:), '\', filenames(1,:));

len = length(filenames);

assert(len ~= 0, ...
    'Unable to find any files that match %s in dir %s. (The directory must be a local path from the script running it)\n', ...
    match, dir_name);

data = {len};

for index = 1:len
    data{index} = readmatrix(filenames{index});

    data{index}(:,9:end) = [];

    data{index}(:,1) = [];
end

% output = cat(1, data{:});

end

