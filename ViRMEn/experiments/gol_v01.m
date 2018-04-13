function code = gol_v01
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
    'trialMaxDuration', 45, ... % timeout countdown clock in seconds
    'targetRPM',8, ...
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
    'manualReward',1;...
    'manualAirpuff',1;...
    'punishment',1;...
    'isFrozen',1;... % whether the world is forzen
    'trialEnded',1;...
    'isBlackout',1;...
    'mazeEnded',1;...
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
    'startPosition', [0 0 eval(vr.exper.variables.mouseHeight) pi/2],... % position vector [X Y Z theta] defining where the mouse started the trial
... %%'endPosition', [],... % position vector [X Y Z theta] defining where the mouse ended the trial
    'blackoutDuration',0,... % "blackout" ITI at the beginning of trial
    'isTimeout', 0 ...  % whether the trial timed out   
    );

%% define the reward and punishment locations (conditions) for each maze
vr.session.trialTypeNames = {'lineara','linearb','world1a','world1b','world2a','world2b'};

n = 1;
vr.condition(n).rewardLocations = [5 65 125 140 188 212 318 451];
vr.condition(n).rewardsPerLocation = [4 4 4 4 4 4 4 4];
vr.condition(n).rewardProb = [1 1 1 1 1 1 1 1]; 
vr.condition(n).world = 1;

n = 2;
vr.condition(n).rewardLocations = [5 188 451];
vr.condition(n).rewardsPerLocation = [4 4 4];
vr.condition(n).rewardProb = [1 1 1]; 
vr.condition(n).world = 1;

n = 3;
vr.condition(n).rewardLocations = [100];
vr.condition(n).rewardsPerLocation = [4];
vr.condition(n).rewardProb = [1]; 
vr.condition(n).world = 2;

n = 4;
vr.condition(n).rewardLocations = [300];
vr.condition(n).rewardsPerLocation = [4];
vr.condition(n).rewardProb = [1]; 
vr.condition(n).world = 2;

n = 5;
vr.condition(n).rewardLocations = [300];
vr.condition(n).rewardsPerLocation = [4];
vr.condition(n).rewardProb = [1]; 
vr.condition(n).world = 3;

n = 6;
vr.condition(n).rewardLocations = [100];
vr.condition(n).rewardsPerLocation = [4];
vr.condition(n).rewardProb = [1]; 
vr.condition(n).world = 3;


vr.rewardLocationsRemaining = [];
vr.localRewardsRemaining = [];
vr.currentRewardLocation = [];


%% common init
vr = commonInit(vr);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

vr = commonRuntime(vr,'iterStart');

if vr.position(2)>400
    vr.trialEnded = 1;
    vr.position(2) = vr.position(2)-400;
end

if abs(vr.currentRewardLocation-vr.position(2))>10
    vr.localRewardsRemaining = 0;
end

if vr.isLick
    if vr.localRewardsRemaining>0
        vr = giveReward(vr,vr.session.rewardSize);
        vr.localRewardsRemaining = vr.localRewardsRemaining - 1;
        
    elseif min(abs(vr.rewardLocationsRemaining-vr.position(2)))<=10
        % find reward location
        [~,i] = min(abs(vr.rewardLocationsRemaining-vr.position(2)));
        vr.currentRewardLocation = vr.rewardLocationsRemaining(i);
        vr.rewardLocationsRemaining(i) = [];
        ind=find(vr.condition(r.trial(vr.tN).type).rewardLocations==vr.currentRewardLocation);
        vr.localRewardsRemaining = vr.condition(r.trial(vr.tN).type).rewardsPerLocation(ind);
        
        vr = giveReward(vr,vr.session.rewardSize);
        vr.localRewardsRemaining = vr.localRewardsRemaining - 1;
    else
        % do nothing.
    end    
end

% if mouse passes end of the maze, reset the trial & rewards 
if vr.trialEnded
    vr = commonRuntime(vr,'trialEnd');
    
    % set the current type     
    vr.currentWorld = vr.condition(vr.trial(vr.tN).type).world;
    vr.rewardLocationsRemaining = vr.condition(vr.trial(vr.tN).type).rewardLocations;
end

vr = commonRuntime(vr,'iterEnd');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
vr = commonTermination(vr);