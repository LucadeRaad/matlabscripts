function output_labels = generate_all_labels(data_matrix, label_name)
%GENERATE_ALL_LABELS Summary of this function goes here
%   Detailed explanation goes here
    [length, ~] = size(data_matrix);

    data = cell(1,length);

    for i = 1:length
        data{i} = generate_labels(data_matrix, label_name);
    end

    output_labels = transpose(data);
end

