function [vr] = giveAirpuff(vr,pulseDur)
% reward delivery function
tic;
if ischar(vr)
    % then we are in manual or test mode, and vr specifies the name of
    % the rig
    daqreset;
    rig = vr;
    ops = getRigSettings(rig);
    vr = [];
    % now add analog output channels (reward)
    % this section mimicks initDAQ
    vr.do = daq.createSession('ni');
    vr.do.addDigitalChannel(ops.dev,ops.airPuffCh,'OutputOnly');
%     vr.do.addClockConnection(ops.doClock{1},ops.doClock{2},'ScanClock');
    vr.session.rig = rig;
    vr.reward = 0;
end

% use timer to continue running virmen. You lose a frame but I dont know
% how else to do it
t = timer;
t.UserData = vr.do;
t.StartFcn = @(src,event) outputSingleScan(src.UserData,1);
t.TimerFcn = @(src,event) outputSingleScan(src.UserData,0);
t.StopFcn = @(src,event) delete(src);
t.ExecutionMode = 'singleShot';
t.StartDelay = pulseDur;
t.BusyMode = 'queue';

start(t)
toc;

end