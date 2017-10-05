function [vr] = giveReward(vr,amount,varargin)
% reward delivery function
switch nargin
    case 2
        units = 'uL'; %default. other valid unit is 'mL','pulseDur'
    case 3
        units = varargin{1};
end

if ischar(vr)
    % then we are in manual or calibration mode, and vr specifies the name of
    % the rig
    daqreset;
    rig = vr;
    ops = getRigSettings(rig);
    vr = [];
    % now add analog output channels (reward)
    vr.ao = daq.createSession('ni');
    vr.ao.addAnalogOutputChannel(ops.dev,ops.rewardCh,'Voltage');
    vr.ao.Rate = 1e3;
    vr.session.rig = rig;
    vr.reward = 0;
end

ops = getRigSettings(vr.session.rig);

switch units
    case 'uL' % default
        pulseDur = interp1(ops.uL,ops.pulseDur,amount,'linear','extrap'); % pulse duration
    case 'mL'
        pulseDur = interp1(ops.uL,ops.pulseDur,amount*1000,'linear','extrap'); % pulse duration
    case 'pulseDur'
        pulseDur = amount;
end

pulsedata=5.0*ones(round(vr.ao.Rate*pulseDur),1); %5V amplitude
pulsedata(end)=0; %reset to 0V at last time point

vr.ao.queueOutputData(pulsedata);
startBackground(vr.ao);

vr.reward = vr.reward + amount;


end