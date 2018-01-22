function code = linearTrack_preTrain
% linearTrack_v3   Code for the ViRMEn experiment linearTrack_v3.
%   code = linearTrack_v3   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
%% TODO:
% calibrate virmen unit to cm conversion

% set whether in debug mode:
vr.debugMode = 0;
vr.imaging = 1;
vr.drawText = 1;
daqreset;
%
ops = getRigSettings;

% initialize vr.session
vr.session = [];
vr.mouseID = makeMouseID_virmen(vr);
vr.session = struct(...
    ...% default entries
    'sessionID', [vr.mouseID '_' datestr(now,'YYmmDD_hhMMss')], ...
    'rig',ops.rigName,...
    'startTime',now(),...
    'experimentCode', mfilename,... % change this to get the actual maze name from vr
    ... % custom fields
    'trialMaxDuration', 120, ... % timeout countdown clock in seconds
    'targetRPM',4, ...
    'rewardSize',2, ...
    'airPuffLength', 0.2 ...
    ); 

% names of variables (fields in vr) that will be saved on each iteration,
% followed by the number of elements in each of those.
% Each variable will be flattened and saved in a
% binary file in the order specified in saveVar.
vr.saveOnIter = {...
    'rawMovement',3;...
    'position',4;...
    'velocity',4;...
    'iN',1;...
    'tN',1;...
    'isITI',1;...
    'reward',1;...
    'isLick',1;...
    'isVisible',1;...
    'dt',1;...
    ... % custom fields
    'punishment',1;...
    'isFrozen',1;... % whether the world is forzen
    'trialEnded',1;...
    'mazeEnded',1;...
    'isBlackout',1;...
    'analogSyncPulse',1;...
    'digitalSyncPulse',1 ...
};
    
% initialize vr.trialInfo
vr.trial(1:5000,1) = struct(...
    ...% the standard fields 
    'N',0,...
    'duration',0,...
    'totalReward',0,...
    'isCorrect',0,...
    'type',eval(vr.exper.variables.startingCondition),... % in this maze the trial type and the world are the same? This generates some redundancy and confusion
    'start',0,...
...%'world',vr.currentWorld,... % FOR NOW ASSUMING THAT WORLD IS "TYPE". I don't really see any major disadvantage to this at the moment (except that loading the world is time intensive)
    ...% general fields to all mazes:
    'startPosition', [0 eval(vr.exper.variables.startY) eval(vr.exper.variables.mouseHeight) pi/2],... % position vector [X Y Z theta] defining where the mouse started the trial
... %%'endPosition', [],... % position vector [X Y Z theta] defining where the mouse ended the trial
    'blackoutDuration',1,... % "blackout" ITI at the beginning of trial
    'isTimeout', 0, ...  % whether the trial timed out   
...% 'stemLength',800 ...
... maze-sepcific fields:
... %     'rewardCondition',1,... assuming that this is the same as trial.type to avoid confustion.
    'licksInBin',[],...
    'rewardInBin',[],...
    'punishmentInBin',[]...
    );

%% define the reward and punishment locations (conditions) for each maze
vr.session.trialTypeNames = {'linearTrack','world1','world2'};
binEdges = 0:100:800;
% reward conditions are matched to world number, so will be matched to
% watever vr.currentWorld is. 

baselineRProb = 0.2;

n = 1;
rProb =         [0 0 0 0 1 0 0 0]';
requiresLick =  [0 0 0 0 0 0 0 0]';
pProb = rProb*0; % no punishment in pre-training
rProb(rProb==0 & pProb==0) = baselineRProb;

vr.condition(n).binEdges = binEdges;
vr.condition(n).rProb = rProb;
vr.condition(n).pProb = pProb;
vr.condition(n).requiresLick = requiresLick;

n = 2;
rProb =         [0 0 0 0 1 0 0 0]';
requiresLick =  [0 0 0 0 0 0 0 0]';
pProb = rProb*0; % no punishment in pre-training
rProb(rProb==0 & pProb==0) = baselineRProb;

vr.condition(n).binEdges = binEdges;
vr.condition(n).rProb = rProb;
vr.condition(n).pProb = pProb;
vr.condition(n).requiresLick = requiresLick;

n = 3;
rProb =         [0 0 1 0 0 0 0 0]';
requiresLick =  [0 0 0 0 0 0 0 0]';
pProb = rProb*0; % no punishment in pre-training
rProb(rProb==0 & pProb==0) = baselineRProb;

vr.condition(n).binEdges = binEdges;
vr.condition(n).rProb = rProb;
vr.condition(n).pProb = pProb;
vr.condition(n).requiresLick = requiresLick;

%%
[vr.trial.licksInBin] = deal(vr.condition(1).rProb.*0);
[vr.trial.rewardInBin] = deal(vr.condition(1).rProb.*0);
[vr.trial.punishmentInBin] = deal(vr.condition(1).rProb.*0);

%% common init
vr = commonInit(vr);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

vr = commonRuntime(vr,'iterStart');

%% MAZE CONDITION CHECK

% check to see if world is frozen
if vr.isBlackout
    % check to see if the delay has elasped 
    if toc(vr.blackoutTic)>vr.trial(vr.tN).blackoutDuration
        % then make sure that the world is invisible
        vr.trialEnded = 1;
        vr.isBlackout = 0;
        vr.isVisible = 1;
    end
    
%check to see if trial has timed out
elseif (now-vr.trial(vr.tN).start)*24*60*60 > vr.session.trialMaxDuration
% TRIAL TIMED OUT 
    vr.mazeEnded = 1;
    vr.isCorrect = 0;
    vr.trial(vr.tN).isTimeout = 1;
    vr.trial(vr.tN).blackoutDuration = 5;

% check to see if the mouse is at the end of the maze
elseif vr.position(2)>=785
    vr.mazeEnded = 1;
    vr.trial(vr.tN).isTimeout = 0;
    vr.trial(vr.tN).blackoutDuration = 1;
    vr = giveReward(vr,4);
    
end

%% MAZE END
if vr.mazeEnded
    % start blackout
    vr.mazeEnded = 0;
    vr.worlds{vr.cond}.surface.visible(:) = 0;
    vr.blackoutTic = tic;
    vr.isBlackout = 1;
    vr.isVisible = 0;
end

%% TRIAL END
if vr.trialEnded

    vr = commonRuntime(vr,'trialEnd');
    
    %% update start position
    scale = vr.rpm-vr.session.targetRPM;
    if isnan(scale) || isempty(scale)
        scale = 0;
    end
    startY = vr.trial(vr.tN-1).startPosition(2)-scale;
    startY(startY<15) = 15;
    startY(startY>785) = 785;
    
    vr.exper.variables.startY = num2str(startY);
        
    vr.trial(vr.tN).startPosition =  [0 startY eval(vr.exper.variables.mouseHeight) pi/2];
    
    %% set the new maze
    vr.position = vr.trial(vr.tN).startPosition;
    vr.currentWorld = vr.trial(vr.tN).type;
    
    vr.worlds{vr.currentWorld} = loadVirmenWorld(vr.exper.worlds{vr.currentWorld});
    
    for k =1:length(vr.worlds)
        vr.worlds{k}.surface.visible(:) = 1;
        vr.worlds{k}.surface.colors(1,:)=0;
    end
end
vr = commonRuntime(vr,'iterEnd');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = commonTermination(vr);