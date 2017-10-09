function vr = outputSyncPulse(vr)

if ~isfield(vr,'ops')
    vr.ops = getRigSettings();
end

if ~isfield(vr, 'analogSyncPulse')
    vr.analogSyncPulse = randi([-10 10]);
end

if ~isfield(vr, 'digitalSyncPulse')
    vr.digitalSyncPulse = 0;
end

analogSync = -10:10;
analogSync(analogSync==vr.analogSyncPulse) = [];
vr.analogSyncPulse = analogSync(randi([1 20]));
vr.digitalSyncPulse = ~vr.digitalSyncPulse;


if vr.ops.outputSyncSignal == 1
    % analog output random integer between 
    outputSingleScan(vr.ao,[vr.analogSyncPulse vr.digitalSyncPulse]);
%     % digital signal
%     outputSingleScan(vr.do(3),vr.digitalSyncPulse);
end
    
    