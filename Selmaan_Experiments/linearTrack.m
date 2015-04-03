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

vr.debugMode = true;
vr.mouseNum = 99;

% set parameters
vr.friction = 0.25;
vr.conds = {'Linear Track'};
vr.itiCorrect = 2;
vr.itiMiss = 4;
vr.rewardDuration = 1e-1;
warning('Need to Measure true reward duration!!!')
vr.mazeLength = eval(vr.exper.variables.floorLength);
pause(1),

%vr = initializePathVIRMEN(vr); %this function is still messy...
vr = initTextboxes(vr);
vr = initDAQ(vr);
vr = initCounters(vr);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% Decrease velocity by friction coefficient (can be zero)
if vr.collision
    vr.dp(1:2) = vr.dp(1:2) * (1-vr.friction);
end

% check for reward and deliver if in reward position
if vr.inITI == 0 && vr.position(2) > vr.mazeLength;
    vr = giveReward(vr,1);
    vr.itiDur = vr.itiCorrect;
    vr.numRewards = vr.numRewards + 1;
    vr.worlds{vr.currentWorld}.surface.visible(:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    vr.numTrials = vr.numTrials + 1;
    vr.cellWrite = true;
else
    vr.isReward = 0;
end

% Check to see if ITI has elapsed, and restart trial if it has
if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    if vr.itiTime > vr.itiDur
        vr.inITI = 0;
        vr.position = vr.worlds{vr.currentWorld}.startLocation;
        vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
        vr.dp = 0;
        vr.trialTimer = tic;
        vr.trialStartTime = rem(now,1);
    end
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
%commonTerminationVIRMEN(vr);