function vr = waitForNextTrial(vr,worlds)

if ~exist('worlds','var')
    worlds = [];
end

if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    if vr.itiTime > vr.itiDur
        vr.inITI = 0;
        vr = chooseNextWorld(vr,worlds);
        vr.position = vr.worlds{vr.currentWorld}.startLocation;
        vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
        vr.dp = 0;
        vr.firstTurn = 1;
        vr.trialTimer = tic;
        vr.trialStartTime = rem(now,1);
    end
end