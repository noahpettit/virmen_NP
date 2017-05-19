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
    'sessionID', [vr.exper.variables.experimenter vr.exper.variables.mouseNumber '_' datestr(now,'YYmmDD_hhMMss')], ...
    'experimenterRigID', 'lynn_behaviorRig2',... % used for initializing the saving file path 
    'nTrials', 0, ...
    'nCorrect', 0, ...
    'totalReward', 0, ...
    'trialTypeNames',{'linear track'},...
    'experimentCode', mfilename,... % change this to get the actual maze name from vr
    ... % reward parameters
    'rewardSizeML', 0.0034, ...
    ... % trial duration parameters
    'trialMaxDuration', 45, ... % timeout countdown clock
    ... % RPM parameters
    'targetRPM',1, ...
    ... % gain parameters - perhaps move these to be hard-coded into movement function?
    'forwardGain', -150, ...
    'viewAngleGain', -1.0, ...
    ... % DO NOT CHANGE
    'start', now(), ...
    'stop', [], ...
    'criterionReached', 0 ...
    ... % iter field names starting from index 19 in matrix
    ); 

% initialize vr.trialInfo
% vr.trial contains all information about individual trials
% trial info is saved in every ITI of the subsequent trial. therefore only
% complete trials are included.
vr.trial(1:5000,1) = struct(...
    ...% the standard fields 
    'N',0,...
    'duration',0,...
    'totalReward',0,...
    'isCorrect',0,...
    'type',1,...
    'start',0,...
    ...% general fields to all mazes:
    'startPosition', [0 10 eval(vr.exper.variables.mouseHeight) pi/2],... % position vector [X Y Z theta] defining where the mouse started the trial
    'endPosition', [],... % position vector [X Y Z theta] defining where the mouse ended the trial
    'frozenDuration',2,... % frozen period at the end of the maze before ITI
    'blackoutDuration',rand(),... % "blackout" ITI at the beginning of trial
    'isTimeout', [], ...  % whether the trial timed out   
    'stemLength',10,...
... maze-sepcific fields:
    'correctCoord',[0 0],...
    'correctRadius',15,...
    'incorrectCoord',[],...
    'incorrectRadius',[]...
    );

% names of variables (fields in vr) that will be saved on each iteration,
% followed by the number of elements in each of those.
% Each variable will be flattened and saved in a
% binary file in the order specified in saveVar.
vr.session.saveVar = {...
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
    'isFrozen',1, ... % whether the world is forzen
    'trialEnded',1,...
    'mazeEnded',1, ...
    'isBlackout',1 ...
};

vr.rawMovement = [];
vr.iN = 0;
vr.tN = 1;
vr.isITI = 0;
vr.isReward = 0;
vr.isLick = 0;
vr.isVisible = 1;
vr.isFrozen = 0;
vr.isBlackout = 0;

% set up the path
vr = initPath(vr,vr.session.experimenterRigID);
vr = initDAQ(vr);
vr = initTextboxes(vr);

%% initialize first trial
vr.mazeEnded = 0;
vr.trialEnded = 0;

vr.trial.N = vr.tN;
vr.trial.start = now();
vr.position = vr.trial(vr.tN).startPosition;
vr.exper.variables.stemLength = num2str(vr.trial(vr.tN).stemLength);

%% define helper functions
vr.fun.euclideanDist = @(XY1,XY2)(sqrt(sum((XY1-XY2).^2)));

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



% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% increment iteration counter
global mvData;
vr.rawMovement = mvData;
vr.iterN = vr.iterN+1;
vr.trialN = vr.tN;
vr.reward = 0;
vr.isVisible = ~vr.isBlackout;

if vr.keyPressed==82 % R key to give reward manually
    vr = giveRewardPump(vr,1);
    vr = rewardTone(vr,1);
    vr.reward = vr.reward + 1;
    vr.trial(vr.tN).totalReward = vr.trial(vr.tN).totalReward+1;
end

if vr.imaging
    vr = iterStartPulse(vr); % pulse indicating the start of the iteration
    vr = iterGradedVoltage(vr); % graded pulse indicating mod(iterationNumber,10)
    vr = iterRandomPulse(vr); % random one or zero
end

%% MAZE CONDITION CHECK
if vr.isFrozen
    if toc(vr.frozenTic)>vr.trial(vr.tN).frozenDuration
        %timer has elapsed, start new trial
        vr.isFrozen = 0;
        vr.trialEnded = 1;
    end
    
% check to see if the mouse is in the ITI
elseif vr.isBlackout
    % check to see if the delay has elasped 
    if toc(vr.blackoutTic)>vr.trial(vr.tN).blackoutDuration
        % then make sure that the world is invisible
        disp('blackout ended');
        vr.position = vr.trial(vr.tN).startPosition;
        vr.worlds{1}.surface.visible(:) = 1;
        vr.exper.movementFunction = @moveWithDualSensors;
        vr.isBlackout = 0;
        vr.isVisible = 1;
    end
    
elseif vr.fun.euclideanDist(vr.position(1:2),vr.trial(vr.tN).correctCoord)<vr.trial(vr.tN).correctRadius
    % animal gets a reward. end the trial. 
    % see see how far the tower is from the center of the field of view;
    rewardTowerDeg = vr.position(4)-cart2pol(vr.trial(vr.tN).correctCoord(1)-vr.position(1),vr.trial(vr.tN).correctCoord(2)-vr.position(2));
    rewardFraction = 0.25+exp(-2*abs(rewardTowerDeg));
    vr.trial(vr.tN).isCorrect = 1;
    vr.isCorrect = 1;
    vr.mazeEnded = 1;
    % deliver reward
    if ~vr.debugMode
        vr = giveRewardPump(rewardFraction);
        vr = rewardTone(vr,rewardFraction);
    end
    vr.trial(vr.tN).totalReward = vr.trial(vr.tN).totalReward + rewardFraction;
    vr.rewardN = rewardFraction;
        
    % otherwise, if the mouse is within the incorrect radius of the incorrect
    
elseif toc(vr.trial(vr.tN).tic) > vr.session.trialMaxDuration
    % trial has timed out
    vr.mazeEnded = 1;
    vr.isCorrect = 0;
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
    vr.frozenTic = tic;
    vr.isFrozen = 1;
    vr.exper.movementFunction = @moveWithKeyboard; 
    
    vr.mazeEnded = 0;
end

%% TRIAL END
if vr.trialEnded
    disp('trial ended');
    vr.trial(vr.tN).endPosition = vr.position;
    vr.trial(vr.tN).duration = (now-vr.trial(vr.tN).start)*(24*60*60);
 
    % update performance metrics
    vr.session.nTrials = vr.tN;
    vr.session.nCorrect = sum([vr.trial(:).isCorrect]);
    vr.session.nRewards = num2str(sum([vr.trial(:).totalReward]));

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
        secCounter = (now-vr.trial(k).start)*(24*60*60);
        rewardCounter = rewardCounter + vr.trial(k).rewardN;
        if secCounter > 60
            break
        end
    end
    rewardsPerMinute = rewardCounter;
    
    %% NEW TRIAL STARTS HERE     
    vr.trialEnded = 0;
    vr.tN = vr.tN+1;
    
    vr.trial(vr.tN).N = vr.tN;
    
    % update conditions based on rpm?
    if rewardsPerMinute > vr.session.targetRPM
    else
    end

    % update conditions based on percentage correct?

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
% draw the text
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
% save the iteration
saveIter(vr);


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
