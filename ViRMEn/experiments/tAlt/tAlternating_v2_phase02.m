function code = tAlternating_v2_phase02
% linearTrackNew   Code for the ViRMEn experiment linearTrackNew.
%   code = linearTrackNew   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


%% MAZE DESCRIPTION
% tAlternating_v2_phase02
% stem length fixed at 200
% tower distance fixed at 15
% two tower percentage at 100% unless percentage correct is below 50, in
% which case it reverts to single towers
% blackout delay period is minimum 0.1 second, drawn from hand-crafted
% discrete distribution

% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)

%% TODO:
% calibrate virmen unit to cm conversion

% set whether in debug mode:
vr.debugMode = 0;
vr.imaging = 0;
vr.drawText = 1;
vr.save = 1;
%
vr.nTextFields = 16;

% initialize vr.session
% vr.session contains all variables that do not vary trial-by-trial. One
% copy of this is saved
% each session.
vr.session = struct(...
    'experimenterRigID', 'lynn_behaviorRig2',...
    'mazeName','tAlternating_v2_phase02',... % change this to get the actual maze name from vr
    'mouseNum', vr.exper.variables.mouseNumber, ...
    ... % reward parameters
    'minRewardFraction', 0.5, ...
    'rewardSizeML', 0.0034, ...
    ... % unique session parameters
    'expMu', 1.5,...
    'frozenDuration',1,...
    ... % trial duration parameters
    'trialMaxDuration', 45, ... % timeout countdown clock
    ... Start
    'minStemLength', 200, ...
    'maxStemLength', 200, ...
    'stemLengthIncrement',0, ...
    ... % Arm length parameters
    'minArmLength',10,...
    'maxArmLength',10,...
    'incrementArmLength',1,...
    ... % RPM parameters
    'targetRPM',4, ...
    'minRPM',0, ... % minimum number of rewards given, regardless of performance - this
    ... % gain parameters
    'forwardGain', -150, ...
    'viewAngleGain', -1.0, ...
    ... % DO NOT CHANGE
    'tic', tic,...
    'startTime', now(), ...
    'stopTime', [], ...
    'nTrials', 0, ...
    'nCorrect', 0, ...
    'pCorrect', 0, ...
    'nRewards', 0, ...
    'criterionReached', 0 ...
    ); 

% initialize vr.trialInfo
% vr.trial contains all information about individual trials
% trial info is saved in every ITI of the subsequent trial. therefore only
% complete trials are included.

vr.trial = struct(...
    'tic',tic,...
    'trialN', 1,...
    'stemLength', eval(vr.exper.variables.stemLength),... % length of the stem
    'armLength', eval(vr.exper.variables.armLength),... % length of the arms - should normally start at 15
    'correctTarget', [0 0],... % XY coordinate defining the center of the reward zone
    'correctRadius', 15,... % distance that the mouse needs to be from the reward location to get the reward
    'incorrectTarget',[0 0],... % XY coordinate defining the center of the incorrect/punishment zone
    'incorrectRadius',15,... % distance that the mouse needs to be from incorrect loication for the trial to be counted as incorrect
    'startPosition', [0 -eval(vr.exper.variables.stemLength)+10 eval(vr.exper.variables.mouseHeight) pi/2],... % position vector [X Y Z theta] defining where the mouse started the trial
    'endPosition', [],... % position vector [X Y Z theta] defining where the mouse ended the trial
    'targetDir', [], ... % target direction = sign of target position X value.
    'turnDir',[],... % turn direction = sign of end position X value.
    'duration', [],... % duration of the trial in seconds
    'blackoutDuration',0.1,...
    'frozenDuration',2,...
    'trialStartTimeAbs', toc(vr.session.tic),... % time the trial started, relative to session start time
    'trialStopTimeAbs', [],... % time trial ended, relative to session start time
    'rewardN', 0,... % total number of rewards given on that trial
    'isCorrect', [], ... % whether the mouse got the trial correct
    'isTimeout', [], ...
    'leftTowerVisible',1,...
    'rightTowerVisible',1, ...
    'rewardTowerDeg',[],...
    'rewardFraction',[],...
    'twoTowerTrial',0, ...
    'leftTarget',[], ...
    'leftChoice',[]...
    );

