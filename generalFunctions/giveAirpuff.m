function [vr] = giveAirpuff(vr,pulseDur)
% reward delivery function
if ischar(vr)
    % then we are in manual or test mode, and vr specifies the name of
    % the rig
    daqreset;
    rig = vr;
    ops = getRigSettings;
    vr = [];
    % now add analog output channels (reward)
    % this section mimicks initDAQ
    
    % is there any reason you can't just put "initDAQ.m" here?
    vr.do(1) = daq.createSession('ni');
    vr.do(2) = daq.createSession('ni');
    vr.do(2).addDigitalChannel(ops.dev,ops.airPuffCh,'OutputOnly');
    
    vr.session.rig = rig;
    vr.reward = 0;
    vr.punishment = 0;
end

% check to see if timer has been initialized
if ~isfield(vr, 'timers');
    vr.timers = [];
end

if ~isfield(vr,'punishment');
    vr.punishment = 0;
end

% check to see if airpuff has been initialized
if ~isfield(vr.timers, 'airpuff');
    t = timer;
    t.UserData = vr.do(2);
    t.StartFcn = @(src,event) outputSingleScan(src.UserData,1);
    t.TimerFcn = @(src,event) outputSingleScan(src.UserData,0);
    t.ExecutionMode = 'singleShot';
    t.BusyMode = 'queue';
    vr.timers.airpuff = t;
end

% use timer to continue running virmen. You lose a frame but I dont know
% how else to do it

vr.timers.airpuff.StartDelay = pulseDur;
if strcmp(vr.timers.airpuff.Running,'off');
start(vr.timers.airpuff);
end

vr.punishment = vr.punishment+pulseDur;

end