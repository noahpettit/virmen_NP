function code = tAlternatingTest
% linearTrackNew   Code for the ViRMEn experiment linearTrackNew.
%   code = linearTrackNew   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)

%% TODO:
% test reward delivery function & calibrate
% write function for increasing the length of the maze (or general function
% for refreshing world vertices after changing experiment variable)
% write termination code 
% calibrate virmen unit to cm conversion & decide on ball gain 
% add ability to push button to give reward manually


% set whether in debug mode:
vr.debugMode = 0;
vr.imaging = 0;
vr.drawText = 1;
vr.save = 1;

%
vr.nTextFields = 7;

% initialize vr.session
% vr.session contains all variables that do not vary trial-by-trial. One
% copy of this is saved at the end of each session.
vr.session = struct(...
    'experimenterRigID', 'lynn_behaviorRig1',...
    'mazeName','tAlternating',... % change this to get the actual maze name from vr 
    'mouseNum', vr.exper.variables.mouseNumber, ...
    'rewardSizeML', 0.004, ...
    ... % ITI parameters
    'incorrectITI', 1,...
    'correctITI', 1, ...
    'minITI',1,...
    'maxITI',15,...
    'incrementITI',0,...
    ... % stem length parameters
    'minStemLength', 100, ...
    'maxStemLength', 100, ...
    'incrementStemLength',3,...
    ... % Arm length parameters
    'minArmLength',2,...
    'maxArmLength',50,...
    'incrementArmLength',3,...
    ... % RPM parameters
    'targetRPM',4, ...
    'minRPM',0.2, ...
    ... % Movement gain parameters
    'forwardGain', -100, ...
    'viewAngleGain', -2, ...
    ... % trial timeout duration
    'trialMaxDuration', 45, ...
    ... % parameters recorded during / throughout the session
    'tic', tic,... 
    'startTime', now(), ... 
    'stopTime', [], ...
    'nTrials', 0, ...
    'nCorrect', 0, ...
    'pCorrect', 0, ...
    'nRewards', 0, ...
    'itiChoiceVisible', 1 ...
    );

