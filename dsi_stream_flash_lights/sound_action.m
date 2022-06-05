function [last_time_action_changed, last_sound] = sound_action(last_sound, sounds, sounds_size)
    last_sound = mod(last_sound, sounds_size) + 820;
    sound(sounds(last_sound:last_sound + 820))
    last_time_action_changed = clock;
end

