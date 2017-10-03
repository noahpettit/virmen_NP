function vr = initDAQ(vr)
% Start the DAQ acquisition
if ~vr.debugMode
    
    daqreset; %reset DAQ in case it's still in use by a previous Matlab program
    
    % add analog input channels (ball movement)
    vr.ai = daq.createSession('ni');
    vr.ai.addAnalogInputChannel(vr.session.dev,vr.session.movementInput,'Voltage','singleEnded');
    vr.ai.Rate = 1e3;
    vr.ai.NotifyWhenDataAvailableExceeds=10;% changed this to 10 to try to get faster response - 50 ms seems like a long time
    vr.ai.IsContinuous=1;
    vr.ai.addlistener('DataAvailable', @avgMvData);
    
    % now add the digital input channels (lick data)
    vr.di = daq.createSession('ni');
    vr.di.addDigitalChannel(vr.session.dev,vr.session.lickCh,'InputOnly');
    vr.di.Rate = 1e3;
    vr.di.IsContinuous=1;
    vr.di.NotifyWhenDataAvailableExceeds=10;% every 10 ms average lick data
    vr.di.addlistener('DataAvailable', @avgLickData);
    
    % now add analog output channels (reward)
    vr.ao = daq.createSession('ni');
    vr.ao.addAnalogOutputChannel(vr.session.dev,vr.session.rewardCh,'Voltage','singleEnded');
    vr.ao.Rate = 1e3;

    % now add digital output channels (air puff)
    vr.do = daq.createSession('ni');
    vr.do.addDigitalChannel(vr.session.dev,vr.session.airPuffCh,'OutputOnly');
    vr.do.Rate = 1e3;    
    
    % add analog output for sync signal
    if ~isempty(vr.session.analogSyncCh)
    vr.ao = daq.createSession('ni');
    vr.ao.addAnalogOutputChannel(vr.session.dev,vr.session.analogSyncCh,'Voltage');
    vr.ao.Rate = 1e4;
    end
    
    if ~isempty(vr.session.digitalSyncCh)
        vr.di.addDigitalChannel(vr.session.dev,vr.session.digitalSyncCh,'Voltage','OutputOnly');
    end
    
    startBackground(vr.ai),
    startBackground(vr.di);
    startBackground(vr.ao);
    startbackground(vr.do);
    pause(1e-2),
    
    keyboard;

end

end

function avgMvData(src,event)
    global mvData
    mvData = mean(event.Data,1);
end

function avgLickData(src,event)
    global lickData
    lickData = mean(event.Data,1);
end
