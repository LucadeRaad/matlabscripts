clear;
clc;
close all;

%% Note that this is hardcoded. When you add or remove .csv files remember to also update here!
% Note that this code will crash if you read a .csv file that doesn't exist
% so just double check that its all right
flash_light_paths = ["../light_comment_start_end/eegData.csv", ...
                     "../light_comment_start_end/eegData1.csv", ...
                     "../light_comment_start_end/eegData2.csv", ...
                     ];


[action_data, between_action_data] = get_all_data(flash_light_paths);

action_class = generate_labels(action_data, 'flashing lights');

between_action_class = generate_labels(between_action_data, 'between action');


X = [action_data; between_action_data];
Y = [action_class; between_action_class];

% Go to Apps -> Classification Learner -> Model of your choice to do ML

load('model.mat', 'FineGaussianSVM');

% graph_model(FineGaussianSVM, "../light_comment_start_end/eegData5.csv", "test");
