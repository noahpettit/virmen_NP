    % PUT ALL CHANNELS IN SAME SESSION TO ALLOW CLOCKED DIO
    % you dont want all to be in the same session, since you need to be
    % able to independently control 
    % can you input single scan while background is running?
    daqreset;
    % add analog input channels (ball movement)
    vr.daq = daq.createSession('ni');
%     vr.daq.addAnalogInputChannel('dev1','ai1:3','Voltage'); % this syntax
%     does not work!

    vr.daq.Rate = 1e3;
    
    vr.daq.addAnalogInputChannel('dev1','ai1','Voltage'); % this syntax
    vr.daq.addDigitalChannel('dev1','port0/line0','OutputOnly');
    vr.di.NotifyWhenDataAvailableExceeds=100;%
    vr.daq.addlistener('DataAvailable', @(x,y)x);
    % queue output channel
    %%
    tic;
    vr.daq.outputSingleScan(ones(1,1));
%     pause(1e-3);
%     startBackground(vr.daq);
    toc;
   %% 
    pause(0.1);
%     
    vr.daq.queueOutputData([1;1;1]);
    vr.daq.startBackground();
    
    %%
    
    % DO NOT USE NOTIFIER -> USE INPUT SINGLE SCAN
%     vr.daq.NotifyWhenDataAvailableExceeds=10;% changed this to 10 to try to get faster response - 50 ms seems like a long time
%     vr.daq.IsContinuous=1;
%     vr.daq.addlistener('DataAvailable', @avgMvData);
    
    % now add the digital input channels (lick data)
    vr.di = daq.createSession('ni');
    vr.di.addDigitalChannel(ops.dev,ops.lickCh,'InputOnly');
    vr.di.Rate = 1e3;
    vr.di.IsContinuous=1;
    vr.di.NotifyWhenDataAvailableExceeds=10;% every 10 ms average lick data
    vr.di.addlistener('DataAvailable', @avgLickData);
    
    % now add analog output channels (reward)
    vr.ao = daq.createSession('ni');
    vr.ao.addAnalogOutputChannel(ops.dev,ops.rewardCh,'Voltage','singleEnded');
    vr.ao.Rate = 1e3;

    % now add digital output channels (air puff)
    vr.do = daq.createSession('ni');
    vr.do.addDigitalChannel(ops.dev,ops.airPuffCh,'OutputOnly');
    vr.do.Rate = 1e3;    
    
    % add analog output for sync signal
    if ~isempty(ops.analogSyncCh)
    vr.ao = daq.createSession('ni');
    vr.ao.addAnalogOutputChannel(ops.dev,ops.analogSyncCh,'Voltage');
    vr.ao.Rate = 1e4;
    end
    
    if ~isempty(ops.digitalSyncCh)
        vr.di.addDigitalChannel(ops.dev,ops.digitalSyncCh,'Voltage','OutputOnly');
    end
    
    startBackground(vr.ai),
    startBackground(vr.di);
    pause(1e-2),
