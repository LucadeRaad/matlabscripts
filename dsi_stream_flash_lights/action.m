function [last_time_action_changed, last_color] = action(last_color, colors, colors_size)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    disp("CHANGING COLORS");
    last_color = mod(last_color, colors_size) + 1;
    rectangle("FaceColor", colors(last_color));
    last_time_action_changed = clock;
end

