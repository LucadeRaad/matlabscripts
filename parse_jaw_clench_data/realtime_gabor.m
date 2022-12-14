clc;
clear;
close all;

%% Initialize the TCP/IP
t = tcpip('localhost', 8844);
fclose(t); %just in case it was open from a previous iteration
fopen(t); %opens the TCPIP connection

headerStart = [64, 65, 66, 67, 68]; % All DSI packet headers begin with '@ABCD', corresponding to these ASCII codes.
cutoffcounter = 0;
notDone = 1;

% Initialize timeLog and plotCounter for real time plotting
timeLog = zeros(1,100);
plotCounter = 0;

%% A bunch of constants
% These constants are set up so that a future user can change them for
% their needs.
MAX_PACKETS_DROPPED = 1500;


pause

while notDone
    %% Termination clause
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
    packet_info = uint8(fread(t, 12))'; % Loads the first 12 bytes of the first packet, which should be the header
    data = [packet_info, uint8(fread(t, double(typecast(fliplr(packet_info(7:8)), 'uint16'))))']; % Loads the full packet, based on the header
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

            %% Plot data in realtime
            % Initialize time and signal logs based on packet size. This
            % can vary based on headset and number of channels
            % available.
            if all(timeLog(:) == 0)
               timeLog = Timestamp;
               signalLog = EEGdata';
            else
               timeLog = [timeLog, Timestamp];
               signalLog = [signalLog, EEGdata'];
            end
            
            % Limit the size of the logs to 100 data points for plotting
            if length(timeLog) >= 100
               timeLog = timeLog(end-99:end);
               signalLog = signalLog(:,end-99:end);
            end
            
            if plotCounter >= 36 % MATLAB waits a specified number of cycles before plotting the data to increase performance.
               plotCounter = 0;
               plot(timeLog,signalLog(1:size(signalLog,1),:))
               xlim([timeLog(1)-1/300, timeLog(end)+1/300])
               ylim([-1000, 1000])
               drawnow;
            else
               plotCounter = plotCounter + 1;
                
            end
        end
    end
end

close all;
fclose(t);
fclose('all');