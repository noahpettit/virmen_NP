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

% set whether in debug mode:
vr.debugMode = true;

% initialize all non[vr.exper]-native variables 
vr.mouseNum = vr.exper.variables.mouseNum;

% set up the path
vr = initializePathVirmen

% define which variables to save

% initialize textboxes

% initialize 


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% check to see if the mouse is in the ITI
% check the timer - if ITI time has elapsed 

% check to see if the mouse is in the reward zone
% YES
% deliver reward
% set world to black
% start ITI counter
% save previous trial data
% update performance metrics
% update onscreen text
% calculate recent rewards per min
% update maze length
% set mouse start position
% 



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
% 
