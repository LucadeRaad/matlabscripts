clc
clear

delete(timerfind)

f = figure;

tmr = timer('ExecutionMode', 'FixedRate', 'Period', 5, 'TimerFcn', @(~,~)timer_call_back());

tmr.TimerFcn = @(~,~)timer_call_back();

tmr.StartDelay = 3;

start(tmr);

function timer_call_back() 
    rectangle('FaceColor', 'r')
    pause(.25)

    rectangle('FaceColor', 'b')
    pause(.25)

    rectangle('FaceColor', 'c')
    pause(.25)

    rectangle('FaceColor', 'g')
    pause(.25)

    rectangle('FaceColor', 'y')
    pause(.25)


    rectangle('FaceColor', [0 0 0])
end