function vr = waitForNextTrial(vr)

if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    if vr.itiTime > vr.itiDur
        if ~vr.debugMode
            isMouseStill = norm(vr.velocity) < vr.mvThresh;
        else
            isMouseStill = 1;
        end
        if isMouseStill
            vr.inITI = 0;
            vr = chooseNextWorld(vr);
            vr.position = vr.worlds{vr.currentWorld}.startLocation;
            vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
            vr.dp = 0;
            vr.firstTurn = 1;
            vr.trialTimer = tic;
            vr.trialStartTime = rem(now,1);
        end
    end
end