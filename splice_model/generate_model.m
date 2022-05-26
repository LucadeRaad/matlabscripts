clear;
clc;
close all;

flash_light_raw = clean_data("../light_flash/test_filtered.csv");

flash_light_paths = ["../light_flash/second_iteration_filtered.csv", ...
                     "../light_flash/test_0001_filtered.csv", ...
                     "../light_flash/test_iteration_0001_filtered.csv", ...
                     "../light_flash/test_filtered.csv"];

sound_paths = ["../sound/sound_data_0001_filtered.csv", ...
               "../sound/sound_data_0002_filtered.csv", ...
               "../sound/sound_data_filtered.csv"];

all_flash_light_data = get_all_data(flash_light_paths);

all_sound_data = get_all_data(sound_paths);

do_nothing = clean_data("../light_flash/do_nothing]_filtered.csv");

do_nothing(5920:end,:) = [];
do_nothing(1:430,:) = [];

do_nothing_class = generate_labels(do_nothing, 'do nothing');

flash_light_class = generate_labels(all_flash_light_data, 'flash light');

sound_class = generate_labels(all_sound_data, 'sound');

full_session = label_session("../light_flash/test_filtered.csv", 'flash light');

X = [all_flash_light_data; do_nothing];
Y = [flash_light_class; do_nothing_class];

model = fitcknn(X, Y);

error_rate = loss(model, flash_light_raw, full_session);

accuracy = 1 - error_rate;

graph_model(model, "../light_flash/test_filtered.csv", 'flash light');
