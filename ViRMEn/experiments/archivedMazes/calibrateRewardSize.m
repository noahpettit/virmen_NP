function code = calibrateRewardSize
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

vr.debugMode = 0;
vr = initDAQ(vr);

vr.nRewards = str2num(vr.exper.variables.nRewards);
vr.pauseDur = str2num(vr.exper.variables.pauseDur);
vr.rewardCount = 0;

%% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)


if vr.rewardCount<vr.nRewards
vr.rewardCount = vr.rewardCount + 1;
giveReward(vr,1);
pause(vr.pauseDur);
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
delete(instrfind);
