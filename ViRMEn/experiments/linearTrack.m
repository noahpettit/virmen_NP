function code = linearTrack
% SingleTower4Cond   Code for the ViRMEn experiment SingleTower4Cond.
%   code = SingleTower4Cond   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

% set whether debug mode:
vr.debugMode = true;
% if you are in debug mode the daq will not be initialized

%initialize important cell information
vr.conds = {'Linear Track'};
vr.mouseNum = vr.exper.variables.mouseNum;
if ischar(vr.mouseNum)
    vr.mouseNum = str2double(vr.mouseNum);
    vr.exper.variables.mouseNum = str2double(vr.exper.variables.mouseNum);
end

%Define indices of walls
vr.cueWallLeftBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.cueWallLeftBlack,:);
vr.cueWallLeftWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.cueWallLeftWhite,:);
vr.cueWallRightBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.cueWallRightBlack,:);
vr.cueWallRightWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.cueWallRightWhite,:);
vr.frontWall = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.frontWall,:);
vr.backWall = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.backWall,:);
vr.tower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.tower,:);
vr.delayWallRight = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.delayWallRight,:);
vr.delayWallLeft = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.delayWallLeft,:);
vr.startLocationCurrent = vr.worlds{1}.startLocation;

vr = initializePathVIRMEN(vr);

vr.adjustmentFactor = 0.01;
vr.minWallLength = eval(vr.exper.variables.wallLengthMin);
vr.lengthFactor = 0;

vr.backWallOriginal = vr.worlds{1}.surface.vertices(:,vr.backWall(1):vr.backWall(2));
vr.wallLength = str2double(vr.exper.variables.wallLength);
vr.length = str2double(vr.exper.variables.wallLengthMin);

vr.edgeIndBackWall = vr.worlds{1}.objects.edges(vr.worlds{1}.objects.indices.backWall,1);
vr.backWallEdges = vr.worlds{1}.edges.endpoints(vr.edgeIndBackWall,:);

vr.backWallCurrent = vr.backWallOriginal(2,:) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
vr.worlds{1}.surface.vertices(2,vr.backWall(1):vr.backWall(2)) = vr.backWallCurrent;
vr.worlds{1}.edges.endpoints(vr.edgeIndBackWall,[2,4]) = vr.backWallEdges([2,4]) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
vr.startLocationCurrent(2) = vr.worlds{1}.startLocation(2) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
vr.position = vr.startLocationCurrent;
vr.cuePos = 1;

vr.inITI = 0;
vr.isReward = 0;

vr.dp = 0;
vr.startTime = now;
vr.trialTimer = tic;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

if vr.inITI == 0 && abs(vr.position(2)) > 485;
% if you are not in the inter-trial interval and are atr the end of the
% maze, get a reward. 
            vr = giveReward(vr,1);
            vr.itiDur = vr.itiCorrect;
            vr.numRewards = vr.numRewards + 1;
    % make the world black
    vr.worlds{1}.surface.visible(:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    vr.numTrials = vr.numTrials + 1;
    % set cellWrite to true so that you save info during the ITI
    vr.cellWrite = true;
else
    vr.isReward = 0;
end


if vr.inITI == 1
% if you are in the inter trial interval
    if vr.cellWrite
        % write the cell data
        [dataStruct] = createSaveStruct(vr.mouseNum,vr.experimenter,...
        vr.conds,vr.whiteMazes,vr.leftMazes,vr.mazeName,vr.cuePos,vr.leftMazes(vr.cuePos),...
        vr.whiteMazes(vr.cuePos),vr.isReward,vr.itiCorrect,vr.itiMiss,vr.isReward ~= 0,vr.leftMazes(vr.cuePos)==(vr.isReward~=0),...
        vr.whiteMazes(vr.cuePos)==(vr.isReward~=0),vr.streak,vr.trialStartTime,rem(now,1),vr.startTime); %#ok<NASGU>
        eval(['data',num2str(vr.numTrials),'=dataStruct;']);
        %save datastruct
        if exist(vr.pathTempMatCell,'file')
            save(vr.pathTempMatCell,['data',num2str(vr.numTrials)],'-append');
        else
            save(vr.pathTempMatCell,['data',num2str(vr.numTrials)]);
        end
        vr.cellWrite = false;
    end
    
    vr.itiTime = toc(vr.itiStartTime);
    if vr.itiTime > vr.itiDur
        % ITI is over
        vr.inITI = 0;
        
        if toc(vr.trialTimer) < 20
            vr.lengthFactor = vr.lengthFactor + vr.adjustmentFactor;
        elseif toc(vr.trialTimer) > 20
            vr.lengthFactor = vr.lengthFactor - vr.adjustmentFactor;
        end
        
        if vr.lengthFactor > 1
            vr.lengthFactor = 1;
        elseif vr.lengthFactor <0
            vr.lengthFactor = 0;
        end
        
        
        vr.backWallCurrent = vr.backWallOriginal(2,:) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
        vr.worlds{1}.surface.vertices(2,vr.backWall(1):vr.backWall(2)) = vr.backWallCurrent;
        vr.worlds{1}.edges.endpoints(vr.edgeIndBackWall,[2,4]) = vr.backWallEdges([2,4]) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
        vr.startLocationCurrent(2) = vr.worlds{1}.startLocation(2) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);    
        vr.length = str2double(vr.exper.variables.wallLengthMin)+ (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
        
        vr.position = vr.startLocationCurrent;
        vr.worlds{1}.surface.visible(:) = 1;
        vr.dp = 0;
        vr.trialTimer = tic;
        vr.trialStartTime = rem(now,1);
    end
end

vr.text(1).string = ['TIME ' datestr(now-vr.startTime,'HH.MM.SS')];
vr.text(2).string = ['TRIALS ', num2str(vr.numTrials)];
vr.text(3).string = ['REWARDS ',num2str(vr.numRewards)];
vr.text(4).string = ['LENGTH ',num2str(vr.length)];

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
commonTerminationVIRMEN(vr);