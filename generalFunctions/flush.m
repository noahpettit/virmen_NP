function flush(ml)
% Flush out the tubing (faster than using the REWARD function).

if nargin<1
    ml = 20;
end
cleanupObj = onCleanup(@daq.reset);

% Create daq session:
sn = daq.createSession('ni');
sn.Rate = 1000;
sn.addAnalogOutputChannel(taskSession.getLocalVar('daqDev'), taskSession.getLocalVar('daqOutChannel'), 'Voltage');

% Create signal:
pauseTime = 0.5;
openTime = 0.2; % Approx. releases 40 ul.
mlPerPulse = 0.04;
signal = [0; ones(sn.Rate*openTime, 1)*5; 0];
signal(:, 2) = 0;

% Make sure buttons are released:
while KbCheck
end

disp('IS THE SPOUT OVER THE WASTE CONTAINER?');

nFlush = 0;
while ~KbCheck && ml > 0
    pause(pauseTime)
    nFlush = nFlush + 1;
    ml = ml - mlPerPulse;
    if ~sn.IsRunning
        sn.queueOutputData(signal);
        sn.startForeground;
    end
    fprintf('%s ~%1.1f ml flushed...\n', datestr(now), nFlush*mlPerPulse);
end

sn.outputSingleScan([0 0]);
sn.release;