% initialize vr.trialInfo
% vr.trial contains all information about individual trials
% trial info is saved in every ITI of the subsequent trial. therefore only
% complete trials are included.
vr.trial = struct(...
    'tic',tic,...
    'trialN', 1,...
    'stemLength', 100,... % length of the stem
    'armLength', eval(vr.exper.variables.armLength),... % length of the arms
    'correctTarget', [0 0],... % XY coordinate defining the center of the reward zone
    'correctRadius', eval(vr.exper.variables.width)/2 + 2*eval(vr.exper.variables.edgeRadius),... % distance that the mouse needs to be from the reward location to get the reward
    'incorrectTarget',[0 0],... % XY coordinate defining the center of the incorrect/punishment zone
    'incorrectRadius',eval(vr.exper.variables.width)/2 + 2*eval(vr.exper.variables.edgeRadius),... % distance that the mouse needs to be from incorrect loication for the trial to be counted as incorrect
    'startPosition', [0 -(vr.session.minStemLength-vr.exper.variables.edgeRadius-0.1) eval(vr.exper.variables.mouseHeight) pi/2],... % position vector [X Y Z theta] defining where the mouse started the trial
    'endPosition', [],... % position vector [X Y Z theta] defining where the mouse ended the trial
    'targetDir', [], ... % target direction = sign of target position X value.
    'turnDir',[],... % turn direction = sign of end position X value. 
    'duration', [],... % duration of the trial in seconds
    'itiDuration', vr.session.minITI,... % duration of the post-trial ITI in seconds
    'trialStartTimeAbs', toc(vr.session.tic),... % time the trial started, relative to session start time
    'trialStopTimeAbs', [],... % time trial ended, relative to session start time
    'rewardN', 0,... % total number of rewards given on that trial
    'isCorrect', [], ... % whether the mouse got the trial correct
    'isTimeout', [] ...
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

vr.trial
% randomize first turn direction
vr.trial(vr.tN).targetDir = sign(rand(1)-0.5);
vr.trial(vr.tN).startingPosition = [0 -(vr.trial(vr.tN).stemLength-vr.exper.variables.edgeRadius-0.1) eval(vr.exper.variables.mouseHeight) pi/2];
% set arm length & stem length
vr.exper.variables.stemLength = num2str(vr.trial(vr.tN).stemLength);
vr.exper.variables.armLength = num2str(vr.trial(vr.tN).armLength);
% reload world to update arm length
vr.worlds{1} = loadVirmenWorld(vr.exper.worlds{1});
% set reward positions
vr.trial(vr.tN).correctTarget = ...
    [vr.trial(vr.tN).targetDir*(vr.trial(vr.tN).armLength+eval(vr.exper.variables.width)/2), eval(vr.exper.variables.width)];
vr.trial(vr.tN).incorrectTarget = ...
    [-1*vr.trial(vr.tN).targetDir*(vr.trial(vr.tN).armLength+eval(vr.exper.variables.width)/2), eval(vr.exper.variables.width)];

vr.position = vr.trial(vr.tN).startPosition;
%vr.exper.variables.stemLength = vr.trial(vr.tN).stemLength;

%% define helper functions
vr.fun.euclideanDist = @(XY1,XY2)(sqrt(sum((XY1-XY2).^2)));

% place correct target tower at correct location

% place incorrect target tower at incorrect location

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
copyfile('C:\Users\harveylab\Desktop\virmen_NP',virmenArchivePath);
disp('virmen code archived');

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

% increment trial duration
vr.trial(vr.tN).duration = toc(vr.trial(vr.tN).tic);

if vr.keyPressed==82;
    if ~vr.debugMode
        vr = giveReward(vr,1);
    end
    vr.trial(vr.tN).rewardN = vr.trial(vr.tN).rewardN+1;
    vr.iter(vr.iN).rewardN = vr.iter(vr.iN).rewardN+1;
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
    if toc(vr.trial(vr.tN).itiTic)>vr.trial(vr.tN).itiDuration
        vr.isITI = 0;
        % increment the trial number
        vr.tN = vr.tN+1;
        vr.trial(vr.tN).tic = tic;
        % set the mouse's start position
        vr.position = vr.trial(vr.tN).startPosition;
        % make the world visible
        vr.worlds{1}.surface.visible(:) = 1;
    else
        % wait.
        % set mouse position to the start position
        vr.position = vr.trial(vr.tN).startPosition;
    end
    
    
    % otherwise, if the mouse is within correctRadius distance of the correct location, deliver the reward, start the ITI, and save the files
elseif vr.fun.euclideanDist(vr.position(1:2),vr.trial(vr.tN).correctTarget)<vr.trial(vr.tN).correctRadius
    % trial is correct
    vr.mazeEnded = 1;
    vr.trial(vr.tN).isCorrect = 1;
    % deliver reward
    if ~vr.debugMode
        vr = giveReward(vr,1);
    end
    vr.trial(vr.tN).rewardN = vr.trial(vr.tN).rewardN+1;
    vr.iter(vr.iN).rewardN = vr.iter(vr.iN).rewardN+1;
    
    %vr.trial(vr.tN).itiDuration = vr.session.correctITI;
    
    % otherwise, if the mouse is within the incorrect radius of the incorrect
    % location, end the trial and commence timeout. OR if the trial timeout
    % has been reached %% WARNING HARDCODED 30 s timeout
elseif (vr.fun.euclideanDist(vr.position(1:2),vr.trial(vr.tN).incorrectTarget)<vr.trial(vr.tN).incorrectRadius) ...
        || toc(vr.trial(vr.tN).tic) > vr.session.trialMaxDuration
    % trial is incorrect
    vr.mazeEnded = 1;
    vr.trial(vr.tN).isCorrect = 0;
    vr.trial(vr.tN).isTimeout = 1;
    % vr.trial(vr.tN).itiDuration = vr.session.incorrectITI;
    
    
end

% if the incorrect or correct zones were reached, determine the conditions of the next trial.
if vr.mazeEnded
    % save end position
    vr.trial(vr.tN).endPosition = vr.position;
    vr.trial(vr.tN).turnDir = sign(vr.position(1));
    % make world invisible
    vr.worlds{1}.surface.visible(:) = 0;
    % enter the ITI
    vr.isITI = 1;
    % start the ITI counter
    vr.trial(vr.tN).itiTic = tic;
    
    % if the mouse has not gotten a reward in the last 5 minutes, give it a
    % reward.
    durationWithoutReward = 0;
    for k = vr.tN:-1:1
        if vr.trial(k).rewardN==0
            durationWithoutReward = durationWithoutReward + vr.trial(k).duration;
            if durationWithoutReward > 60/vr.session.minRPM
                if ~vr.debugMode
                    vr = giveReward(vr,1);
                end
                vr.trial(vr.tN).rewardN = vr.trial(vr.tN).rewardN+1;
                vr.iter(vr.iN).rewardN = vr.iter(vr.iN).rewardN+1;
                break
            end
        else
            break
        end
    end

    % update performance metrics
    vr.session.nTrials = vr.tN-1;
    vr.session.nCorrect = sum([vr.trial(1:max(1,vr.tN-1)).isCorrect]);
    vr.session.pCorrect = vr.session.nCorrect/vr.session.nTrials;
    
    % save the previous trial data
    if vr.tN>1 && vr.save
        vr = saveTrial(vr,vr.tN-1);
    end
    
%% update next trial params that stay the same
    
    vr.trial(vr.tN+1).startPosition =  vr.trial(vr.tN).startPosition;
    vr.trial(vr.tN+1).armLength = vr.trial(vr.tN).armLength;
    vr.trial(vr.tN+1).correctRadius = vr.trial(vr.tN).correctRadius;
    vr.trial(vr.tN+1).incorrectRadius = vr.trial(vr.tN).incorrectRadius;

    
    %% update next trial parameters that change:
    % compute rewards per minute as if every trial was like this one & was
    rewardsPerMinute = vr.trial(vr.tN).rewardN*(60/(vr.trial(vr.tN).duration+vr.trial(vr.tN).itiDuration));
    
    if rewardsPerMinute > vr.session.targetRPM
        % make the maze harder by increasing the ITI of the subsequent
        vr.trial(vr.tN+1).itiDuration = vr.trial(vr.tN).itiDuration + vr.session.incrementITI;
    else
        % make the maze easier by making it shorter
        vr.trial(vr.tN+1).itiDuration = max(vr.session.minITI, vr.trial(vr.tN).itiDuration - vr.session.incrementITI);
    end
    
    % set the correct and incorrect target positions 
    vr.trial(vr.tN+1).targetDir = -1*vr.trial(vr.tN).turnDir;
    vr.trial(vr.tN+1).correctTarget = ...
    [vr.trial(vr.tN+1).targetDir*(vr.trial(vr.tN+1).armLength+eval(vr.exper.variables.width)/2), eval(vr.exper.variables.width)];
    vr.trial(vr.tN+1).incorrectTarget = ...
    [-1*vr.trial(vr.tN+1).targetDir*(vr.trial(vr.tN+1).armLength+eval(vr.exper.variables.width)/2), eval(vr.exper.variables.width)];
    
    vr.trial(vr.tN+1).trialN = vr.tN+1;
    vr.trial(vr.tN+1).rewardN = 0;
    
    %% update maze for next trial
    %vr.exper.variables.stemLength = vr.trial(vr.tN+1).stemLength;
    
    %% update text boxes
    if vr.drawText
        vr.text(6).string = upper(['RPM: ', num2str(rewardsPerMinute)]);
    end
    
    vr.mazeEnded = 0;
    
end

%%
    if vr.drawText
        vr.text(1).string = upper(['TIME: ' datestr(now-vr.session.startTime,'HH.MM.SS')]);
        vr.text(2).string = upper(['TRIALS: ' num2str(vr.session.nTrials)]);
        vr.text(3).string = upper(['REWARDS: ' num2str(sum([vr.trial(:).rewardN]))]);
        vr.text(4).string = upper(['PRCT: ' num2str(vr.session.pCorrect)]);
        vr.text(5).string = upper(['ITI: ', num2str(vr.trial(vr.tN).itiDuration)]);
    end

%% update iter things that are not condition-dependent and that may have been altered during the iteration

vr.iter(vr.iN).trialN = vr.tN;
vr.iter(vr.iN).isITI = vr.isITI;
vr.iter(vr.iN).position = vr.position;
vr.iter(vr.iN).velocity = vr.velocity;
vr.iter(vr.iN).pitchRollYaw = mvData;



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
% if vr.save
% save([vr.session.savePathFinal, filesep, vr.session.baseFilename '_vr.mat'], 'vr', '-v7.3');
% end
