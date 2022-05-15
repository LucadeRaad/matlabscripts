clear;
clc;
close all;

[Left1, Right1] = GetFullData("UWB Test Data_filtered_Round1.csv");
[Left2, Right2] = GetFullData("UWB Test Data 2_0001_raw.csv");
[Left3, Right3] = GetFullData("UWB Test Data 3_filtered.csv");

%Takes in a file, puts out 1 second after finding every look left and
%right, and an equal amount of downtime to equalize
function [LookLeft, LookRight] = GetFullData(file)
    Data = readmatrix(file);
    
    [Data, ~] = CleanData(Data);
    
    % Readtable doesnt work
    [~, comments] = xlsread(file);
    
    
    % We want to seperate and only have the comments
    comments = comments(:,14);
    
    indexesOfLookLeft = contains(comments, 'Look Left');
    indexesOfLookLeft = find(indexesOfLookLeft);

    indexesOfLookLeftEnd = contains(comments, 'Look Left End');
    indexesOfLookLeftEnd = find(indexesOfLookLeftEnd);
    
    indexesOfLookRight = contains(comments, 'Look Right');
    indexesOfLookRight = find(indexesOfLookRight);

    indexesOfLookRightEnd = contains(comments, 'Look Right End');
    indexesOfLookRightEnd = find(indexesOfLookRightEnd);

    LookLeftSplices = [indexesOfLookLeft ; indexesOfLookLeftEnd];
    LookRightSplices = [indexesOfLookRight ; indexesOfLookRightEnd];
    
    look_left_sessions = GetActions(Data, LookLeftSplices, "look left");
    
    look_right_sessions = GetActions(Data, LookRightSplices, "look right");
    
    % Normalize the data so it can be compared, put on a graph etc.
    LookLeft = normalize(look_left_sessions);
    LookRight = normalize(look_right_sessions);
end

function [session_output] = GetActions(data, dataIndexes, title_txt)
    [length, ~] = size(dataIndexes);

    session = zeros([1, 7]);

    % offset;
    
    for i = 1:length
        start = dataIndexes(i,1);
        finish = dataIndexes(i,2);

        snippet = data(start - 300 : finish + 300,:);

        figure
        stackedplot(snippet);
        title(title_txt)

        %offset = input("Input any offset. The center is 300");

        % offset = [offset; offset];

        % session = [session; snippet];
    end

    session_output = session;

    % save_file = title_txt + ''

    % save()
end

% All of the input matrixes has a bunch of columns that will muddy the data
function [cleanMatrix, time] = CleanData(matrix)
    time = matrix(:,1);

    tempMatrix = matrix;

    tempMatrix(:,9:end) = [];
    tempMatrix(:,1) = [];

    cleanMatrix = tempMatrix;
end