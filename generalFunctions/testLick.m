function testLick()

global lickData
% now add the digital input channels (lick data)
daqreset;
ops = getRigSettings('loki');
vr.di = daq.createSession('ni');
vr.di.addDigitalChannel(ops.dev,ops.lickCh,'InputOnly');
vr.di.Rate = 1e3;
vr.di.IsContinuous=1;
vr.di.NotifyWhenDataAvailableExceeds=10;% every 10 ms average lick data
vr.di.addlistener('DataAvailable', @avgLickData);


startBackground(vr.di);
pause(1e-2),

figure; hold on
p = plot([]); hold on
runningLick = zeros(5000,1);
while true
    runningLick(:) = [runningLick(2:end); lickData];
    set(p,'xdata',1:length(runningLick),'ydata',runningLick);
end


end


function avgLickData(src,event)
    global lickData
    lickData = mean(event.Data,1)>0.1; % needs to be licking more than 10% of the time or it does not count
end

