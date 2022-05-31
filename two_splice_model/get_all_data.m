function [output_data, between_action_data] = get_all_data(paths)
%GET_ALL_DATA Summary of this function goes here
%   Detailed explanation goes here
    [~, length] = size(paths);

    data = cell(1, length);
    between_data = cell(1, length);

    for i = 1:length
        [between_data{i}, data{i}] = get_full_data(paths(i));
    end

    output_data_length = 0;

    output_between_length = 0;

    for i = 1:length
        [l, ~] = size(data{i});

        [bl, ~] = size(between_data{i});

        output_data_length = output_data_length + l;
        output_between_length = output_between_length + bl;
    end

    output_data = zeros([output_data_length, 7]);
    between_action_data = zeros([output_between_length, 7]);

    offset = 1;

    for i = 1:length
        [l, ~] = size(data{i});
        output_data(offset:offset + l - 1,:) = cell2mat(data(i));

        [l, ~] = size(between_data{i});
        between_action_data(offset:offset + l - 1,:) = cell2mat(between_data(i));

        offset = offset + l;
    end
end

