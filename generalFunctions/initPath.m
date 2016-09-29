function [vr] = initPath(vr, experimenterRigID)
%INITIALIZEPATHVIRMEN This is a function to initialize virmen path
%information run during the initialization block of all mazes

if nargin<2
    experimenterRigID = 'default';
end

vr.mazeName = func2str(vr.exper.experimentCode);
% vr.exper.variables.mouseNumber = sprintf('%03d',vr.mouseNum); %save mouse num in exper 

% get path info for specific experimenter strings
switch experimenterRigID
    
    case 'default'
        % if experimenterRig was not defined
        vr.experimenter = 'XX';
        path = ['C:\DATA\' vr.experimenter '\currentMice\' vr.experimenter sprintf('%03d',vr.exper.variables.mouseNumber)];
        tempPath = ['C:\DATA\' vr.experimenter '\temp'];
        
    case 'noah_deskPC'
        vr.experimenter = 'NP';
        path = ['C:\DATA\' vr.experimenter '\currentMice\' vr.experimenter sprintf('%03d',vr.exper.variables.mouseNumber)];
        tempPath = ['C:\DATA\' vr.experimenter '\temp'];
        
    case 'noah_behaviorRig1'
        vr.experimenter = 'NP';
        path = ['C:\DATA\' vr.experimenter '\currentMice\' vr.experimenter sprintf('%03d',vr.exper.variables.mouseNumber)];
        tempPath = ['C:\DATA\' vr.experimenter '\temp'];
        
    case 'lynn_behaviorRig1'
        vr.experimenter = 'LY';
        path = ['C:\DATA\' vr.experimenter '\currentMice\' vr.experimenter sprintf('%03d',vr.exper.variables.mouseNumber)];
        tempPath = ['C:\DATA\' vr.experimenter '\temp'];
end

% make directories if they do not already exist 
if ~exist(tempPath,'dir');
    mkdir(tempPath);
end
if ~exist(path,'dir')
    mkdir(path);
end

% now setup all the paths for saving the files
vr.filenameTempMat = 'tempStorage.mat';
vr.filenameTempMatCell = 'tempStorageCell.mat';
vr.filenameTempDat = 'tempStorage.dat';
vr.filenameMat = [vr.experimenter,vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'.mat'];
vr.filenameMatCell = [vr.experimenter,vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_Cell.mat'];
vr.filenameDat = [vr.experimenter,vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'.dat'];
fileIndex = 0;
fileList = what(path);
while sum(strcmp(fileList.mat,vr.filenameMat)) > 0
    fileIndex = fileIndex + 1;
    vr.filenameMat = [vr.experimenter,vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.mat'];
    vr.filenameMatCell = [vr.experimenter,vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_Cell_',num2str(fileIndex),'.mat'];
    vr.filenameDat = [vr.experimenter,vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.dat'];
    fileList = what(path);
end
exper = copyVirmenObject(vr.exper); %#ok<NASGU>
vr.pathTempMat = [tempPath,'\',vr.filenameTempMat];
vr.pathTempMatCell = [tempPath,'\',vr.filenameTempMatCell];
vr.pathTempDat = [tempPath,'\',vr.filenameTempDat];
vr.pathMat = [path,'\',vr.filenameMat];
vr.pathMatCell = [path,'\',vr.filenameMatCell];
vr.pathDat = [path, '\',vr.filenameDat];
save(vr.pathTempMat,'exper');
vr.fid = fopen(vr.pathTempDat,'w');

%save tempFile
% ??? not sure what this is for
%save(vr.pathTempMatCell,'-struct','vr','conds');

end

