function action = get_full_data(file)
%GET_FULL_DATA Summary of this function goes here
%   Detailed explanation goes here
    Data = clean_data(file);
    
    % Readtable doesnt work
    comments = readmatrix(file);

    comments = comments(:,13);
    
    % Note that this will clump all actions into one, which means this code
    % will need to be modified if you want to have multiple stimuli in one
    % session
    indexes_of_actions = find(comments);
    
    action_sessions = get_actions(Data, indexes_of_actions);
    
    % Normalize the data so it can be compared, put on a graph etc.
    action = normalize(action_sessions);
end

function session_output = get_actions(data, data_indexes)
    snippet_size = get_snippet_size();

    % If a snippet is too close to the beginning we don't want to use it
    % this can result in losing a data point
    if data_indexes(1,:) < snippet_size
        data_indexes(1,:) = [];
    end

    [length, ~] = size(data_indexes);

    % We create a session of the size we want so that matlab doesn't have
    % to deal with creating many matrixes all the time
    session = zeros([length * snippet_size * 2, 7]);
    
    for i = 1:length
        n = data_indexes(i,:);

        snippet = data(n - snippet_size : n + snippet_size - 1,:);

        session_offset_start = ((snippet_size * 2) * (i - 1)) + 1;
        session_offset_end = session_offset_start + (snippet_size * 2) - 1;

        session(session_offset_start:session_offset_end,:) = snippet;

%         figure
%         stackedplot(snippet);
    end

    session_output = session;
end
