function matrix = clean_data(file)
%CLEAN_DATA Takes a csv file taken from ***LUCA'S AUTO GENERATED and returns data
%   The returned data is only the information, not the comments nor the
%   time.
    matrix = readmatrix(file);

    matrix(:,1) = [];

    % matrix = normalize(matrix, 'scale');
end

