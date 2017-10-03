function [vr] = giveReward(vr,uL)
% reward delivery function

%   uL - amount of reward to deliver in uL
if ischar(vr)
    % then we are in calibration mode, and vr specifies the name of
    % the rig
    rig = vr;
    ops = getRigDAQSettings(vr);
    vr = [];
    % now add analog output channels (reward)
    vr.ao = daq.createSession('ni');
    vr.ao.addAnalogOutputChannel(ops.dev,ops.rewardCh,'Voltage','singleEnded');
    vr.ao.Rate = 1e3;
    vr.session.rig = rig;
    vr.reward = 0;
end

ops = getRigSettings(vr.session.rig);

pulseDur = interp1(ops.uL,ops.sinDur,uL); % pulse duration

pulsedata=5.0*ones(round(vr.ao.Rate*pulseDur),1); %5V amplitude
pulsedata(end)=0; %reset to 0V at last time point
vr.ao.queueOutputData(pulsedata);
startForeground(vr.ao);

vr.reward = vr.reward + uL;

end