% initialize vr.iter
% vr.iter contains  information about all  indidivual iteration of virmen.
% the amount of information stored in this should be kept to a minimum.
% the iteration data for the last trial is all saved during the ITI
% #note: this is different from what was done before, where iteration data
% was saved on every iteration. I think this system might be better?
% vr.iter is only kept for the last two trials

vr.iter = struct(...
    'tic',[],...
    'trialN',[],... % current trial number
    'iterN',[],... % iterationNumber
    'iterInTrial',[],... % iteration in the trial
    'position',[],... % current position
    'velocity',[],... % current velocity
    'rewardN',[],... % number of rewards given on current iteration
    'lickN',[],... % count of licks
    'isITI',[],... % whether the mouse is in the ITI
    'isBlackout',[],... % whether the world is not visible
    'isFrozen',[],... % whether the world is forzen
    'isBrake',[],... % whether the ball is braked
    'startTimeAbs',[],... % absolute time
    'startTimeInTrial',[],... % time in trial (from trial start)
    'startTimeInSession',[], ... % time in session (from session start)
    'pitchRollYaw',[]...
    );

% set up the path
vr = initPath(vr,vr.session.experimenterRigID);

% set up the daq
vr = initDAQ(vr);

% initialize text boxes
cmap = lines(vr.nTextFields);
for k = 1:vr.nTextFields
    vr.text(k).string = '';
    vr.text(k).position = [1.1 .8-(0.1*(k-1))];
    vr.text(k).size = .03;
    vr.text(k).color = cmap(k,:);
end

%% initialize first trial
vr.iN = 0; % iteration total count
vr.iNT = 0; % interation in trial
vr.tN = 1; % trial number
vr.isITI = 0;
vr.mazeEnded = 0;

% randomize first turn direction
vr.trial(vr.tN).targetDir = sign(rand(1)-0.5); % this is just for getting the tower color
vr.trial(vr.tN).startingPosition = [0 -vr.trial(vr.tN).stemLength+10 eval(vr.exper.variables.mouseHeight) pi/2];

% set arm length & stem length
vr.exper.variables.stemLength = num2str(vr.trial(vr.tN).stemLength);
vr.exper.variables.armLength = num2str(vr.trial(vr.tN).armLength);

% set which tower is visible and set the tower location
switch vr.trial(vr.tN).targetDir
    case -1 % = right turn!!!! - remember x coordinates are flipped
        % make the right target the correct target and left the incorrect
        vr.trial(vr.tN).rightTowerVisible = 1;
        vr.trial(vr.tN).leftTowerVisible  = 0;
    case 1 % = left turn!!!!
        vr.trial(vr.tN).rightTowerVisible = 0;
        vr.trial(vr.tN).leftTowerVisible  = 1;
end

vr.trial(vr.tN).correctTarget = [vr.trial(vr.tN).targetDir*eval(vr.exper.variables.armLength), 20];
vr.trial(vr.tN).incorrectTarget = [-1*vr.trial(vr.tN).targetDir*eval(vr.exper.variables.armLength), 20];

if vr.trial(vr.tN).twoTowerTrial
    vr.trial(vr.tN).rightTowerVisible = 1;
    vr.trial(vr.tN).leftTowerVisible  = 1;
end

% set the radius
vr.exper.variables.rightTowerRadius = num2str(10*vr.trial(vr.tN).rightTowerVisible);
vr.exper.variables.leftTowerRadius = num2str(10*vr.trial(vr.tN).leftTowerVisible);
vr.trial(vr.tN).correctRadius = 15;
vr.trial(vr.tN).incorrectRadius = 15;
vr.trial(vr.tN).itiDuration = 2;

% reload world to update arm length and tower visibility
vr.worlds{1} = loadVirmenWorld(vr.exper.worlds{1});

