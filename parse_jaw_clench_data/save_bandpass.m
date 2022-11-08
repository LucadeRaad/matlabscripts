clear;
clc;
close all;

dir_name = 'Data_RandomClench';

match = '*_raw.csv';

csv_files = dir(fullfile(dir_name, match));

source_filenames = struct2cell(csv_files);
source_filenames = append(source_filenames(2,:), '\', source_filenames(1,:));

len = length(source_filenames);

assert(len ~= 0, ...
    'Unable to find any files that match %s in dir %s. (double check the path and from where you are calling your script if the path is relative)\n', ...
    match, dir_name);


dest_filenames = struct2cell(csv_files);

dest_full_path = dest_filenames(2,:);
dest_full_path = dest_full_path(1);
dest_full_path = dest_full_path{1}; % Matlab is a good language

dest_path_split = strsplit(dest_full_path, '\');
dest_path = dest_path_split(1);

for strindex = 2:length(dest_path_split) - 1
    dest_path = strcat(dest_path, '\', dest_path_split(strindex));
end

dest_path = strcat(dest_path, '\LUCA_BANDPASS_', dir_name);

if not(isfolder(dest_path{1}))
    mkdir(dest_path{1})
end

dest_filenames = dest_filenames(1,:);
dest_filenames = strrep(dest_filenames, '_raw', '_LUCA_BANDPASS');
dest_filenames = append(dest_path, '\', dest_filenames);


for index = 1:len
    full_data = readmatrix(source_filenames{index});

    data = full_data(:, 2:8);

    data = bandpass(data, [1, 50], 300);

    full_data(:, 2:8) = data;

    writematrix(full_data, dest_filenames{index});
end

