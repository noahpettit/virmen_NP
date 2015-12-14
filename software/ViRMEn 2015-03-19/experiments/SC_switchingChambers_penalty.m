function code = SC_switchingChambers_penalty
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
vr = makeDirSNC(vr);

% set parameters
vr.rewardDelay = 1;
vr.mvThresh = eval(vr.exper.variables.mvThresh);
vr.friction = 0.25;
vr.itiCorrect = eval(vr.exper.variables.itiCorrect);
vr.itiMissBase = eval(vr.exper.variables.itiMissBase);
vr.penaltyITI = 0;
vr.penaltyProb = eval(vr.exper.variables.penaltyProb);
floorLength = eval(vr.exper.variables.floorLength);
funnelLength = eval(vr.exper.variables.funnelLength);
vr.rewardLength = 5 + floorLength + funnelLength;
vr.nWorlds = length(vr.worlds);
vr.sessionSwitchpoints = eval(vr.exper.variables.switches);

vr = initTextboxes(vr);
vr = initDAQ(vr);
vr = initCounters(vr);

nBlocks = length(vr.sessionSwitchpoints)+1;
initBlock = 2 - mod(vr.mouseNum,2);
blockIDs = mod(initBlock:initBlock+nBlocks-1,2) + 1;
blockMazes = [1 2;3 4];
for nBlock = 1:nBlocks
    vr.contingentBlocks(nBlock,:) = blockMazes(blockIDs(nBlock),:);
end

worldChoice = randi(size(vr.contingentBlocks,2));
vr.currentWorld = vr.contingentBlocks(1,worldChoice);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% collect behavior data
vr = collectBehaviorIter(vr);

% Decrease velocity by friction coefficient (can be zero)
vr = adjustFriction(vr);

% check for trial-terminating position and deliver reward
if vr.inITI == 0 && (vr.position(2) > vr.rewardLength);
    % Disable movement
    vr.dp = 0*vr.dp;
    % Enforce Reward Delay
    if ~vr.inRewardZone
        vr.rewStartTime = tic;
        vr.inRewardZone = 1;
    end
    vr.rewDelayTime = toc(vr.rewStartTime);    
    if vr.rewDelayTime > vr.rewardDelay
        % Check reward condition
        rightWorld = vr.currentWorld==1 || vr.currentWorld==4;
        rightArm = vr.position(1) > 0;
        if ~abs(rightWorld-rightArm)
            %deliver reward if appropriate
            vr.behaviorData(9,vr.trialIterations) = 1;
            vr.numRewards = vr.numRewards + 1;
            vr = giveReward(vr,1);
            vr.itiDur = vr.itiCorrect;
            vr.wrongStreak = 0;
        else
            % update wrongStreak counter if incorrect
            vr.behaviorData(9,vr.trialIterations) = 0;
            vr.itiMiss = vr.itiMissBase + vr.penaltyITI*vr.wrongStreak;
            vr.itiDur = vr.itiMiss;
            vr.wrongStreak = vr.wrongStreak + 1;
        end
        % End trial and update switchBlock / worlds info
        vr = endVRTrial(vr);
        switchBlock = 1 + find(vr.numTrials >= vr.sessionSwitchpoints,1,'last');
        if isempty(switchBlock)
            switchBlock = 1;
        end
        vr.blockWorlds = vr.contingentBlocks(switchBlock,:);
    else
        vr.behaviorData(9,vr.trialIterations) = 0;
        vr.behaviorData(8,vr.trialIterations) = -1;
    end
else
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
[vr,sessionData] = collectTrialData(vr);
vr = makeSwitchingSessionFigs(vr,sessionData, vr.sessionSwitchpoints);