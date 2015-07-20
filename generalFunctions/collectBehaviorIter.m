function vr = collectBehaviorIter(vr)

thisIter(1) = vr.currentWorld;
thisIter(2:4) = vr.velocity([1,2,4]);
thisIter(5:7) = vr.position([1,2,4]);
thisIter(8) = vr.inITI;
% 9 is reserved for the reward
thisIter(10) = vr.dt;

vr.trialIterations = vr.trialIterations + 1;
vr.behaviorData([1:8,10],vr.trialIterations) = thisIter([1:8,10])';