function code = basicT_4conditions
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
vr.sessionSwitchpoint = 100;
vr.itiCorrect = 2;
vr.itiMiss = 4;
vr.armLength = eval(vr.exper.variables.armLength);
vr.nWorlds = length(vr.worlds);

vr = initTextboxes(vr);
vr = initDAQ(vr);
vr = initCounters(vr);
vr.currentWorld = randi(vr.nWorlds/2);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% collect behavior data
vr = collectBehaviorIter(vr);

% Decrease velocity by friction coefficient (can be zero)
vr = adjustFriction(vr);

% check for reward and deliver if in reward position
if vr.inITI == 0 && abs(vr.position(1)) > vr.armLength/2;
    rightWorld = vr.currentWorld==1 || vr.currentWorld==4;
    rightArm = vr.position(1) > 0;
    if ~abs(rightWorld-rightArm)
        vr.isReward = true;
        vr.behaviorData(9,vr.trialIterations) = 1;
        vr = endVRTrial(vr,vr.isReward);
    else
        vr.isReward = false;
        vr.behaviorData(9,vr.trialIterations) = 0;
        vr = endVRTrial(vr,vr.isReward);
    end
else
    vr.isReward = false;
    vr.behaviorData(9,vr.trialIterations) = 0;
end

% Check to see if ITI has elapsed, and restart trial if it has
if vr.numTrials >= vr.sessionSwitchpoint
    worlds = [3,4];
else
    worlds = [1,2];
end
vr = waitForNextTrial(vr,worlds);

% Update Textboxes
vr = updateTextDisplay(vr);

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
[vr,sessionData] = collectTrialData(vr);
vr = makeSwitchingSessionFigs(vr,sessionData);

