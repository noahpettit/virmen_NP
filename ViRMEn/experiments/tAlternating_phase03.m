function code = tAlternating_phase03
% linearTrackNew   Code for the ViRMEn experiment linearTrackNew.
%   code = linearTrackNew   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


%% MAZE DESCRIPTION
% linearTrack_phase00
% Linear track of 500 units in length
% Tower A and Tower B that switch every time mouse gets it right.
% Min/starting position 3 units away from reward zone
% Increment by 2 units every time mouse gets it right
% Freeze view at the end.
% correct ITI = 2 sec, incorrect ITI = 2 seconds;
% Give reward inversely proportional to angular distance of tower from center of FOV. = mod(100-angleBetweenViewAngleAndRewardTowerCenter).
% Play reward sound volume proportional to reward
% If mouse enters reward zone with tower not in view then trial is counted as incorrect.
% Adjust starting distance to target of 4 RPM, averaged over last 1 min.
% When mouse is running 100 consecutive trials of max length and >4 RPM, move to phase01

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
vr.nTextFields = 13;

% initialize vr.session
% vr.session contains all variables that do not vary trial-by-trial. One
% copy of this is saved
% each session.
vr.session = struct(...
    'experimenterRigID', 'lynn_behaviorRig1',...
    'mazeName','tAlternating_phase03',... % change this to get the actual maze name from vr
    'mouseNum', vr.exper.variables.mouseNumber, ...
    ... % reward parameters
    'minRewardFraction', 0.25, ...
    'rewardSizeML', 0.004, ...
    ... % ITI parameters
    'incorrectITI', 2,...
    'correctITI', 2,...
    'minITI',2,...
    'maxITI',8,...
    'incrementITI',0,...
    'trialMaxDuration', 45, ... % timeout countdown clock
    ... Start
    'minStemLength', 6, ...
    'maxStemLength', 350, ...
    'stemLengthIncrement',2, ...
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
    'nRewards', 0 ...
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
    'itiDuration', vr.session.minITI,... % duration of the post-trial ITI in seconds
    'itiBlackout',0,...
    'itiMaxBlackout',0,...
    'itiFrozen',2,...
    'itiBrake',0,...
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
    'leftTrial',[] ...
    );

