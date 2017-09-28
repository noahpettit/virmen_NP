function vr = initDAQ(vr)
% Start the DAQ acquisition
if ~vr.debugMode
    daqreset; %reset DAQ in case it's still in use by a previous Matlab program
    vr.ai = daq.createSession('ni');
    vr.ai.addAnalogInputChannel('dev1','ai1:3','Voltage','singleEnded');
    vr.ai.Rate = 1e3;
    vr.ai.NotifyWhenDataAvailableExceeds=50;
    vr.ai.IsContinuous=1;
    vr.aiListener = vr.ai.addlistener('DataAvailable', @avgMvData);
    % now add the digital input
    vr.di = daq.createSession('ni');
    vr.di.addDigitalChannel('dev1','p0.0','Voltage');
    
    % now add the digital and analog output
    
    
    startBackground(vr.ai),
    pause(1e-2),
    
    % add analog output for sync signal
    vr.ao = daq.createSession('ni');
    vr.ao.addAnalogOutputChannel('dev1','ao0','Voltage');
    vr.ao.Rate = 1e4;
end

end

function avgMvData(src,event)
    global mvData
    mvData = mean(event.Data,1);
end