clear;
clc;
close all;

flash_light_paths = ["../light_comment_start_end/eegData.csv", ...
                     "../light_comment_start_end/eegData0.csv", ...
                     "../light_comment_start_end/eegData1.csv", ...
                     "../light_comment_start_end/eegData2.csv", ...
                     "../light_comment_start_end/eegData3.csv"];


[action_data, between_action_data] = get_all_data(flash_light_paths);

action_class = generate_labels(action_data, 'flashing lights');

between_action_class = generate_labels(between_action_data, 'between action');


X = [];
Y = [];

model = fitcknn(X, Y);

error_rate = loss(model, ,);

accuracy = 1 - error_rate;