% set reward positions
vr.position = vr.trial(vr.tN).startPosition;

vr.exper.variables.stemLength = num2str(vr.trial(vr.tN).stemLength);

%% define helper functions
vr.fun.euclideanDist = @(XY1,XY2)(sqrt(sum((XY1-XY2).^2)));

% make the textboxes
if vr.drawText
    vr.text(1).string = upper(['TIME: ' datestr(now-vr.session.startTime,'HH.MM.SS')]);
    vr.text(2).string = upper(['TRIALS: ' num2str(vr.session.nTrials)]);
    vr.text(3).string = upper(['REWARDS: ' num2str(0)]);
    vr.text(4).string = upper(['PRCT: ' num2str(vr.session.pCorrect)]);
end

%% Save copy of the virmen directory exactly as it is when this code is run
virmenArchivePath = [vr.session.savePathFinal filesep vr.session.experimenter sprintf('%03d',eval(vr.exper.variables.mouseNumber)) '_virmenArchive' filesep vr.session.baseFilename '_virmenArchive'];
if ~exist(virmenArchivePath,'dir')
    mkdir(virmenArchivePath);
end
copyfile('C:\Users\harveyadmin\Desktop\virmen',virmenArchivePath);
disp('virmen code archived');

if vr.save
    save([vr.session.savePathFinal, filesep, vr.session.baseFilename '_vr.mat'], 'vr', '-v7.3');
end
disp('vr structure saved');

vr.arduino = [];
vr = giveRewardPump(vr,1);
vr = rewardTone(vr,1);

vr.isBlackout = 0;
vr.isFrozen = 0;
vr.trialEnded = 0;
vr.mazeEnded = 0;


%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

global mvData;

% increment iteration counter

vr.iN = vr.iN+1;
vr.iNT = vr.iNT + 1;
vr.iter(vr.iNT).iterN = vr.iN;
vr.iter(vr.iNT).tic = tic;
vr.iter(vr.iNT).startTimeAbs = now();
vr.iter(vr.iNT).startTimeInTrial = toc(vr.trial(vr.tN).tic);
vr.iter(vr.iNT).startTimeInSession = toc(vr.session.tic);
vr.iter(vr.iNT).rewardN = 0;
vr.iter(vr.iNT).isBlackout = vr.isBlackout;
vr.iter(vr.iNT).isFrozen = vr.isFrozen;
vr.iter(vr.iNT).trialN = vr.tN;
vr.iter(vr.iNT).position = vr.position;
vr.iter(vr.iNT).velocity = vr.velocity;
vr.iter(vr.iNT).pitchRollYaw = mvData;
vr.iter(vr.iNT).iterInTrial = vr.iNT;

% increment trial duration
vr.trial(vr.tN).duration = toc(vr.trial(vr.tN).tic);

if vr.keyPressed==82 % R key to give reward manually
    vr = giveRewardPump(vr,1);
    vr = rewardTone(vr,1);
    vr.trial(vr.tN).rewardN = vr.trial(vr.tN).rewardN+1;
    vr.iter(vr.iNT).rewardN = vr.iter(vr.iNT).rewardN+1;
end

% if
if vr.imaging
    vr = iterStartPulse(vr); % pulse indicating the start of the iteration
    vr = iterGradedVoltage(vr); % graded pulse indicating mod(iterationNumber,10)
end

%% MAZE CONDITION CHECK
if vr.isFrozen
%     disp(['frozen for: ' num2str(toc(vr.trial(vr.tN).frozenTic))]);
    % check to see if the frozen coun
    if toc(vr.trial(vr.tN).frozenTic)>vr.trial(vr.tN).frozenDuration
        %timer has elapsed, start new trial
        vr.isFrozen = 0;
        vr.trialEnded = 1;
    end
    
    % check to see if the mouse is in the ITI
