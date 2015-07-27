function vr = endVRTrial(vr)

vr.worlds{vr.currentWorld}.surface.visible(:) = 0;
vr.itiStartTime = tic;
vr.inITI = 1;
vr.numTrials = vr.numTrials + 1;

%save trial data
vr = saveTrialData(vr);