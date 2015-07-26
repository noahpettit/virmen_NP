function vr = collectBehaviorIter(vr)

thisIter(1) = vr.currentWorld;
thisIter(2:4) = vr.dp([1,2,4]);
thisIter(5:7) = vr.position([1,2,4]);
thisIter(8) = vr.inITI;

vr.trialIterations = vr.trialIterations + 1;
vr.behaviorData(1:8,vr.trialIterations) = thisIter';