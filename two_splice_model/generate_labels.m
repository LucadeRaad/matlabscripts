function labels = generate_labels(matrix, label_name)
%GENERATE_LABELS generates labels the size of the matrix
%   This should be used for training, but not testing as it expects the
%   matrix coming in to be soley of one class/label.
    label_name = convertStringsToChars(label_name);
    
    [label_length, ~] = size(matrix);

    single_cell = cell(1);
    single_cell(:) = {label_name};

    class_labels = cell(label_length, 1);
    class_labels(:) = single_cell;

    labels = class_labels;
end

