function code = linearTrack
% Linear Track   Code for the ViRMEn experiment Linear Track.
%   code = Linear Track   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = false;
vr = makeDirSNC(vr);

% set parameters
vr.friction = 0.25;
vr.itiCorrect = 2;
vr.itiMiss = 4;
vr.mazeLength = eval(vr.exper.variables.floorLength);
vr.nWorlds = length(vr.worlds);

vr = initTextboxes(vr);
vr = initDAQ(vr);
vr = initCounters(vr);
vr.currentWorld = randi(vr.nWorlds);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% collect behavior data
vr = collectBehaviorIter(vr);

% Decrease velocity by friction coefficient (can be zero)
vr = adjustFriction(vr);

% check for reward and deliver if in reward position
if vr.inITI == 0 && vr.position(2) > vr.mazeLength;
    vr.isReward = true;
    vr.behaviorData(9,vr.trialIterations) = 1;
    vr = endVRTrial(vr,vr.isReward);
else
    vr.isReward = false;
    vr.behaviorData(9,vr.trialIterations) = 0;
end

% Check to see if ITI has elapsed, and restart trial if it has
vr = waitForNextTrial(vr);

% Update Textboxes
vr = updateTextDisplay(vr);

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if ~vr.debugMode
    stop(vr.ai),
    delete(vr.ai),
    delete(vr.ao),
end
vr = collectTrialData(vr);