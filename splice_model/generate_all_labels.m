function output_labels = generate_all_labels(data_matrix, label_name)
%GENERATE_ALL_LABELS Summary of this function goes here
%   Detailed explanation goes here
    [length, ~] = size(data_matrix);

    data = cell(1,length);

    for i = 1:length
        data{i} = generate_labels(data_matrix, label_name);
    end

    output_labels = transpose(data);

% 
%     output_data_length = 0;
% 
%     for i = 1:length
%         [l, ~] = size(data{i});
% 
%         output_data_length = output_data_length + l;
%     end
% 
%     output_labels = {};
% 
%     offset = 1;
% 
%     for i = 1:length
%         [l, ~] = size(data{i});
% 
%         output_labels(offset:offset + l - 1,:) = data(i);
% 
%         offset = offset + l;
%     end
end

