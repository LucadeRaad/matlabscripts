% Created by Maryam, edited by Luca
clear;
clc;
close all;

% Variables
filtered_unordered_eeg = parse_eeg('Data_RandomClench', '*_filtered.csv');
% filtered_ordered_eeg = parse_eeg('Data_Clench_RAW', '*_filtered.csv');
n = 500;
iteration=10;
displayFFT=false;

for i=0:iteration:99 % Start movie loop
    pause(1);
    overlap = n/100 *i;
    f = figure(1);
    title = 'overlap= ' + string(overlap);
    disp(title);

    % We only care about 1 session at a time!
    graph_gabor(filtered_unordered_eeg(1), n, overlap, displayFFT);
    
    set(f, 'Name', title);

end % End of movie loop

pause(10);
close('all');
