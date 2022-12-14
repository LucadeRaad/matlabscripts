clc;
clear;
close all;

load("bandpass_model.mat", "bandpass_model");

%% Initialize the TCP/IP
t = tcpip('localhost', 8844);
fclose(t); %just in case it was open from a previous iteration
fopen(t); %opens the TCPIP connection

headerStart = [64, 65, 66, 67, 68]; % All DSI packet headers begin with '@ABCD', corresponding to these ASCII codes.
cutoffcounter = 0;
notDone = 1;

graph_write_delay = 36;

%% A bunch of constants
% These constants are set up so that a future user can change them for
% their needs.
MAX_PACKETS_DROPPED = 1500;

FIGURE_SIZE = 600;

FIGURE_Y_MAX_LIM = 1000;

FIGURE_Y_MIN_LIM = -1000;

BANDPASS_RANGE = [1, 50];

DATAPOINTS_PER_SEC = 300;

DATABUFFER_SIZE = 10000;

GABOR_WINDOW_SIZE = 300;

NUM_CHANNELS = 4;

% The indexes for the slices that the FFT output is put into.
SLICE_INDEXES = [1, 6, 11, 16, 21, 26, 31, 36, 41, 46, 51];

Fs = 300;

dt = 1/Fs;

FREQ_INCR = 1 / (dt * GABOR_WINDOW_SIZE);

gaborCount = 0;
dataCount = 0;
plotCounter = 0;

% Initialize timeLog and plotCounter for real time plotting
allData = zeros(DATABUFFER_SIZE, NUM_CHANNELS);
displayData = zeros(DATABUFFER_SIZE, NUM_CHANNELS);
timeLog = zeros(DATABUFFER_SIZE, 1);
algOutput = zeros(DATABUFFER_SIZE, 1);

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

            EEGdata(8:end) = [];

            % We discard EEG channels that are unused in the algorithm.
            % we only use:
            % Channel 2: F4-LE
            % Channel 4: C4-LE
            % Channel 6: P3-LE
            % Channel 7: P4-LE

            EEGdata(5) = [];
            EEGdata(3) = [];
            EEGdata(1) = [];

            %% Plot data in realtime
            if dataCount <= DATABUFFER_SIZE
                dataCount = dataCount + 1;

                allData(dataCount,:) = EEGdata;
                displayData(dataCount,:) = EEGdata;

                timeLog(dataCount,:) = Timestamp;

                algOutput(dataCount,:) = 0;
            else
                allData = circshift(allData, -1);
                allData(dataCount,:) = EEGdata;

                displayData = circshift(displayData, -1);
                displayData(dataCount,:) = EEGdata;

                timeLog = circshift(timeLog, -1);
                timeLog(end) = Timestamp;

                algOutput = circshift(algOutput, -1);
                algOutput(end) = 0;
            end
            
            if (gaborCount >= GABOR_WINDOW_SIZE)
                %gaborSlice = allData(end - (GABOR_WINDOW_SIZE) : end, :);

                %gaborSlice = bandpass(gaborSlice, BANDPASS_RANGE, DATAPOINTS_PER_SEC);

                gaborSlice = filter(bandpass_model, allData(1:dataCount, :));

                displayData(end - (GABOR_WINDOW_SIZE - 1) : end, :) = gaborSlice;



%                 sliceVals = zeros(length(SLICE_INDEXES) - 1, NUM_CHANNELS);
% 
%                 fhat = fft(d(iter : iter + (GABOR_WINDOW_SIZE - 1), :), [], 1);
%                 PSD = fhat.*conj(fhat)/GABOR_WINDOW_SIZE;
% 
%                 for k = 5:SLICE_STEP:(SLICE_STEP * (SLICE_COUNT))
%                     s_ind = floor(k / freq_incr);
%                     e_ind = floor((k + SLICE_STEP) / freq_incr) + 1;
%                 
%                     sliceVals(k / SLICE_STEP, :) = mean(PSD(s_ind : e_ind, :));
%                 end
%        
%                 [~, mininds] = min(sliceVals, [], 1);
%                 [~, maxinds] = max(sliceVals, [], 1);

                gaborCount = 0;
            else
                gaborCount = gaborCount + 1;
            end

            if plotCounter >= graph_write_delay % MATLAB waits a specified number of cycles before plotting the data to increase performance.
                % graphLog = bandpass(allData.', BANDPASS_RANGE, DATAPOINTS_PER_SEC);

                if dataCount <= FIGURE_SIZE
                    graphLog = displayData(1 : dataCount, :);
                    graphTime = timeLog(1 : dataCount);
                else
                    graphLog = [displayData(dataCount - FIGURE_SIZE: dataCount, :), algOutput(dataCount - FIGURE_SIZE: dataCount)];
                    graphTime = timeLog(dataCount - FIGURE_SIZE: dataCount);
                end
  
                plot(graphTime, graphLog)

                xlim([graphTime(1) - 1 / DATAPOINTS_PER_SEC, graphTime(end) + 1 / DATAPOINTS_PER_SEC])

                %ylim([FIGURE_Y_MIN_LIM, FIGURE_Y_MAX_LIM])
                
                drawnow;

                plotCounter = 0;
            else
                plotCounter = plotCounter + 1;
            end
        end
    end
end

close all;
fclose(t);
fclose('all');