function matrix = clean_data(file)
%CLEAN_DATA Takes a csv file taken from dsi streamer and returns data
%   The returned data is only the information, not the comments nor the
%   time.
    matrix = readmatrix(file);

    matrix(:,9:end) = [];
    matrix(:,1) = [];

    matrix = normalize(matrix, 'scale');
end

