# matlabscripts
 
General matlab scripts for GIZMO 2.0 EEG analysis at UWB.

## Installation

Clone the repo. Some scripts use the following matlab toolboxes:

- Statistics and Machine Learning Toolbox

- Parallel Computing Toolbox (recommended)

## dsi_stream_flash_lights

Have DSI streamer installed from [Wearable Sensing's website](https://wearablesensing.com/support/downloadables/)

Keep defaults, 300 data points per second should be fine
Any buffer/delay can cause data to get out of sync. To fix this make sure your computer is powerful enough to run the script and the DSI streamer without falling behind.

### To Test

To test the stream (if you are making modifications to the code and want to test, it won't create any new data) do the following:
1. Click on TCP IP
2. Click on Activate TCP/IP Socket
3. Then click on Start
4. Click run on DSI_flash_lights_api.m
5. Go (Quickly!) back to Data Source
6. Click on File
7. Click on Play, now any .dsi file can be used to simulate live eeg data

### To Run

Follow the above instructions until step 4 (assuming you have the headset working and everything). For now the program is hardcoded to flash 10 times and then stop running. You can do many sessions in a row without overwriting your data. If a session has too much noise (the time between data points is also recorded and used for machine learning) just delete the session you just created without fear of losing more data.

## rand_flashes

rand_flashes is not actually random and is just a proof of concept. It starts a timer and flashes through a series of lights. If used in conjunction with DSI streamer have someone else record the data points.

## splice_model

splice_model assumes two things: each .csv file coming in is of one class (eg. only flashing lights or only sounds) and assumes that there is 1 comment that is around when the action occurs. It then takes a bit of time before and after the splice and tries to do machine learning on the splices. Better used with data coming from rand_flashes as the human operator of the DSI streamer cannot really comment just before and after the data point.

## two_splice_model

two_splice_model assumes two things: each .csv file coming in is of one class (eg. only flashing lights or only sounds) and assumes all data coming in is coming in from dsi_stream_flash_lights. It then tries to find a distiction bewteen the commented data and the data between. Currently does nothing and the machine learning model you choose must be manually chosen from matlab's Apps section.

## License
[MIT](https://choosealicense.com/licenses/mit/)
