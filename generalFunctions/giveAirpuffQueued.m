function [vr] = giveAirpuffQueued(vr,pulseDur)
% reward delivery function
tic;
if ischar(vr)
    % then we are in manual or test mode, and vr specifies the name of
    % the rig
    daqreset;
    rig = vr;
    ops = getRigSettings(rig);
    vr = [];
    % now add analog output channels (reward)
    % this section mimicks initDAQ
    vr.do = daq.createSession('ni');
    vr.do.addAnalogInputChannel(ops.dev,'ai8','Voltage');
    vr.do.addDigitalChannel(ops.dev,ops.airPuffCh,'OutputOnly');
%     vr.do.NotifyWhenDataAvailableExceeds=100;%
%     vr.do.addlistener('DataAvailable', @(x,y)x);
    vr.do.Rate = 1e3;
%     vr.do.addClockConnection(ops.doClock{1},ops.doClock{2},'ScanClock');
    vr.session.rig = rig;
    vr.reward = 0;
end

% use timer to continue running virmen. You lose a frame but I dont know
% how else to do it
vr.do.queueOutputData([ones(pulseDur*vr.do.Rate,1);0]);
% vr.do.NotifyWhenDataAvailableExceeds=100;%
vr.do.addlistener('DataAvailable', @(x,y)x);
startBackground(vr.do);

end