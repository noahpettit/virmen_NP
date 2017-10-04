function [] = calibrateReward(rig,pulseDur,pulseDelay,nPulse)
% reward delivery function
if isempty(pulseDelay)
    pulseDelay = pulseDur + 0.1; % I think this should be long enough to settle
end

h = msgbox('Calibrating... press OK to stop calibration');
for k = 1:nPulse
    giveReward(rig,pulseDur,'pulseDur');
    pause(pulseDelay);
    disp([num2str(k) ' rewards of ' num2str(pulseDur) ' given']);
    if ~ishandle(h)
        disp('aborted calibration');
        break
    end  
end
if ishandle(h)
    close(h);
end
end