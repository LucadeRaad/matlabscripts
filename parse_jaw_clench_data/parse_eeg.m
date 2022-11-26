function [data, names] = parse_eeg(dir_name, match, do_bandpass)
%PARSE_EEG Takes a .csv from an eeg file and returns a matrix of the data
%   Only records data, no artifacts or other information

rand_clench_struct = dir(fullfile(dir_name, match));

filenames = struct2cell(rand_clench_struct);
names =  filenames(1,:);
filenames = append(filenames(2,:), '\', names);

len = length(filenames);

assert(len ~= 0, ...
    'Unable to find any files that match %s in dir %s. (double check the path and from where you are calling your script if the path is relative)\n', ...
    match, dir_name);

data = {len};

for index = 1:len
    data{index} = readmatrix(filenames{index});

    data{index}(:,9:end) = [];

    data{index}(:,1) = [];

    if do_bandpass
        data{index} = bandpass(data{index}, [1, 50], 300);
    end
end

end

