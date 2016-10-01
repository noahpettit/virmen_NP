function code = tAlternatingTest
% tAlternatingTest   Code for the ViRMEn experiment tAlternatingTest.
%   code = tAlternatingTest   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
vr.counter = tic;
vr.iter = 1;
vr.check = {};


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if toc(vr.counter)>1
    vr.exper.variables.armLength = num2str(str2num(vr.exper.variables.armLength)-5);
    disp(vr.exper.variables.armLength);
    worldLoad = tic;
    vr.worlds{1} = loadVirmenWorld(vr.exper.worlds{1});
    toc(worldLoad)
    vr.currentWorld = 1;

    vr.counter = tic;
    vr.iter = vr.iter+1;
    vr.check{vr.iter} = whos('vr');
end
    





% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
