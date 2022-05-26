clc;
clear;
close all;

%% Initialize the TCP/IP
t = tcpip('localhost', 8844);
fclose(t); %just in case it was open from a previous iteration
fopen(t); %opens the TCPIP connection

% Open text file for writing data
textFile = fopen('eegData.csv', 'w');

%% Creating events
% An event will be either flashing lights or a sound
f = figure;
rectangle('FaceColor', [0 0 0])

colors = get_color_array();
[~, colors_size] = size(colors);

activity_state = activity_states.none;

%% The TCPIP Reading Loops

% Initialize timeLog and plotCounter for real time plotting
%timeLog = zeros(1,100);
%plotCounter = 0;

headerStart = [64, 65, 66, 67, 68]; % All DSI packet headers begin with '@ABCD', corresponding to these ASCII codes.
cutoffcounter = 0;
notDone = 1;

while notDone
    %% Termination clause
    if t.Bytesavailable < 12                %if there's not even enough data available to read the header
        cutoffcounter = cutoffcounter + 1;  %take a step towards terminating the whole thing
        if cutoffcounter == 1500            %and if 1500 steps go by without any new data,
            notDone = 0;                    %terminate the loop.
        end
        disp('no bytes available')
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

            %% Actions are an FSA
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
                if time_passed > 4
                    activity_state = activity_states.active;
                    activity_start_time = clock;
                    last_time_color_changed = activity_start_time;
                    last_color = 0;
                    comment = '1, start of action';
                end
            elseif activity_state == activity_states.active
                if time_passed > 1
                    rectangle("FaceColor", 'k')  % Reset the automata
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

                if (milliseconds_since_color_changed > 100)
                    disp("CHANGING COLORS");
                    last_color = mod(last_color, colors_size) + 1;
                    rectangle("FaceColor", colors(last_color));
                    last_time_color_changed = clock;
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
