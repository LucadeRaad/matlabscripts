function output_data = get_all_data(paths)
%GET_ALL_DATA Summary of this function goes here
%   Detailed explanation goes here
    [~, length] = size(paths);

    data = cell(1,length);

    for i = 1:length
        data{i} = get_full_data(paths(i));
    end

    output_data_length = 0;

    for i = 1:length
        [l, ~] = size(data{i});

        output_data_length = output_data_length + l;
    end

    output_data = zeros([output_data_length, 7]);

    offset = 1;

    for i = 1:length
        [l, ~] = size(data{i});

        output_data(offset:offset + l - 1,:) = cell2mat(data(i));

        offset = offset + l;
    end
end

