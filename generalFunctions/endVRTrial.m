function vr = endVRTrial(vr,rewarded)

if rewarded
    vr = giveReward(vr,1);
    vr.numRewards = vr.numRewards + 1;
    vr.itiDur = vr.itiCorrect;
else
    vr.itiDur = vr.itiMiss;
end

vr.worlds{vr.currentWorld}.surface.visible(:) = 0;
vr.itiStartTime = tic;
vr.inITI = 1;
vr.numTrials = vr.numTrials + 1;

%save trial data
vr = saveTrialData(vr);