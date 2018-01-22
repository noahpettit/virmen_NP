function vr = commonInit(vr)
% contains common initializations across mazes & defaults
global lickCount

% get rid of all the red in the world
for k = 1:length(vr.worlds)
    vr.worlds{k}.surface.colors(1,:)=0;
end

vr.rawMovement = [];
vr.iN = 0;
vr.tN = 1;
vr.isITI = 0;
vr.reward = 0;
vr.isLick = 0;
vr.isVisible = 1;
vr.isFrozen = 0;
vr.isBlackout = 0;
vr.isPunishment = 0;
vr.binsEvaluated = [];
vr.manualReward = 0;
vr.manualAirpuff = 0;

% set up the path
vr.ops = getRigSettings;
vr = initDAQ(vr);
vr = initPath(vr);
vr = initTextboxes(vr,16);

% initialize the first trial
vr.tN = 1;

vr.mazeEnded = 0;
vr.trialEnded = 0;

vr.trial(vr.tN).N = vr.tN;
vr.trial(vr.tN).start = now();
vr.position = vr.trial(vr.tN).startPosition;

%% set the new maze
vr.position = vr.trial(vr.tN).startPosition;
vr.currentWorld = vr.trial(vr.tN).type;

vr.worlds{vr.currentWorld} = loadVirmenWorld(vr.exper.worlds{vr.currentWorld});

for k =1:length(vr.worlds)
    vr.worlds{k}.surface.visible(:) = 1;
    vr.worlds{k}.surface.colors(1,:)=0;
end


vr.iN = 0;

vr.lastLickCount = lickCount;
vr.analogSyncPulse = 1;
vr.digitalSyncPulse = 0;
vr = outputSyncPulse(vr);
vr.rpm = 0;

vr.position = vr.trial(vr.tN).startPosition;
vr.currentWorld = vr.trial(vr.tN).type;
    
vr.worlds{vr.currentWorld} = loadVirmenWorld(vr.exper.worlds{vr.currentWorld});
    for k =1:length(vr.worlds)
        vr.worlds{k}.surface.visible(:) = 1;
        vr.worlds{k}.surface.colors(1,:)=0;
    end

vr = getGitHash(vr);
vr = saveSession(vr);
vr = saveVr(vr);

pause(0.1);

end