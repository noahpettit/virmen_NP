function vr = saveTrialData(vr)

nIters = vr.trialIterations;
behavData = vr.behaviorData(:,1:nIters);
behavData(end+1,:) = vr.currentWorld;
trialName = sprintf('Trial#%03.0f',vr.numTrials);
trialFileName = fullfile(vr.fullPath,trialName);
save(trialFileName,'behavData')

% Reset trial iteration counter and behavior data matrix
vr.trialIterations = 0;
vr.behaviorData = nan(9,1e4);