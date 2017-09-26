function code = linearTrack_v3
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
vr.debugMode = 1;
vr.imaging = 0;
vr.drawText = 1;
vr.save = 0;
%
vr.nTextFields = 16;

% set up gain - perhaps move these to the transformation function?
vr.forwardGain = -150;
vr.viewAngleGain = -1;

% initialize vr.session
% vr.session contains all variables that do not vary trial-by-trial. One
% copy of this is saved
% each session.
vr.session = struct(...
    'sessionID', [vr.exper.variables.mouseID '_' datestr(now,'YYmmDD_hhMMss')], ...
    'experimenterRigID', 'noah_deskPC',... % used for initializing the saving file path 
    'nTrials', 0, ...
    'nCorrect', 0, ...
    'totalReward', 0, ...
    'trialTypeNames',{'linear track'},...
    'experimentCode', mfilename,... % change this to get the actual maze name from vr
    'rewardSizeML', 0.004, ...
    'trialMaxDuration', 45, ... % timeout countdown clock
    'targetRPM',1, ...
    'startTime', now()...
    );

% initialize vr.trialInfo
% vr.trial contains all information about individual trials
% trial info is saved in every ITI of the subsequent trial. therefore only
% complete trials are included.
vr.trial(1:5000,1) = struct(...
    ...% the standard fields 
    'N',0,...
    'duration',0,...
    'reward',0,...
    'isCorrect',0,...
    'type',1,...
    'startTime',0,...
    'experimentCode',mfilename(),...
    ...% general fields to all mazes:
    'startPosition', [0 10 eval(vr.exper.variables.mouseHeight) pi/2],... % position vector [X Y Z theta] defining where the mouse started the trial
    'endPosition', [],... % position vector [X Y Z theta] defining where the mouse ended the trial
    'frozenDuration',2,... % frozen period at the end of the maze before ITI
    'blackoutDuration',rand(),... % "blackout" ITI at the beginning of trial
    'isTimeout', [], ...  % whether the trial timed out   
    'stemLength',10,...
    'world',eval(vr.exper.variables.currentWorld),...
... maze-sepcific fields:
    'correctRadius',15,...
    'incorrectRadius',15,...
    'puff',0 ...
    );

% names of variables (fields in vr) that will be saved on each iteration,
% followed by the number of elements in each of those.
% Each variable will be flattened and saved in a
% binary file in the order specified in saveVar.
vr.session.saveVar = {...
    % standard fields, do not change:
    'rawMovement',4,...
    'position',4,...
    'velocity',4,...
    'iN',1,...
    'tN',1,...
    'isITI',1,...
    'isReward',1,...
    'isLick',1,...
    'isVisible',1,...
    'dt',1,...
    ... % custom fields
    'airPuff',1,...
    'isFrozen',1, ... % whether the world is forzen
    'trialEnded',1,...
    'mazeEnded',1, ...
    'isBlackout',1 ...
};

% the fields saved on every iteration
vr.rawMovement = [];
vr.iN = 0;
vr.tN = 1;
vr.isITI = 0;
vr.isReward = 0;
vr.isLick = 0;
vr.isVisible = 1;
vr.isFrozen = 0;
vr.isBlackout = 0;
vr.airPuff = 0;

vr.itiTic;
vr.itiDuration = 3;

% set up the path
vr = initPath(vr,vr.session.experimenterRigID);
vr = initDAQ(vr);
vr = initTextboxes(vr);

%% set up the maze

% world 1 is the standard linear track
% world 2 is the "enriched" linear track w/ air puff
% world 3 is a different "enriched" linear track w/ air puff
% world 4 is a different "enriched" linear track w/out air puff

vr.worlds{1}.rewardXY = [0 800];
vr.worlds{1}.puffXY = [NaN NaN];

vr.worlds{2}.rewardXY = [0 350];
vr.worlds{2}.puffXY = [0 700];

vr.worlds{3}.rewardXY = [0 630];
vr.worlds{3}.puffXY = [0 400];

vr.worlds{4}.rewardXY = [0 520];
vr.worlds{4}.puffXY = [NaN NaN];

%% initialize first trial
vr.mazeEnded = 0;
vr.trialEnded = 0;

vr.iN = 0;
vr.tN = 1;
vr.trial.N = vr.tN;
vr.trial.start = now();
vr.position = vr.trial(vr.tN).startPosition;
vr.exper.variables.stemLength = num2str(vr.trial(vr.tN).stemLength);

%% define helper functions
vr.fun.euclideanDist = @(XY1,XY2)(sqrt(sum((XY1-XY2).^2)));

%% Save copy of the virmen directory exactly as it is when this code is run
if vr.save
    archiveVirmenCode(vr,mfilename('fullpath'));
    save([vr.session.savePathFinal, filesep, vr.session.sessionID '_vr.mat'], 'vr', '-v7.3');
    disp('vr structure saved');
    % open and initialize 
    vr.iterFileID = fopen([vr.session.savePathTemp filesep vr.session.sessionID '_iter.bin'],'a+');
