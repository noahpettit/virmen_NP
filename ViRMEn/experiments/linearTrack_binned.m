function code = linearTrack_binned
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
% vr.debugMode = 0;
% % vr.imaging = 0;
vr.drawText = 1;
% vr.save = 0;
daqreset;
%

% initialize vr.session
vr.session = [];
vr.session = struct(...
    ...% default entries
    'sessionID', [vr.exper.variables.mouseID '_' datestr(now,'YYmmDD_hhMMss')], ...
    'rig',vr.exper.variables.rig,...
    'experimentName', mfilename, ...
    'startTime',now(),...
    'experimentCode', mfilename,... % change this to get the actual maze name from vr
    ... % custom fields
    'trialMaxDuration', 90, ... % timeout countdown clock in seconds
    'targetRPM',1 ...
    ); 

s.session.trialTypeNames = {'linearTrack','world1','world2'};
% names of variables (fields in vr) that will be saved on each iteration,
% followed by the number of elements in each of those.
% Each variable will be flattened and saved in a
% binary file in the order specified in saveVar.
vr.saveOnIter = {...
    'rawMovement',4;...
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
% PROBLEM: we have 3 different terms for "trial type".
% "world","condition",and "type". these should really all be rolled into one.... 
vr.trial(1:5000,1) = struct(...
    ...% the standard fields 
    'N',0,...
    'duration',0,...
    'totalReward',0,...
    'isCorrect',0,...
    'type',1,... % in this maze the trial type and the world are the same? This generates some redundancy and confusion
    'start',0,...
...%'world',vr.currentWorld,... % FOR NOW ASSUMING THAT WORLD IS "TYPE". I don't really see any major disadvantage to this at the moment (except that loading the world is time intensive)
    ...% general fields to all mazes:
    'startPosition', [0 14 eval(vr.exper.variables.mouseHeight) pi/2],... % position vector [X Y Z theta] defining where the mouse started the trial
... %%'endPosition', [],... % position vector [X Y Z theta] defining where the mouse ended the trial
    'blackoutDuration',5,... % "blackout" ITI at the beginning of trial
    'isTimeout', 0, ...  % whether the trial timed out   
...% 'stemLength',800 ...
... maze-sepcific fields:
... %     'rewardCondition',1,... assuming that this is the same as trial.type to avoid confustion.
    'licksInBin',[],...
    'rewardInBin',[],...
    'punishmentInBin',[]...
    );


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

% set up the path
vr.ops = getRigSettings;
vr = initDAQ(vr);
vr = initPath(vr);
vr = initTextboxes(vr,16);

%% define the reward and punishment locations (conditions) for each maze

binEdges = 0:100:800;
% reward conditions are matched to world number, so will be matched to
% watever vr.currentWorld is. 

baselineRProb = 0.2;

n = 1;
rProb = [0 0 0 0 0 0 0 1]';
pProb = rProb*0; % no punishment in pre-training
rProb(rProb==0 & pProb==0) = baselineRProb;

vr.condition(n).binEdges = binEdges;
vr.condition(n).rProb = rProb;
vr.condition(n).pProb = pProb;
vr.condition(n).requiresLick = true;

% first real maze - maze 2
n = 2;
rProb = [0 0 0 0 0 1 0 0]';
pProb = [0 0 1 0 0 0 0 0]';
rProb(rProb==0 & pProb==0) = baselineRProb;

vr.condition(n).binEdges = binEdges;
vr.condition(n).rProb = rProb;
vr.condition(n).pProb = pProb;
vr.condition(n).requiresLick = true;

% second real maze = maze 3
n = 3;
rProb = [0 1 0 0 0 0 0 0]';
pProb = [0 0 0 0 0 1 0 0]';
rProb(rProb==0 & pProb==0) = baselineRProb;

vr.condition(n).binEdges = binEdges;
vr.condition(n).rProb = rProb;
vr.condition(n).pProb = pProb;
vr.condition(n).requiresLick = true;

% third real maze = maze 4
n = 4;
rProb = [0 1 0 0 0 0 0 0]';
pProb = [0 0 0 0 0 1 0 0]';
rProb(rProb==0 & pProb==0) = baselineRProb;
vr.condition(n).binEdges = binEdges;
vr.condition(n).rProb = rProb;
vr.condition(n).pProb = pProb;
vr.condition(n).requiresLick = true;

%%
[vr.trial.licksInBin] = deal(vr.condition(1).rProb.*0);
[vr.trial.rewardInBin] = deal(vr.condition(1).rProb.*0);
[vr.trial.punishmentInBin] = deal(vr.condition(1).rProb.*0);

%% initialize first trial
vr.tN = 1;

vr.mazeEnded = 0;
vr.trialEnded = 0;

vr.trial(vr.tN).N = vr.tN;
vr.trial(vr.tN).start = now();
vr.position = vr.trial(vr.tN).startPosition;

%% Save copy of the virmen directory exactly as it is when this code is run
archiveVirmenCode(vr);
vr = getGitHash(vr);

vr.iN = 0;

vr.lastLickCount = 0;
vr.ci.resetCounters;
vr.analogSyncPulse = 1;
vr.digitalSyncPulse = 0;
vr = outputSyncPulse(vr);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
% first output synch pulse 

%

% increment iteration counter
global mvData;

newCount = vr.ci.inputSingleScan;
vr.isLick = newCount - vr.lastLickCount; 
vr.lastLickCount = newCount;

vr.rawMovement = mvData;
vr.iN = vr.iN+1;
vr.reward = 0;
vr.punishment = 0;
vr.isVisible = ~vr.isBlackout;

cond = vr.trial(vr.tN).type;
binN = find(vr.condition(cond).binEdges<vr.position(2),1,'last');

switch vr.keyPressed 
    case 76 % L key
        vr.isLick = 1;
    case 82
        % R key to deliver reward manually
        vr = giveReward(vr,20);
        vr.trial(vr.tN).totalReward = vr.trial(vr.tN).totalReward+1;
    case 80
        vr = giveAirpuff(vr,0.5);
    case 49
        % "1" key pressed: switch world to world 1 
        [vr.trial(vr.tN+1:end).type] = deal(1);
    case 50
        % "2" key pressed: switch world to world 2 
        [vr.trial(vr.tN+1:end).type] = deal(2);
    case 51
        % "3" key pressed: switch world to world 3 
        [vr.trial(vr.tN+1:end).type] = deal(3);
end

if ~isnan(vr.keyPressed)
disp(vr.keyPressed);
end

if vr.isLick
    disp('lick!');
end


% if isfield(vr.ao.addAnalogOutputChannel
%     vr = iterGradedVoltage(vr); % graded pulse indicating mod(iterationNumber,10)
%     vr = iterRandomPulse(vr); % random one or zero
% end

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

% check to see if the mouse is at the end of the maze
elseif vr.position(2)>=780
    vr.mazeEnded = 1;
    vr.trial(vr.tN).isTimeout = 0;
    
% check to see if the mouse has licked
elseif vr.isLick
    % get the mouse's binned position in the maze

    % find out if the mouse has already licked in this bin
    if vr.trial(vr.tN).licksInBin(binN) == 0
        % mouse has not licked in the bin
        if rand<=vr.condition(cond).rProb(binN)
            % give reward
            vr = giveReward(vr,1);
            vr.trial(vr.tN).totalReward = vr.trial(vr.tN).totalReward+1;
        end
        if rand<=vr.condition(cond).pProb(binN)
            % give punishment (air puff)
            vr = giveAirpuff(vr,1);
            vr.punishment = vr.punishment + 1;
        end
    end
    vr.trial(vr.tN).licksInBin(binN) = vr.trial(vr.tN).licksInBin(binN)+1;      
end

%% MAZE END
if vr.mazeEnded
    vr.mazeEnded = 0;
    vr.worlds{cond}.surface.visible(:) = 0;
    vr.blackoutTic = tic;
    vr.isBlackout = 1;
    vr.isVisible = 0;
end

%% TRIAL END
if vr.trialEnded
    disp('trial ended');
    vr.trial(vr.tN).duration = (now-vr.trial(vr.tN).start)*(24*60*60);
 
    % update performance metrics
    vr.session.nTrials = vr.tN;
    vr.session.nCorrect = sum([vr.trial(:).isCorrect]);
    vr.session.nRewards = num2str(sum([vr.trial(:).totalReward]));

    %% SAVE DATA
    
    vr = saveTrial(vr);
    disp('trial data saved');

    %% NEW TRIAL STARTS HERE     
    vr.trialEnded = 0;
    vr.tN = vr.tN+1;
    vr = outputSyncPulse(vr);
    
    vr.trial(vr.tN).start = now();
    vr.trial(vr.tN).N = vr.tN;    
    vr.trial(vr.tN).rewardN = 0;
    vr.trial(vr.tN).startPosition =  [0 randi([12,112]) eval(vr.exper.variables.mouseHeight) pi/2];
    
    %% update text boxes
    cond = vr.trial(vr.tN).type;
    
    %% set the new maze
    vr.position = vr.trial(vr.tN).startPosition;
    vr.currentWorld = vr.trial(vr.tN).type;
    vr.worlds{cond}.surface.visible(:) = 1;
    vr.drawText = 1;
    

end

% % draw the text
if vr.drawText
    vr.text(1).string = upper(['TIME: ' datestr(now-vr.session.startTime,'HH.MM.SS')]);
    vr.text(2).string = upper(['TRIAL: ' num2str(vr.tN)]);
    vr.text(3).string = upper(['REWARDS: ' num2str(sum([vr.trial(:).totalReward]))]);
    vr.text(4).string = upper(['CC: ' num2str(vr.trial(vr.tN).type)]);
    vr.text(5).string = upper(['NC: ' num2str(vr.trial(vr.tN+1).type)]);
    
if vr.isLick
    vr.text(6).string = upper(['LICK! ']);
else
    vr.text(6).string = upper(['']);
end

    %% compute the stats to show
    ind = [vr.trial(:).type]==vr.trial(vr.tN).type;
    ind(vr.tN+1:end) = 0;
%     nBins = numel(vr.trial(vr.tN).licksInBin);
    avgLick = mean([vr.trial(ind).licksInBin]>0,2);
    avgReward = mean([vr.trial(ind).rewardInBin]>0,2);
    avgPunishment = mean([vr.trial(ind).punishmentInBin]>0,2);


    vr.text(7).string = upper(['BIN: ', num2str(binN)]);
    vr.text(8).string = upper(['L: ', num2str(vr.trial(vr.tN).licksInBin')]);
    
    
vr.text(9).string = upper(['AL: ', num2str(round(avgLick',1))]);
vr.text(10).string = upper(['AR: ', num2str(round(avgReward',1))]);
vr.text(11).string = upper(['AP: ', num2str(round(avgPunishment',1))]);


vr.text(11).string = upper(['TTYPE: ', num2str(vr.trial(vr.tN).type)]);
%     vr.text(10).string = upper(['FRZN: ', num2str(abs(vr.trial(vr.tN).frozenDuration))]);
%     vr.text(12).string = upper(['BO: ', num2str(abs(vr.trial(vr.tN).blackoutDuration))]);
%     vr.text(13).string = upper(['MAXBO: ', num2str(abs(vr.trial(vr.tN).itiMaxBlackout))]);
%     vr.text(14).string = upper(['FR: ' num2str(round(length(vr.iter)/toc(vr.iter(1).tic)))]);
%     vr.text(15).string = upper(['LRTG: ' num2str(rad2deg(vr.trial(vr.tN-1).rewardTowerDeg))]);
%     vr.text(16).string = upper(['LEVELUP: ' num2str(vr.session.criterionReached)]);
end
vr.drawText = 1;
% % save the iteration
vr = saveIter(vr);


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

fclose(vr.iterFileID);
fclose(vr.trialFileID);
