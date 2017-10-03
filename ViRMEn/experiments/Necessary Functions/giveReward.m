function [vr] = giveReward(vr,uL,sinDur)
%giveReward Function which delivers rewards using the Master-8 system
%(instantaneous pulses)
%   nRew - number of rewards to deliver
calibrationMode = 0;
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
end

sinDur = .06;

if ~calibrationMode
    actualRate = vr.ao.Rate; %get sample rate
    pulselength=round(actualRate*sinDur*nRew*(targetRewardSize/ops.calibratedRewardSize)); %find duration (rate*duration in seconds *numRew)
    pulsedata=5.0*ones(pulselength,1); %5V amplitude
    pulsedata(pulselength)=0; %reset to 0V at last time point
    vr.ao.queueOutputData(pulsedata);
    startForeground(vr.ao);
else


vr.reward = nRew.*rewardSize;

end