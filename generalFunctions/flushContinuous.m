function flushContinuous(flushTime)

if nargin<1
    flushTime = 4;
end

% Create daq session:
sn = daq.createSession('ni');
sn.Rate = 50000;
sn.addAnalogOutputChannel('dev1', 0, 'Voltage');

% Make sure buttons are released:
% while KbCheck
% end

disp('IS THE SPOUT OVER THE WASTE CONTAINER?');
pause(2)
fprintf('%s Flushing...\n', datestr(now));

sn.outputSingleScan([5]);
tStart = tic;
while toc(tStart) < flushTime
    pause(0.1)
end

sn.outputSingleScan([0]);
toc(tStart)