% initialize vr.iter
% vr.iter contains  information about all  indidivual iteration of virmen.
% the amount of information stored in this should be kept to a minimum.
% the iteration data for the last trial is all saved during the ITI
% #note: this is different from what was done before, where iteration data
% was saved on every iteration. I think this system might be better?
vr.iter = struct(...
    'tic',[],...
    'trialN',[],... % current trial number
    'iterN',[],... % iterationNumber
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
vr.iN = 0;
vr.tN = 1;
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

%% Save  copy of the virmen directory exactly as it is when this code is run
virmenArchivePath = [vr.session.savePathFinal filesep vr.session.experimenter sprintf('%03d',eval(vr.exper.variables.mouseNumber)) '_virmenArchive' filesep vr.session.baseFilename '_virmenArchive'];
if ~exist(virmenArchivePath,'dir');
    mkdir(virmenArchivePath);
end
% copyfile('C:\Users\harveylab\Desktop\virmen_NP',virmenArchivePath);
disp('virmen code archived');

if vr.save
    save([vr.session.savePathFinal, filesep, vr.session.baseFilename '_vr.mat'], 'vr', '-v7.3');
end
disp('vr structure saved');

vr.arduino = [];
vr = giveRewardPump(vr,1);
vr = rewardTone(vr,1);


%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

global mvData;

% increment iteration counter

vr.iN = vr.iN+1;
vr.iter(vr.iN).iterN = vr.iN;
vr.iter(vr.iN).tic = tic;
vr.iter(vr.iN).startTimeAbs = now();
vr.iter(vr.iN).startTimeInTrial = toc(vr.trial(vr.tN).tic);
vr.iter(vr.iN).startTimeInSession = toc(vr.session.tic);
vr.iter(vr.iN).rewardN = 0;
vr.iter(vr.iN).isBlackout = 0;
vr.iter(vr.iN).isFrozen = 0;

% increment trial duration
vr.trial(vr.tN).duration = toc(vr.trial(vr.tN).tic);

if vr.keyPressed==82;
    if ~vr.debugMode
        vr = giveRewardPump(vr,1);
        vr = rewardTone(vr,1);
    end
    vr.trial(vr.tN).rewardN = vr.trial(vr.tN).rewardN+vr.isReward;
    vr.iter(vr.iN).rewardN = vr.iter(vr.iN).rewardN+vr.isReward;
end

% if
if vr.imaging
    vr = iterStartPulse(vr); % pulse indicating the start of the iteration
    vr = iterGradedVoltage(vr); % graded pulse indicating mod(iterationNumber,10)
end

% check to see if the mouse is in the ITI
if vr.isITI
    % check to see if the ITI has elasped and if so come out of the ITI,
    % increment the trial counter, and set the mouse at the start of the
    % maze.
    if toc(vr.trial(vr.tN).itiTic)>vr.trial(vr.tN).itiFrozen
        % then make sure that the world is invisible
        vr.worlds{1}.surface.visible(:) = 0;
        vr.iter(vr.iN).isBlackout = 1;
    else
        vr.iter(vr.iN).isFrozen = 1;
    end
    
    if toc(vr.trial(vr.tN).itiTic)>vr.trial(vr.tN).itiDuration
        vr.isITI = 0;
        % increment the trial number
        vr.tN = vr.tN+1;
        vr.trial(vr.tN).tic = tic;
        % set the mouse's start position
        vr.position = vr.trial(vr.tN).startPosition;
        % make the world visible
        vr.worlds{1} = loadVirmenWorld(vr.exper.worlds{1});
        vr.worlds{1}.surface.visible(:) = 1;
        vr.exper.movementFunction = @moveWithDualSensors;

    else
        % wait.
        % set mouse position to the start position
        vr.position = vr.trial(vr.tN).endPosition;
    end
    
    
    % otherwise, if the mouse is within correctRadius distance of the correct location, deliver the reward, start the ITI, and save the files
elseif vr.fun.euclideanDist(vr.position(1:2),vr.trial(vr.tN).correctTarget)<vr.trial(vr.tN).correctRadius
    % trial is correct
    % see see how far the tower is from the center of the field of view;
    vr.trial(vr.tN).rewardTowerDeg = vr.position(4)-cart2pol(vr.trial(vr.tN).correctTarget(1)-vr.position(1),vr.trial(vr.tN).correctTarget(2)-vr.position(2));
    vr.trial(vr.tN).rewardFraction = (pi/2-abs(vr.trial(vr.tN).rewardTowerDeg))/(pi/2);
    vr.trial(vr.tN).rewardFraction(vr.trial(vr.tN).rewardFraction<vr.session.minRewardFraction) = vr.session.minRewardFraction;
    
    vr.mazeEnded = 1;
    vr.trial(vr.tN).isCorrect = 1;
    % deliver reward
    
    if ~vr.debugMode
        vr = giveRewardPump(vr,vr.trial(vr.tN).rewardFraction);
        vr = rewardTone(vr,vr.trial(vr.tN).rewardFraction);
    end
    vr.trial(vr.tN).rewardN = vr.trial(vr.tN).rewardN+vr.trial(vr.tN).rewardFraction;
    vr.iter(vr.iN).rewardN = vr.iter(vr.iN).rewardN+vr.trial(vr.tN).rewardFraction;
    
%     vr.trial(vr.tN).itiDuration = vr.session.correctITI;
    
    % otherwise, if the mouse is within the incorrect radius of the incorrect
elseif (vr.fun.euclideanDist(vr.position(1:2),vr.trial(vr.tN).incorrectTarget)<vr.trial(vr.tN).incorrectRadius) ...
        
% trial is incorrect
vr.mazeEnded = 1;
vr.trial(vr.tN).isCorrect = 0;
vr.trial(vr.tN).isTimeout = 0;
% vr.trial(vr.tN).itiDuration = vr.session.incorrectITI;

% if the trial has timed out
elseif toc(vr.trial(vr.tN).tic) > vr.session.trialMaxDuration
    
    vr.mazeEnded = 1;
    vr.trial(vr.tN).isCorrect = 0;
    vr.trial(vr.tN).isTimeout = 1;
    
%     vr.trial(vr.tN).itiDuration = vr.session.incorrectITI;
    
end

% determine the conditions of the next trial.
if vr.mazeEnded
    
    % save end position
    vr.trial(vr.tN).endPosition = vr.position;
    
    % make world invisible if trial timed out
    if vr.trial(vr.tN).isTimeout
        vr.worlds{1}.surface.visible(:) = 0;
        vr.iter(vr.iN).isBlackout = 1;
    end
    
    % set the movement function
    vr.exper.movementFunction = @moveWithKeyboard;
    
    % enter the ITI
    vr.isITI = 1;
    % start the ITI counter
    vr.trial(vr.tN).itiTic = tic;
    
    % update performance metrics
    vr.session.nTrials = vr.tN-1;
    vr.session.nCorrect = sum([vr.trial(1:max(1,vr.tN-1)).isCorrect]);
    vr.session.pCorrect = vr.session.nCorrect/vr.session.nTrials;
    vr.session.nRewards = num2str(sum([vr.trial(:).rewardN]));
    
    % save the previous trial data
    if vr.tN>1 && vr.save
        vr = saveTrial(vr,vr.tN-1);
    end
    
    % update next trial params that stay the same
    
    vr.trial(vr.tN+1).stemLength = vr.trial(vr.tN).stemLength;
    vr.trial(vr.tN+1).armLength = vr.trial(vr.tN).armLength;
    vr.trial(vr.tN+1).correctRadius = vr.trial(vr.tN).correctRadius;
    vr.trial(vr.tN+1).incorrectRadius = vr.trial(vr.tN).incorrectRadius;
    vr.trial(vr.tN+1).correctRadius = 15;
    vr.trial(vr.tN+1).incorrectRadius = 15;

    % calculate rewards per minute averaged over the last 20 seconds
    rewardCounter = 0;
    secCounter = 0;
    for k = vr.tN:-1:1
        secCounter = toc(vr.trial(k).tic);
        rewardCounter = rewardCounter + vr.trial(k).rewardN;
        if secCounter > 20;
            break
        end
    end
    rewardsPerMinute = rewardCounter/(20/60);
    
    % if the rewards per minute are greater than a certain amount, increase
    % the ITI
    if rewardsPerMinute > vr.session.targetRPM
        % make the maze harder by increasing the ITI
        vr.trial(vr.tN+1).itiFrozen = 2;
        vr.trial(vr.tN+1).itiMaxBlackout = 5;%min(10, vr.trial(vr.tN).itiMaxBlackout + 0.1);
    else
        % make the maze easier by decreasing the ITI
        vr.trial(vr.tN+1).itiFrozen = 2;
        vr.trial(vr.tN+1).itiMaxBlackout = 5;%max(0, vr.trial(vr.tN).itiMaxBlackout - 0.3);
    end
    vr.trial(vr.tN+1).itiBlackout = rand(1)*vr.trial(vr.tN+1).itiMaxBlackout;
    vr.trial(vr.tN+1).itiDuration = vr.trial(vr.tN+1).itiFrozen+vr.trial(vr.tN+1).itiBlackout;

    
    % if the percentage correct is greater than 50, introduce chance of
    % twoTowerTrial
    last20Trials = vr.tN:-1:vr.tN-19;
    last20Trials(last20Trials<1) = [];
    percentageCorrectLast20 = sum([vr.trial(last20Trials).isCorrect])/length(last20Trials);
    vr.text(9).string = upper(['PC20: ', num2str(percentageCorrectLast20)]);

    if percentageCorrectLast20 < 0.5
        vr.trial(vr.tN+1).twoTowerTrial = 0; 
    else
        vr.trial(vr.tN+1).twoTowerTrial = 1;
    end
    
    % set the target direction
    if vr.trial(vr.tN).isCorrect
        vr.trial(vr.tN+1).targetDir = -1*vr.trial(vr.tN).targetDir;
    else
        vr.trial(vr.tN+1).targetDir = vr.trial(vr.tN).targetDir;
    end
    
    % set arm length & stem length
    vr.exper.variables.stemLength = num2str(vr.trial(vr.tN+1).stemLength);
    vr.exper.variables.armLength = num2str(vr.trial(vr.tN+1).armLength);
    
    % set which tower is visible and set the tower location
    switch vr.trial(vr.tN+1).targetDir
        case -1 % = right turn - remember x coordinates are flipped
            % make the right target the correct target and left the incorrect
            vr.text(8).string = upper('RIGHT TURN TRIAL');
            vr.trial(vr.tN+1).rightTowerVisible = 1;
            vr.trial(vr.tN+1).leftTowerVisible  = 0;
        case 1 % = left turn!!!!
            vr.text(8).string = upper('LEFT TURN TRIAL');
            vr.trial(vr.tN+1).rightTowerVisible = 0;
            vr.trial(vr.tN+1).leftTowerVisible  = 1;
    end
    
    if vr.trial(vr.tN+1).twoTowerTrial
        vr.trial(vr.tN+1).rightTowerVisible = 1;
        vr.trial(vr.tN+1).leftTowerVisible  = 1;
    end
    
    % set the radius
    vr.exper.variables.leftTowerX = num2str((eval(vr.exper.variables.armLength)+10));
    vr.exper.variables.rightTowerX = num2str(-(eval(vr.exper.variables.armLength)+10));
    
    vr.trial(vr.tN+1).correctTarget = [vr.trial(vr.tN+1).targetDir*(eval(vr.exper.variables.armLength)+10), 20];
    vr.trial(vr.tN+1).incorrectTarget = [-1*vr.trial(vr.tN+1).targetDir*(eval(vr.exper.variables.armLength)+10), 20];
    vr.exper.variables.rightTowerRadius = num2str(10*vr.trial(vr.tN+1).rightTowerVisible);
    vr.exper.variables.leftTowerRadius = num2str(10*vr.trial(vr.tN+1).leftTowerVisible);
    
% set the trial fields that change    
    
    vr.trial(vr.tN+1).trialN = vr.tN+1;
    vr.trial(vr.tN+1).rewardN = 0;
    vr.trial(vr.tN+1).startPosition =  [0 -eval(vr.exper.variables.stemLength)+10 eval(vr.exper.variables.mouseHeight) pi/2];
    
    %% update text boxes
    if vr.drawText
        vr.text(6).string = upper(['RPM: ', num2str(rewardsPerMinute)]);
    end
    
    
    if vr.tN > 1
        try
            vr.text(11).string = upper(['TT PC: ', num2str(sum([vr.trial([vr.trial(1:end-1).twoTowerTrial]==1).isCorrect])...
                /sum([vr.trial(1:end-1).twoTowerTrial]==1))]);
        catch
            global vr1
            vr1 = vr;
            keyboard
        end
        
    end

    
    vr.mazeEnded = 0;
end

%%
if ~vr.isITI
    if vr.drawText
        vr.text(1).string = upper(['TIME: ' datestr(now-vr.session.startTime,'HH.MM.SS')]);
        vr.text(2).string = upper(['TRIALS: ' num2str(vr.session.nTrials)]);
        vr.text(3).string = upper(['REWARDS: ' num2str(sum([vr.trial(:).rewardN]))]);
        vr.text(4).string = upper(['PRCT: ' num2str(vr.session.pCorrect)]);
        vr.text(5).string = upper(['LENGTH: ', num2str(vr.trial(vr.tN).stemLength)]);
        vr.text(7).string = upper(['TDIST: ', num2str(abs(vr.trial(vr.tN).correctTarget(1)))]);
        vr.text(10).string = upper(['ITI: ', num2str(abs(vr.trial(vr.tN).itiDuration))]);
        vr.text(12).string = upper(['BLACKOUT: ', num2str(abs(vr.trial(vr.tN).itiBlackout))]);
        vr.text(13).string = upper(['MAXBLKOUT: ', num2str(abs(vr.trial(vr.tN).itiMaxBlackout))]);

    end
end
%% update iter things that are not condition-dependent and that may have been altered during the iteration

vr.iter(vr.iN).trialN = vr.tN;
vr.iter(vr.iN).isITI = vr.isITI;
vr.iter(vr.iN).position = vr.position;
vr.iter(vr.iN).velocity = vr.velocity;
vr.iter(vr.iN).pitchRollYaw = mvData;



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
delete(instrfind);
