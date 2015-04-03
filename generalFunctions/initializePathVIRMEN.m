function [vr] = initializePathVIRMEN(vr)
%INITIALIZEPATHVIRMEN This is a function to initialize virmen path
%information run during the initialization block of all mazes

%initialize cell info
vr.experimenter = 'MARY';
vr.mazeName = func2str(vr.exper.experimentCode);
vr.exper.variables.mouseNumber = sprintf('%03d',vr.mouseNum); %save mouse num in exper 

%set up path information
path = ['C:\DATA\Mary\Current Mice\LD' sprintf('%03d',vr.mouseNum)];
tempPath = 'C:\DATA\Mary\Temporary';
if ~exist(tempPath,'dir');
    mkdir(tempPath);
end
if ~exist(path,'dir')
    mkdir(path);
end
vr.filenameTempMat = 'tempStorage.mat';
vr.filenameTempMatCell = 'tempStorageCell.mat';
vr.filenameTempDat = 'tempStorage.dat';
vr.filenameMat = ['LD',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'.mat'];
vr.filenameMatCell = ['LD',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_Cell.mat'];
vr.filenameDat = ['LD',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'.dat'];
fileIndex = 0;
fileList = what(path);
while sum(strcmp(fileList.mat,vr.filenameMat)) > 0
    fileIndex = fileIndex + 1;
    vr.filenameMat = ['LD',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.mat'];
    vr.filenameMatCell = ['LD',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_Cell_',num2str(fileIndex),'.mat'];
    vr.filenameDat = ['LD',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.dat'];
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
save(vr.pathTempMatCell,'-struct','vr','conds');

end