elseif vr.isBlackout
    % check to see if the delay has elasped 
    if toc(vr.trial(vr.tN).blackoutTic)>vr.trial(vr.tN).blackoutDuration
        % then make sure that the world is invisible
        disp('blackout ended');
        vr.position = vr.trial(vr.tN).startPosition;
        vr.worlds{1}.surface.visible(:) = 1;
        vr.exper.movementFunction = @moveWithDualSensors;
        vr.isBlackout = 0;
    end
    
    % otherwise, if the mouse is within correctRadius distance of the correct location, deliver the reward, start the ITI, and save the files
elseif vr.fun.euclideanDist(vr.position(1:2),vr.trial(vr.tN).correctTarget)<vr.trial(vr.tN).correctRadius
    % trial is correct
    % see see how far the tower is from the center of the field of view;
    vr.trial(vr.tN).rewardTowerDeg = vr.position(4)-cart2pol(vr.trial(vr.tN).correctTarget(1)-vr.position(1),vr.trial(vr.tN).correctTarget(2)-vr.position(2));
    
    vr.trial(vr.tN).rewardFraction = 0.25+exp(-2*abs(vr.trial(vr.tN).rewardTowerDeg));
    
    vr.mazeEnded = 1;
    vr.trial(vr.tN).isCorrect = 1;
    % deliver reward
    if ~vr.debugMode
        vr = giveRewardPump(vr,vr.trial(vr.tN).rewardFraction);
        vr = rewardTone(vr,vr.trial(vr.tN).rewardFraction);
    end
    vr.trial(vr.tN).rewardN = vr.trial(vr.tN).rewardN + vr.trial(vr.tN).rewardFraction;
    vr.iter(vr.iNT).rewardN = vr.iter(vr.iNT).rewardN+vr.trial(vr.tN).rewardFraction;
        
    % otherwise, if the mouse is within the incorrect radius of the incorrect
elseif (vr.fun.euclideanDist(vr.position(1:2),vr.trial(vr.tN).incorrectTarget)<vr.trial(vr.tN).incorrectRadius) ...    
% trial is incorrect
vr.mazeEnded = 1;
vr.trial(vr.tN).isCorrect = 0;
vr.trial(vr.tN).isTimeout = 0;

elseif toc(vr.trial(vr.tN).tic) > vr.session.trialMaxDuration
    % trial has timed out
    vr.mazeEnded = 1;
    vr.trial(vr.tN).isCorrect = 0;
    vr.trial(vr.tN).isTimeout = 1;
end

%% MAZE END
if vr.mazeEnded
    disp('maze ended');
    % make world invisible if trial timed out
    if vr.trial(vr.tN).isTimeout
        vr.worlds{1}.surface.visible(:) = 0;
    end
    
    % start the frozen period
    vr.trial(vr.tN).frozenTic = tic;
    vr.isFrozen = 1;
    vr.exper.movementFunction = @moveWithKeyboard; 
    
    vr.mazeEnded = 0;
end

