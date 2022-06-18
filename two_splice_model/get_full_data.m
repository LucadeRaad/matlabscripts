function [between_action, action] = get_full_data(file)
%GET_FULL_DATA Summary of this function goes here
%   Detailed explanation goes here
    Data = clean_data(file);
    
    comments = readcell(file);

    comments = comments(:,11);
    
    % Note that this will clump all actions into one, which means this code
    % will need to be modified if you want to have multiple stimuli in one
    % session
    indexes_of_action_start = find(strcmp(comments, 'start of action'));

    indexes_of_action_end = find(strcmp(comments, 'end of action'));

    [start_length, ~] = size(indexes_of_action_start);
    [end_length, ~] = size(indexes_of_action_end);

    assert (start_length == end_length, ...
            'There are an unqeual amount of start(%f.0) and end indexes(%f.0)', ...
            start_length, end_length)

    [action, between_action] = get_actions(Data, indexes_of_action_start, indexes_of_action_end);
end

function [action_data, between_action_data] = get_actions(data, indexes_of_action_start, indexes_of_action_end)
    [length, ~] = size(indexes_of_action_start);

    data_offset = 1;
    
    action_length = 0;
    between_action_length = 0;

    % This gets the total length of splices plus how much big the final
    % data matrixes will get
    for i = 1:length
        start_index = indexes_of_action_start(i,:);
        end_index = indexes_of_action_end(i,:);

        assert(start_index < end_index, 'start index is ahead of end index %f.0', i)

        action_length = action_length + end_index - start_index;

        between_action_length = between_action_length + start_index - data_offset - 1;

        data_offset = end_index;
    end

    data_offset = 1;
    action_offset = 1;
    between_action_offset = 1;

    % We create a session of the size we want so that matlab doesn't have
    % to deal with inefficient memory allocation
    action_data = zeros([action_length, 9]);

    between_action_data = zeros([between_action_length, 9]);
    
    for i = 1:length
        start_index = indexes_of_action_start(i,:);
        end_index = indexes_of_action_end(i,:);

        action_length = end_index - start_index;
        action_data(action_offset:action_offset + action_length,:) = data(start_index:end_index,:);

        action_offset = action_offset + action_length;

        between_action_length = start_index - data_offset - 1;

        between_action_data(between_action_offset:between_action_offset + between_action_length,:) = data(data_offset:start_index - 1,:);
        
        between_action_offset = between_action_offset + between_action_length;

        data_offset = data_offset + action_length + between_action_length;
    end
end
