function matrix = clean_data(file)
%CLEAN_DATA Takes a csv file taken from ***LUCA'S AUTO GENERATED and returns data
%   The returned data is only the information, not the comments nor the
%   time.
    matrix = readmatrix(file);

    matrix(:,11:end) = [];

    matrix(:,1) = [];

    % Normalize the data so it can be compared, put on a graph etc.
    matrix = normalize(matrix);
end