%% TRIAL END
if vr.trialEnded
    disp('trial ended');
    vr.trial(vr.tN).endPosition = vr.position;
    vr.trial(vr.tN).duration = toc(vr.trial(vr.tN).tic);
    vr.trial(vr.tN).leftChoice = vr.trial(vr.tN).leftTarget*vr.trial(vr.tN).isCorrect*(~vr.trial(vr.tN).isTimeout);
    if vr.trial(vr.tN).isCorrect
        vr.trial(vr.tN).turnDir = vr.trial(vr.tN).targetDir*(~vr.trial(vr.tN).isTimeout);
    else
        vr.trial(vr.tN).turnDir = -1*vr.trial(vr.tN).targetDir*(~vr.trial(vr.tN).isTimeout);
    end
    vr.trial(vr.tN).trialStopTimeAbs = toc(vr.session.tic);
    
    % update performance metrics
    vr.session.nTrials = vr.tN;
    vr.session.nCorrect = sum([vr.trial(:).isCorrect]);
    vr.session.pCorrect = vr.session.nCorrect/vr.session.nTrials;
    vr.session.nRewards = num2str(sum([vr.trial(:).rewardN]));

    %% SAVE DATA
    if vr.save
        vr = saveTrial(vr,vr.tN);
        disp('data saved');
    end
    
    %% COMPUTE PERFORMANCE METRICS
    
    % rewards per minute averaged over the last 60 seconds
    rewardCounter = 0;
    secCounter = 0;
    for k = vr.tN:-1:1
        secCounter = toc(vr.trial(k).tic);
        rewardCounter = rewardCounter + vr.trial(k).rewardN;
        if secCounter > 60
            break
        end
    end
    rewardsPerMinute = rewardCounter;
    

    % percentage correct in the last 20 trials
    last20Trials = vr.tN:-1:vr.tN-19;
    last20Trials(last20Trials<1) = [];
    percentageCorrectLast20 = sum([vr.trial(last20Trials).isCorrect])/length(last20Trials);
    vr.text(9).string = upper(['PC20: ', num2str(percentageCorrectLast20)]);
    
    % see if criterion has been reached
    if sum([vr.trial(:).twoTowerTrial])>100 && mean([vr.trial([vr.trial(:).twoTowerTrial]==1).isCorrect])>0.75
        vr.session.criterionReached = 1;
    end
    
    %% NEW TRIAL STARTS HERE 
    vr.trialEnded = 0;
    vr.tN = vr.tN+1;
    vr.iNT = 0;
    vr.iter(:) = [];

    vr.trial(vr.tN).trialStartTimeAbs = toc(vr.session.tic);
    vr.trial(vr.tN).rewardN = 0;
    vr.trial(vr.tN).isCorrect = 0;
    vr.trial(vr.tN).isTimeout = 0;
    vr.trial(vr.tN).frozenDuration = vr.session.frozenDuration;
    vr.trial(vr.tN).blackoutTic = tic;
    vr.trial(vr.tN).tic = tic;
    vr.trial(vr.tN).trialN = vr.tN;
    vr.trial(vr.tN).stemLength = vr.trial(vr.tN-1).stemLength;
    vr.trial(vr.tN).armLength = vr.trial(vr.tN-1).armLength;
    vr.trial(vr.tN).correctRadius = vr.trial(vr.tN-1).correctRadius;
    vr.trial(vr.tN).incorrectRadius = vr.trial(vr.tN-1).incorrectRadius;
    vr.trial(vr.tN).correctRadius = 15;
    vr.trial(vr.tN).incorrectRadius = 15;
    vr.trial(vr.tN).startPosition = [0 -eval(vr.exper.variables.stemLength)+10 eval(vr.exper.variables.mouseHeight) pi/2];
    
    % here we need to set the blackout delay
    vr.trial(vr.tN).blackoutDuration = exprnd(vr.session.expMu);
    vr.trial(vr.tN).frozenDuration = vr.session.frozenDuration;

    % update  trial params that stay the same as last trial

    % update conditions based on rpm?
    if rewardsPerMinute > vr.session.targetRPM
    else
    end

    % update conditions based on percentage correct?
     if percentageCorrectLast20 >= 0
        vr.trial(vr.tN).twoTowerTrial = 1;
    else
        vr.trial(vr.tN).twoTowerTrial = 0;
    end
    
    % set the target direction
    if vr.trial(vr.tN-1).isCorrect
        vr.trial(vr.tN).targetDir = -1*vr.trial(vr.tN-1).targetDir;
    else
        vr.trial(vr.tN).targetDir = vr.trial(vr.tN-1).targetDir;
    end
    
    vr.trial(vr.tN).leftTarget = vr.trial(vr.tN).targetDir > 0;
    % set arm length & stem length
    vr.exper.variables.stemLength = num2str(vr.trial(vr.tN).stemLength);
    vr.exper.variables.armLength = num2str(vr.trial(vr.tN).armLength);
    
    % set which tower is visible and set the tower location
    switch vr.trial(vr.tN).targetDir
        case -1 % = right turn - remember x coordinates are flipped
            % make the right target the correct target and left the incorrect
            vr.text(8).string = upper('RIGHT TURN TRIAL');
            vr.trial(vr.tN).rightTowerVisible = 1;
            vr.trial(vr.tN).leftTowerVisible  = 0;
        case 1 % = left turn!!!!
            vr.text(8).string = upper('LEFT TURN TRIAL');
            vr.trial(vr.tN).rightTowerVisible = 0;
            vr.trial(vr.tN).leftTowerVisible  = 1;
    end
    
    if vr.trial(vr.tN).twoTowerTrial
        vr.trial(vr.tN).rightTowerVisible = 1;
        vr.trial(vr.tN).leftTowerVisible  = 1;
    end
    
    % set the tower positions
    vr.exper.variables.leftTowerX = num2str((eval(vr.exper.variables.armLength)+10));
    vr.exper.variables.rightTowerX = num2str(-(eval(vr.exper.variables.armLength)+10));
    
    vr.trial(vr.tN).correctTarget = [vr.trial(vr.tN).targetDir*(eval(vr.exper.variables.armLength)+10), 20];
    vr.trial(vr.tN).incorrectTarget = [-1*vr.trial(vr.tN).targetDir*(eval(vr.exper.variables.armLength)+10), 20];
    vr.exper.variables.rightTowerRadius = num2str(10*vr.trial(vr.tN).rightTowerVisible);
    vr.exper.variables.leftTowerRadius = num2str(10*vr.trial(vr.tN).leftTowerVisible);
    
    vr.trial(vr.tN).trialN = vr.tN+1;
    vr.trial(vr.tN).rewardN = 0;
    vr.trial(vr.tN).startPosition =  [0 -eval(vr.exper.variables.stemLength)+10 eval(vr.exper.variables.mouseHeight) pi/2];
    
    %% update text boxes
    if vr.drawText
        vr.text(6).string = upper(['RPM: ', num2str(rewardsPerMinute)]);
    end
    
    if vr.tN > 1
        vr.text(11).string = upper(['TT PC: ', num2str(sum([vr.trial([vr.trial(1:end-1).twoTowerTrial]==1).isCorrect])...
            /sum([vr.trial(1:end-1).twoTowerTrial]==1))]);
    end
    

    vr.worlds{1} = loadVirmenWorld(vr.exper.worlds{1});
    vr.worlds{1}.surface.visible(:) = 0;
    vr.trial(vr.tN).blackoutTic = tic;
    vr.isBlackout = 1;
    
    vr.text(12).string = upper(['BO: ', num2str(abs(vr.trial(vr.tN).blackoutDuration))]);

    
    
