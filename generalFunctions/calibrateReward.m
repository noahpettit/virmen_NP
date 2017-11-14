function [] = calibrateReward(varargin)
% arguments are: rig, pulseDur, pulseDelay, nPulse;
switch nargin
    case 1
        rig = varargin{1};
        pulseDur = 1;
        pulseDelay = 0.1;
        nPulse = 1;
    case 2
        rig = varargin{1};
        pulseDur = varargin{2};
        pulseDelay = 0.1;
        nPulse = 1;
    case 3
        rig = varargin{1};
        pulseDur = varargin{2};
        pulseDelay = varargin{3};
        nPulse = 1;
    case 4
        rig = varargin{1};
        pulseDur = varargin{2};
        pulseDelay = varargin{3};
        nPulse = varargin{3};
end

% reward delivery function
if isempty(pulseDelay)
    pulseDelay = 0.1; % I think this should be long enough to settle
end
pulseDelay(pulseDelay<0.05) = 0.05;

h = msgbox('Calibrating... press OK to stop calibration');
for k = 1:nPulse
    giveReward(rig,pulseDur,'pulseDur');
    pause(pulseDur+pulseDelay);
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