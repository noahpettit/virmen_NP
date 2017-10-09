function vr = initDAQ(vr)
% Start the DAQ acquisition
    if ~isfield(vr,'session');
        vr.session = [];
    end
    if ~isfield(vr.session, 'rig');
        ops = getRigSettings; % attempt to find automatically
        vr.session.rig = ops.rigName;
    else
        ops = getRigSettings(vr.session.rig);
    end
    
    daqreset; %reset DAQ in case it's still in use by a previous Matlab program
    
    % PUT ALL CHANNELS IN SAME SESSION TO ALLOW CLOCKED DIO
    % add analog input channels (ball movement)
    vr.ai = daq.createSession('ni');
    ch = vr.ai.addAnalogInputChannel(ops.dev,ops.movementCh{1},'Voltage');
    ch.TerminalConfig = 'SingleEnded';
    ch = vr.ai.addAnalogInputChannel(ops.dev,ops.movementCh{2},'Voltage');
    ch.TerminalConfig = 'SingleEnded';
    ch = vr.ai.addAnalogInputChannel(ops.dev,ops.movementCh{3},'Voltage');
    ch.TerminalConfig = 'SingleEnded';

    % add notifier?
    vr.ai.Rate = (1e3);
    vr.ai.NotifyWhenDataAvailableExceeds=50;
    vr.ai.IsContinuous=1;
    vr.aiListener = vr.ai.addlistener('DataAvailable', @avgMvData);
    
    % now add the counter input channels (lick data)
    vr.ci = daq.createSession('ni');
    vr.ci.addCounterInputChannel(ops.dev, ops.lickCh, 'EdgeCount');
    
    % now add digital output channels (reward)
    vr.do(1) = daq.createSession('ni');
    vr.do(1).addDigitalChannel(ops.dev,ops.rewardCh,'OutputOnly');
    vr.do(1).Rate = 1e2;
    % now add digital output channels (air puff)
    vr.do(2) = daq.createSession('ni');
    vr.do(2).addDigitalChannel(ops.dev,ops.airPuffCh,'OutputOnly');
    vr.do(2).Rate = 1e2;    
    
    % add analog output for sync signal
    if ~isempty(ops.analogSyncCh)
        vr.ao = daq.createSession('ni');
        vr.ao.addAnalogOutputChannel(ops.dev,ops.analogSyncCh,'Voltage');
        vr.ao.addDigitalChannel(ops.dev,ops.digitalSyncCh,'OutputOnly');
        vr.ao.Rate = 1e3;
    end
    
%     if ~isempty(ops.digitalSyncCh)
%         vr.do(3) =  daq.createSession('ni');
%         vr.do(3).addDigitalChannel(ops.dev,ops.digitalSyncCh,'OutputOnly');
%     end
    vr.ops = ops;
    startBackground(vr.ai);
    pause(1e-2);
end

function avgMvData(src,event)
    global mvData
    mvData = mean(event.Data,1);
end
