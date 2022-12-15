clc;
clear;
close all;

%% Initialize the TCP/IP
t = tcpip('localhost', 8844);
fclose(t); %just in case it was open from a previous iteration
fopen(t); %opens the TCPIP connection

newcolors = [0.83 0.14 0.14
             1.00 0.54 0.00
             0.47 0.25 0.80
             0.25 0.80 0.54
             0.00 0.00 1.00];

colororder(newcolors);

% Don't ever change this, unless wearable sensing changes their packet
% structure
HEADER_START = [64, 65, 66, 67, 68]; % All DSI packet headers begin with '@ABCD', corresponding to these ASCII codes.

%% A bunch of constants
% These constants are set up so that a future user can change them for
% their needs.
MAX_PACKETS_DROPPED = 1500;

FIGURE_SIZE = 900;

FIGURE_Y_MAX_LIM = 1000;
FIGURE_Y_MAX_MID_LIM = FIGURE_Y_MAX_LIM / 2;

FIGURE_Y_MIN_LIM = -1 * FIGURE_Y_MAX_LIM;
FIGURE_Y_MIN_MID_LIM = FIGURE_Y_MIN_LIM / 2;

FIGURE_WRITE_DELAY = 36;

SLICE_COUNT = 9;

SLICE_STEP = 5;

DATAPOINTS_PER_SEC = 300;

DATABUFFER_SIZE = 1201;

GABOR_WINDOW_SIZE = 300;

NUM_CHANNELS = 4;

Fs = 300;

dt = 1/Fs;

FREQ_INCR = 1 / (dt * GABOR_WINDOW_SIZE);

% https://stackoverflow.com/questions/31325491/how-to-design-a-zero-phase-bandpass-filter-for-1-to-20-hz-in-matlab
% Changed to be a 1-50 bandpass
B_PASS = fir1(400, [1,50] / (Fs / 2));
A_PASS = 1;

gaborCount = 0;
dataCount = 0;
plotCounter = 0;
packetDropCounter = 0;

% Initialize timeLog and plotCounter for real time plotting
allData = zeros(DATABUFFER_SIZE, NUM_CHANNELS);
displayData = zeros(DATABUFFER_SIZE, NUM_CHANNELS);
timeLog = zeros(DATABUFFER_SIZE, 1);
algOutput = zeros(DATABUFFER_SIZE, 1);

sliceVals = zeros(SLICE_COUNT, NUM_CHANNELS);

%% Figure Initialization

title('Realtime EEG Processing','HandleVisibility','off');
ylabel('Microvolts','HandleVisibility','off');
xlabel('Data Points (300 samples per second)','HandleVisibility','off');

hold on

ylim([FIGURE_Y_MIN_LIM, FIGURE_Y_MAX_LIM])

% https://www.mathworks.com/matlabcentral/answers/338733-how-to-stop-legend-from-adding-data1-data2-when-additional-data-is-plotted
set(0, 'DefaultLegendAutoUpdate', 'off')

legend('F4-LE', 'C4-LE', 'P3-LE', 'p4-LE', 'Algorithm Output', 'Location', 'northwest');

notDone = 1;

while notDone
    %% Termination clause
    if t.Bytesavailable < 12                        %if there's not even enough data available to read the header
        packetDropCounter = packetDropCounter + 1;  %take a step towards terminating the whole thing

        if packetDropCounter == MAX_PACKETS_DROPPED %and if 1500 steps go by without any new data,
            notDone = 0;                            %terminate the loop.
        end

        disp('no bytes available') % Load bearing disp(). If removed increase the pause time
        pause(0.001)
        continue
    else  %meaning, unless there's data available.
        packetDropCounter = 0;
    end

    %% Read the packet
    packet_info = uint8(fread(t, 12))'; % Loads the first 12 bytes of the first packet, which should be the header
    data = [packet_info, uint8(fread(t, double(typecast(fliplr(packet_info(7:8)), 'uint16'))))']; % Loads the full packet, based on the header
    lengthdata = length(data);

    % Checks if the packet contains the header
    if all(ismember(HEADER_START, data)) 
        % This determines whether it's an event or sensor packet.
        packetType = data(6);          

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

            %% Add EEG data to buffer
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
            
            %% Perform gabor transform on data
            if (gaborCount >= GABOR_WINDOW_SIZE)
                displayData = filtfilt(B_PASS, A_PASS, allData);

                gaborSlice = displayData(dataCount - GABOR_WINDOW_SIZE:dataCount, :);

                fhat = fft(gaborSlice, [], 1);
                PSD = fhat.*conj(fhat) / GABOR_WINDOW_SIZE;

                for k = SLICE_STEP:SLICE_STEP:(SLICE_STEP * SLICE_COUNT)
                    s_ind = floor(k / FREQ_INCR);
                    e_ind = floor((k + SLICE_STEP) / FREQ_INCR) + 1;

                    sliceVals(k / SLICE_STEP, :) = mean(PSD(s_ind:e_ind, :));
                end

                [~, minInds] = min(sliceVals, [], 1);
                [~, maxInds] = max(sliceVals, [], 1);

                allChannels = maxInds > minInds;

                isClench = allChannels(1) | allChannels(2) | allChannels(3) | allChannels(4);

                if isClench
                    algOutput(dataCount - GABOR_WINDOW_SIZE:dataCount, :) = FIGURE_Y_MAX_MID_LIM;
                else
                    algOutput(dataCount - GABOR_WINDOW_SIZE:dataCount, :) = FIGURE_Y_MIN_MID_LIM;
                end
                
                gaborCount = 0;
            else
                gaborCount = gaborCount + 1;
            end

            %% Plot data in realtime
            if plotCounter >= FIGURE_WRITE_DELAY % MATLAB waits a specified number of cycles before plotting the data to increase performance.
                if dataCount <= FIGURE_SIZE
                    smallSlice = 1:dataCount;

                    graphLog = [displayData(smallSlice, :), algOutput(smallSlice, :)];
                    graphTime = timeLog(smallSlice);
                else
                    bigSlice = dataCount - FIGURE_SIZE;

                    graphLog = [displayData(bigSlice:dataCount, :), algOutput(bigSlice:dataCount)];
                    graphTime = timeLog(bigSlice:dataCount);
                end

                set(gca,'NextPlot','replacechildren');

                plot(graphTime, graphLog);

                legend show

                xlim([graphTime(1) - 1 / DATAPOINTS_PER_SEC, graphTime(end) + 1 / DATAPOINTS_PER_SEC])

                %legend('F4-LE', 'C4-LE', 'P3-LE', 'F4-LE', 'Algorithm Output')

                
                
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