function vr = initCounters(vr)

vr.inITI = 0;
vr.numTrials = 0;
vr.numRewards = 0;
vr.dp = 0;
vr.isReward = 0;
vr.trialIterations = 0;
vr.sessionStartTime = tic;
vr.behaviorData = nan(9,1e4);