end

if ~(vr.isFrozen || vr.isBlackout)
    if vr.drawText
        vr.text(1).string = upper(['TIME: ' datestr(now-vr.session.startTime,'HH.MM.SS')]);
        vr.text(2).string = upper(['TRIALS: ' num2str(vr.session.nTrials)]);
        vr.text(3).string = upper(['REWARDS: ' num2str(sum([vr.trial(:).rewardN]))]);
        vr.text(4).string = upper(['PRCT: ' num2str(vr.session.pCorrect)]);
        vr.text(5).string = upper(['LENGTH: ', num2str(vr.trial(vr.tN).stemLength)]);
        vr.text(7).string = upper(['TDIST: ', num2str(abs(vr.trial(vr.tN).correctTarget(1)))]);
        vr.text(10).string = upper(['FRZN: ', num2str(abs(vr.trial(vr.tN).frozenDuration))]);
        vr.text(12).string = upper(['BO: ', num2str(abs(vr.trial(vr.tN).blackoutDuration))]);
%         vr.text(13).string = upper(['MAXBO: ', num2str(abs(vr.trial(vr.tN).itiMaxBlackout))]);
        vr.text(14).string = upper(['FR: ' num2str(round(length(vr.iter)/toc(vr.iter(1).tic)))]);
%         vr.text(15).string = upper(['LRTG: ' num2str(rad2deg(vr.trial(vr.tN-1).rewardTowerDeg))]);
        vr.text(16).string = upper(['LEVELUP: ' num2str(vr.session.criterionReached)]);
    end
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
delete(instrfind);
