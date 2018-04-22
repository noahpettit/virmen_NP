function [vr] = giveReward(vr,amount,varargin)
% reward delivery function
switch nargin        
    case 2
        units = 'uL'; %default. other valid unit is 'mL','pulseDur'
    case 3
        units = varargin{1};
end

% reward delivery function
if ischar(vr) || isempty(vr)
    % then we are in manual or test mode, and vr specifies the name of
    % the rig
    daqreset;
    ops = getRigSettings(vr);
    vr = [];
    % now add analog output channels (reward)
    % this section mimicks initDAQ
    vr.do(1) = daq.createSession('ni');
    vr.do(1).addDigitalChannel(ops.dev,ops.rewardCh,'OutputOnly');
%     vr.do.addClockConnection(ops.doClock{1},ops.doClock{2},'ScanClock');
    vr.session.rig = ops.rigName;
end
ops = getRigSettings(vr.session.rig);
% check to see if timer has been initialized
if ~isfield(vr, 'timers')
    vr.timers = [];
end

% check to see if airpuff has been initialized
if ~isfield(vr.timers, 'reward')
    t = timer;
    t.UserData = vr.do(1);
    t.StartFcn = @(src,event) outputSingleScan(src.UserData,1);
    t.TimerFcn = @(src,event) outputSingleScan(src.UserData,0);
    t.ExecutionMode = 'singleShot';
    t.BusyMode = 'queue';
    vr.timers.reward = t;
end



switch units
    case 'uL' % default
        pulseDur = interp1(ops.uL,ops.pulseDur,amount,'linear','extrap'); % pulse duration
    case 'mL'
        pulseDur = interp1(ops.uL,ops.pulseDur,amount*1000,'linear','extrap'); % pulse duration
    case 'pulseDur'
        pulseDur = amount;
end

% use timer to continue running virmen.
vr.timers.reward.StartDelay = round(pulseDur.*1000)/1000;
if strcmp(vr.timers.reward.Running,'off')
start(vr.timers.reward);
end


% pulsedata=5.0*ones(round(vr.ao.Rate*pulseDur),1); %5V amplitude
% pulsedata(end)=0; %reset to 0V at last time point

% vr.ao.queueOutputData(pulsedata);
% startBackground(vr.ao);
if ~isfield(vr,'reward');
    vr.reward = 0;
end

vr.reward = vr.reward + amount;


end