end

vr.arduino = [];
vr = giveRewardPump(vr,1);
vr = rewardTone(vr,1);



% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% increment iteration counter
global mvData;
global lickData;

vr.rawMovement = mvData;
vr.isLick = lickData;

vr.iN = vr.iN+1;
vr.reward = 0;
vr.isVisible = ~vr.isBlackout;

switch vr.keyPressed
    case 82 % R key to give reward manually
    vr = giveRewardPump(vr,1);
    vr = rewardTone(vr,1);
    vr.reward = vr.reward + 1;
    vr.trial(vr.tN).reward = vr.trial(vr.tN).reward+1;
    case 49 % 1 to switch to world 1 next trial
        vr.trial(vr.tN+1:end).world = 1;
    case 50 % 2 switches to world 2 next trial
        vr.trial(vr.tN+1:end).world = 2;
    case 51 % 3 switches to world 3 next trial
        vr.trial(vr.tN+1:end).world = 3;
    case 52 % 4 switches to world 4 next trial
        vr.trial(vr.tN+1:end).world = 4;
end

% check to see if the mouse is in the ITI
if vr.isITI
    if toc(vr.itiTic)>vr.itiDuration
        vr.trialEnded = 1;
        vr.isITI = 0;
    else
        vr.position = [-20 -20 vr.position(3) 0]; % wait at ITI location
    end
end

% if the mouse licks, check for appropriate response 
if vr.isLick
    if vr.trial(vr.tN).reward ==0 && vr.fun.euclideanDist(vr.position(1:2),vr.worlds{vr.trial(vr.tN).world}.rewardXY)<vr.trial(vr.tN).lickRadius
        vr = giveRewardPump(vr,1);
        vr.reward = vr.reward + 1;
        vr.trial(vr.tN).reward = vr.trial(vr.tN).reward+1;
    end
    if vr.trial(vr.tN).puff == 0 && vr.fun.euclideanDist(vr.position(1:2),vr.worlds{vr.trial(vr.tN).world}.rewardXY)<vr.trial(vr.tN).lickRadius
        vr = giveAirPuff(vr,1);
        vr.airPuff = vr.airPuff+1;
        vr.trial(vr.tN).puff = vr.trial(vr.tN).puff+1;
    end
end

% check if the mouse is at the end of the maze
if vr.position(2)>790
    vr.itiTic = tic;
    vr.worlds{vr.trial(vr.tN).world}.surface.visible(:) = 0;
    vr.position = [-20 -20 vr.position(3) 0];
    vr.exper.movementFunction = @moveWithKeyboard;
end
    

if vr.trialEnded
    
    vr.trial(vr.tN).duration = (now - vr.trial(vr.tN).startTime)*(60*60*24);
    
    % NEW TRIAL STARTS HERE   

    vr.trialEnded = 0;
    vr.isITI = 0;
    
    vr.tN = vr.tN+1;
    
    % set the mouse's start position
    vr.position = vr.trial(vr.tN).startPosition + [0 randi(100) 0 0];
    % make the world visible
    vr.currentWorld = vr.trial(vr.tN).world;
    vr.worlds{vr.currentWorld} = loadVirmenWorld(vr.exper.worlds{vr.currentWorld});
    vr.worlds{vr.currentWorld}.surface.visible(:) = 1;
    vr.exper.movementFunction = @moveWithDualSensors;

    vr.trial(vr.tN).N = vr.tN;
    
    % calculate RPM over last 3 trials
    rpm = 60*sum(vr.trial(vr.tN:-1:max(1,vr.tN-2)).reward)/sum(vr.trial(vr.tN:-1:max(1,vr.tN-2)).duration);

    %% update text boxes
    if vr.drawText
        vr.text(6).string = upper(['RPM: ', num2str(rpm)]);
    end
    
    if vr.save
        saveTrial(vr.trial)
    end
    
end
% draw the text
if ~(vr.isFrozen || vr.isBlackout)
    if vr.drawText
        vr.text(1).string = upper(['TIME: ' datestr(now-vr.session.startTime,'HH.MM.SS')]);
        vr.text(2).string = upper(['TRIALS: ' num2str(vr.tN-1)]);
        vr.text(3).string = upper(['REWARDS: ' num2str(sum([vr.trial(:).reward]))]);
    end
end
% output pulses 
if vr.imaging
    vr = iterStartPulse(vr); % pulse indicating the start of the iteration
    vr = iterGradedVoltage(vr); % graded pulse indicating mod(iterationNumber,10)
    vr = iterRandomPulse(vr); % random one or zero
end
% save the iteration
if vr.save
saveIter(vr);
end


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
fclose(vr.iterFileID);

