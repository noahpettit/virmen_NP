function code = linearTrackNew
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
vr.nTextFields = 6;

% initialize vr.session
% vr.session contains all variables that do not vary trial-by-trial. One
% copy of this is saved
% each session.
vr.session = struct(...
    'experimenterRigID', 'lynn_behaviorRig1',...
    'mouseNum', vr.exper.variables.mouseNumber, ...
    'tic', tic,...
    'startTime', now(), ...
    'stopTime', [], ...
    'nTrials', 0, ...
    'nCorrect', 0, ...
    'pCorrect', 0, ...
    'nRewards', 0, ...
    'rewardSizeML', 0.004, ...
    'incorrectITI', 3,...
    'correctITI', 3, ...
    'minStemLength', 3.1, ...
    'maxStemLength', 1000, ...
    'targetRPM',4, ...
    'minRPM',0.2, ...
    'stemLengthIncrement',3, ...
    'forwardGain', -155, ...
    'viewAngleGain', -1, ...
    'trialMaxDuration', 45 ...
    );

% initialize vr.trialInfo
% vr.trial contains all information about individual trials
% trial info is saved in every ITI of the subsequent trial. therefore only
% complete trials are included.

vr.trial = struct(...
    'tic',tic,...
    'trialN', 1,...
    'stemLength', 10,... % length of the stem
    'armLength', 0,... % length of the arms
    'correctTarget', [0 str2num(vr.exper.variables.width)],... % XY coordinate defining the center of the reward zone
    'correctRadius', str2num(vr.exper.variables.width),... % distance that the mouse needs to be from the reward location to get the reward
    'incorrectTarget',[0 0],... % XY coordinate defining the center of the incorrect/punishment zone
    'incorrectRadius',0,... % distance that the mouse needs to be from incorrect loication for the trial to be counted as incorrect
    'startPosition', [0 0 eval(vr.exper.variables.mouseHeight) pi/2],... % position vector [X Y Z theta] defining where the mouse started the trial
    'endPosition', [],... % position vector [X Y Z theta] defining where the mouse ended the trial
    'duration', [],... % duration of the trial in seconds
    'itiDuration', 3,... % duration of the post-trial ITI in seconds
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
    'startTimeInSession',[] ... % time in session (from session start)
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
vr.text(5).string = upper(['LENGTH: ', num2str(vr.trial(vr.tN).stemLength)]);
end

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

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
    
    vr.trial(vr.tN).itiDuration = vr.session.correctITI;
    
    % otherwise, if the mouse is within the incorrect radius of the incorrect
    % location, end the trial and commence timeout. OR if the trial timeout
    % has been reached %% WARNING HARDCODED 30 s timeout
elseif (vr.fun.euclideanDist(vr.position(1:2),vr.trial(vr.tN).incorrectTarget)<vr.trial(vr.tN).incorrectRadius) ...
        || toc(vr.trial(vr.tN).tic) > vr.session.trialMaxDuration
    % trial is incorrect
    vr.mazeEnded = 1;
    vr.trial(vr.tN).isCorrect = 0;
    vr.trial(vr.tN).isTimeout = 1;
    vr.trial(vr.tN).itiDuration = vr.session.incorrectITI;
    
    % if the mouse has not gotten a reward in the last 5 minutes, give it a
    % reward.
    durationWithoutReward = 0;
    for k = vr.tN-1:-1:1
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
    
end

% if the incorrect or correct zones were reached, determine the conditions of the next trial.
if vr.mazeEnded
    
    % save end position
    vr.trial(vr.tN).endPosition = vr.position;
    % make world invisible
    vr.worlds{1}.surface.visible(:) = 0;
    % enter the ITI
    vr.isITI = 1;
    % start the ITI counter
    vr.trial(vr.tN).itiTic = tic;
    
    % update performance metrics
    vr.session.nTrials = vr.tN-1;
    vr.session.nCorrect = sum([vr.trial(1:max(1,vr.tN-1)).isCorrect]);
    vr.session.pCorrect = vr.session.nCorrect/vr.session.nTrials;
    
    % save the previous trial data
    if vr.tN>1 && vr.save
        vr = saveTrial(vr,vr.tN-1);
    end
    
    %% update next trial parameters that change:
    % compute rewards per minute as if every trial was like this one
    vr.trial(vr.tN).duration = toc(vr.trial(vr.tN).tic);
    rewardsPerMinute = 60/(vr.trial(vr.tN).duration+vr.trial(vr.tN).itiDuration);
    
    if rewardsPerMinute > vr.session.targetRPM
        % make the maze harder by making it longer
        vr.trial(vr.tN+1).stemLength = vr.trial(vr.tN).stemLength + vr.session.stemLengthIncrement;
    else
        % make the maze easier by making it shorter
        vr.trial(vr.tN+1).stemLength = max(vr.session.minStemLength, vr.trial(vr.tN).stemLength - vr.session.stemLengthIncrement);
    end
    
    vr.trial(vr.tN+1).trialN = vr.tN+1;
    vr.trial(vr.tN+1).startPosition = [0 -vr.trial(vr.tN+1).stemLength+str2num(vr.exper.variables.edgeRadius)+1 str2num(vr.exper.variables.mouseHeight) pi/2];
    vr.trial(vr.tN+1).rewardN = 0;
    
    %% update next trial params that stay the same
    
    vr.trial(vr.tN+1).armLength = vr.trial(vr.tN).armLength;
    vr.trial(vr.tN+1).correctTarget = vr.trial(vr.tN).correctTarget;
    vr.trial(vr.tN+1).correctRadius = vr.trial(vr.tN).correctRadius;
    vr.trial(vr.tN+1).incorrectTarget = vr.trial(vr.tN).incorrectTarget;
    vr.trial(vr.tN+1).incorrectRadius = vr.trial(vr.tN).incorrectRadius;
    
    %% update maze for next trial
    %vr.exper.variables.stemLength = vr.trial(vr.tN+1).stemLength;
    
    %% update text boxes
    if vr.drawText
        vr.text(6).string = upper(['RPM: ', num2str(60/(vr.trial(vr.tN).duration+vr.trial(vr.tN).itiDuration))]);
    end
    
    vr.mazeEnded = 0;
    
end

%%
    if vr.drawText
        vr.text(1).string = upper(['TIME: ' datestr(now-vr.session.startTime,'HH.MM.SS')]);
        vr.text(2).string = upper(['TRIALS: ' num2str(vr.session.nTrials)]);
        vr.text(3).string = upper(['REWARDS: ' num2str(sum([vr.trial(:).rewardN]))]);
        vr.text(4).string = upper(['PRCT: ' num2str(vr.session.pCorrect)]);
        vr.text(5).string = upper(['LENGTH: ', num2str(vr.trial(vr.tN).stemLength)]);
    end

%% update iter things that are not condition-dependent and that may have been altered during the iteration

vr.iter(vr.iN).trialN = vr.tN;
vr.iter(vr.iN).isITI = vr.isITI;
vr.iter(vr.iN).position = vr.position;
vr.iter(vr.iN).velocity = vr.velocity;



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if vr.save
save([vr.session.savePathFinal, filesep, vr.session.baseFilename '_vr.mat'], 'vr', '-v7.3');
end
