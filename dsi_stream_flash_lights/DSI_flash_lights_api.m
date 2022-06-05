clc;
clear;
close all;

%% Initialize the TCP/IP
t = tcpip('localhost', 8844);
fclose(t); %just in case it was open from a previous iteration
fopen(t); %opens the TCPIP connection

% Open text file for writing data
% Make new file if one already exists
fileName = '../light_comment_start_end/eegData0.csv';
i = 0;
while (exist(fileName, 'file') == 2)
    fileName = strrep(fileName, int2str(i), int2str(i+1));
    i = i+1;
end

textFile = fopen(fileName, 'a'); 
% 'a' creates and opens a new file or opens a preexisting file to append to

%% Creating events
% An event will be either flashing lights or a sound
%f = figure;
%f = figure('WindowState', 'maximized', 'Color', 'black'); % Full-screen figure
rectangle('FaceColor', [0 0 0]) % [0, 0, 0] is black

%% Used for the action function. Switch between the functions to use different variables
colors = get_color_array();
[~, colors_size] = size(colors);

% Also used for the action function. This crazy loop can be simplified
notes = {'C' 'G' 'A' 'F'}; %notes which will be used
freq = [261.60 391.99 440.00 349.23]; %frequencies of notes above
melody = {'C' 'G' 'A' 'F' 'C' 'G' 'A' 'F'}; %four chords played twice
sounds = [];

%For Loop
for k = 1:numel(melody)
    note = 0:0.00025:1.0; % Note duration (which can be edited for length)
    sounds = [sounds sin(2 * pi * freq(strcmp(notes, melody{k})) * note)];
end

[~, sounds_size] = size(sounds);

activity_state = activity_states.none;

%% The TCPIP Reading Loops

% Initialize timeLog and plotCounter for real time plotting
%timeLog = zeros(1,100);
%plotCounter = 0;

headerStart = [64, 65, 66, 67, 68]; % All DSI packet headers begin with '@ABCD', corresponding to these ASCII codes.
cutoffcounter = 0;
notDone = 1;

num_flashes = 0;

%% A bunch of constants
% These constants are set up so that a future user can change them for
% their needs.
MAX_FLASHES = 10;
MAX_PACKETS_DROPPED = 1500;
QUIET_TIME = 4; % Number of seconds between starting an action.
ACTIVE_TIME = 1; % Number of seconds the action takes. Should always be smaller than quiet time.
CHANGE_THRESHOLD = 50; % Number of milliseconds until there is a change in the action state


while notDone
    %% Termination clause
    if num_flashes > MAX_FLASHES
        notDone = 0;
        disp("Done!!!")
    end
    if t.Bytesavailable < 12                     %if there's not even enough data available to read the header
        cutoffcounter = cutoffcounter + 1;       %take a step towards terminating the whole thing
        if cutoffcounter == MAX_PACKETS_DROPPED  %and if 1500 steps go by without any new data,
            notDone = 0;                         %terminate the loop.
        end
        disp('no bytes available') % Load bearing disp(). If removed increase the pause time
        pause(0.001)
        continue
    else  %meaning, unless there's data available.
        cutoffcounter = 0;
    end

    % Read the packet
    data = uint8(fread(t, 12))'; % Loads the first 12 bytes of the first packet, which should be the header
    data = [data, uint8(fread(t, double(typecast(fliplr(data(7:8)), 'uint16'))))']; % Loads the full packet, based on the header
    lengthdata = length(data);

    if all(ismember(headerStart,data)) % Checks if the packet contains the header
        packetType = data(6); %this determines whether it's an event or sensor packet.

        %% Event Packet.  This includes the greeting packet
        if packetType == 5
            disp("event packet!")
        end

        %% EEG sensor packet
        if packetType == 1
            Timestamp = swapbytes(typecast(data(13:16),'single'));
            EEGdata = swapbytes(typecast(data(24:lengthdata),'single'));

            EEGdata = EEGdata(1:7);

            %% Actions are an FSA (Fourier Spectral Analysis)
            % The comment is added at the end of a timestamp
            comment = '';

            if activity_state == activity_states.none
                activity_start_time = clock;
                activity_state = activity_states.quiet;
            end

            time_passed = etime(clock, activity_start_time);

            if activity_state == activity_states.none
                activity_start_time = clock;
                activity_state = activity_states.quiet;
            elseif activity_state == activity_states.quiet
                if time_passed > QUIET_TIME
                    num_flashes = num_flashes + 1;
                    activity_state = activity_states.active;
                    activity_start_time = clock;
                    last_time_color_changed = activity_start_time;
                    last_color = 0;
                    comment = '1, start of action';
                end
            elseif activity_state == activity_states.active
                if time_passed > ACTIVE_TIME
                    rectangle("FaceColor", 'k')  % Reset the automata ('k' == black)
                    activity_state = activity_states.quiet;
                    activity_start_time = clock;
                    comment = '2, end of action';
                end
            else
                disp("unexpected state!")
            end

            if activity_state == activity_states.active
                milliseconds_since_color_changed = milliseconds(clock - last_time_color_changed);
                milliseconds_since_color_changed = milliseconds_since_color_changed(6:6) * 1000000;
                milliseconds_since_color_changed = time2num(milliseconds_since_color_changed);

                if (milliseconds_since_color_changed > CHANGE_THRESHOLD)
                    % disp("CHANGING COLORS"); 
                    %[last_time_color_changed, last_color] = action(last_color, colors, colors_size);
                    [last_time_color_changed, last_color] = sound_action(last_color, sounds, sounds_size);
                end
            end

            %% Write data to text file
            fmtSpec = repmat('%f,', 1, 7);
            
            fprintf(textFile, '%f,', time_passed);
            fprintf(textFile, '%f,', Timestamp);
            
            fprintf(textFile, fmtSpec, EEGdata);

            fprintf(textFile, '%s,', comment);

            fprintf(textFile, '\n');
        end
    end
end

fclose(t);
fclose('all');