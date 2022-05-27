function labels = label_session(file, label_name)
%LABEL_SESSION Puts labels around actions during a session
%   Unlike generate_labels this function should take in an entire session
%   and it will label the areas around an event as the event but label the
%   other areas as 'do nothing' this code assumes that the session only has
%   one type of event and that the person wearing the eeg is idle between
%   events.
    labels = label_actions(file, label_name);
end

function session_output = label_actions(file, label_name)
    comments = readmatrix(file);
    comments = comments(:,13);
    
    data_indexes = find(comments);

    snippet_size = get_snippet_size();

    % If a snippet is too close to the beginning we don't want to use it
    % this can result in losing a data point
    if data_indexes(1,:) < snippet_size
        data_indexes(1,:) = [];
    end

    data = clean_data(file);

    [num_indexes, ~] = size(data_indexes);
    [data_size, ~] = size(data);

    % We create a session of the size we want so that matlab doesn't have
    % to deal with creating many matrixes all the time
    session = cell(data_size, 1);    

    action_cell= cell(1);
    action_cell(:) = {label_name};

    nothing_cell = cell(1);
    nothing_cell(:) = {'do nothing'};

    session(:) = nothing_cell;

    for i = 1:num_indexes
        n = data_indexes(i,:);

        session_offset_start = n - snippet_size + 1;
        session_offset_end = n + snippet_size - 1;

        session(session_offset_start:session_offset_end,:) = action_cell;
    end

    session_output = session;
end
