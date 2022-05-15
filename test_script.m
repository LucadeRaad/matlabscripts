clear;
clc;
close all;

[Left1, Right1] = GetFullData("UWB Test Data_filtered_Round1.csv");
[Left2, Right2] = GetFullData("UWB Test Data 2_0001_raw.csv");
[Left3, Right3] = GetFullData("UWB Test Data 3_filtered.csv");

% stackedplot(Left1)
% figure;
% stackedplot(Left2)
% figure;
% stackedplot(Left3)
% figure;
% stackedplot(Right1)
% figure;
% stackedplot(Right2)
% figure;
% stackedplot(Right3)


% % To do knn we need a matrix of cells that hold 1x1 cell arrays that hold 
% % the strings that are the class names. They need to be 1:1 with the data
% % matrixes. This is really fun.
% 
% Right1 = [Right1 ; Right3];
% 
% Left1 = [Left1 ; Left3];
% 
% [NoActionLength, ~] = size(NoAction1);
% [LeftLength, ~] = size(Left1);
% [RightLength, ~] = size(Right1);
% 
% NoActionClass = cell(NoActionLength, 1);
% LeftClass = cell(LeftLength, 1);
% RightClass = cell(RightLength, 1);
% 
% CellNoAction = cell(1);
% CellLeft = cell(1);
% CellRight = cell(1);
% 
% CellNoAction(:) = {'No Action'};
% CellLeft(:) = {'Look Left'};
% CellRight(:) = {'Look Right'};
% 
% NoActionClass(:) = CellNoAction;
% LeftClass(:) = CellLeft;
% RightClass(:) = CellRight;
% 
% % Now data is ready to put into KNN
% AllDataLuca1 = [NoAction1; Right1; Left1];
% AllClassLuca1 = [NoActionClass; RightClass; LeftClass];
% 
% KNN = fitcknn(AllDataLuca1, AllClassLuca1, 'NumNeighbors', 5, 'Standardize', 1);
% 
% % We compare data 1 to 2
% [LeftLabel, LeftScore, LeftCost] = predict(KNN, Left2);
% [RightLabel, RightScore, RightCost] = predict(KNN, Right2);
% [NoActionLabel, NoActionScore, NoActionCost] = predict(KNN, NoAction2);
% 
% leftCorrect = FindCorrectness(KNN, Left2, "left", CellNoAction, CellLeft, CellRight);
% rightCorrect = FindCorrectness(KNN, Right2, "right", CellNoAction, CellLeft, CellRight);
% noactionCorrect = FindCorrectness(KNN, NoAction2, "no action", CellNoAction, CellLeft, CellRight);
% 
% disp("Left Correctness: " + leftCorrect);
% disp("Right Correctness: " + rightCorrect);
% disp("No Action Correctness: " + noactionCorrect);

%Takes in a file, puts out 1 second after finding every look left and
%right, and an equal amount of downtime to equalize
function [LookLeft, LookRight] = GetFullData(file)
    Data = readmatrix(file);
    
    [Data, ~] = CleanData(Data);
    
    % Readtable doesnt work
    [~, comments] = xlsread(file);
    
    
    % We want to seperate and only have the comments
    comments = comments(:,14);
    
    % 300 rows is 1 second. Will need to read 300 before and take 5 seconds
    % 1500 rows after
    indexesOfLookLeft = contains(comments, 'Look Left');
    indexesOfLookLeft = find(indexesOfLookLeft);
    
    indexesOfLookRight = contains(comments, 'Look Right');
    indexesOfLookRight = find(indexesOfLookRight);
    
    look_left_sessions = GetActions(Data, indexesOfLookLeft, "look left");
    
    look_right_sessions = GetActions(Data, indexesOfLookRight, "look right"); 
    
    % Normalize the data so it can be compared, put on a graph etc.
    LookLeft = normalize(look_left_sessions);
    LookRight = normalize(look_right_sessions);
end

function [session_output] = GetActions(data, dataIndexes, title_txt)
    [length, ~] = size(dataIndexes);

    session = zeros([1, 7]);

    % offset;
    
    for i = 1:length
        n = dataIndexes(i,:);

        snippet = data(n - 300 : n + 1500,:);

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