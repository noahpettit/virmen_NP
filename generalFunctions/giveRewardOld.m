function [vr] = giveRewardOld(vr,nRew)
%giveReward Function which delivers rewards using the Master-8 system
%(instantaneous pulses)
%   nRew - number of rewards to deliver

sinDur = .06*(0.8/0.5); %Calibrated to give 4ul for single reward, SNC 4/3/15

if ~vr.debugMode
    actualRate = vr.ao.Rate; %get sample rate
    pulselength=round(actualRate*sinDur*nRew); %find duration (rate*duration in seconds *numRew)
    pulsedata=5.0*ones(pulselength,1); %5V amplitude
    pulsedata(pulselength)=0; %reset to 0V at last time point
    vr.ao.queueOutputData(pulsedata);
    startForeground(vr.ao);
end

end

