function [vr] = getVirmenRigSettings(vr,rigID)
%INITIALIZEPATHVIRMEN This is a function to initialize virmen path
%information run during the initialization block of all mazes

% make a field with all rig-specific info
vr.rig.ID = rigID;

%are we on imaging rig? 
switch vr.rig.ID
    case 'noahDesk'

vr.rig.path= 'C:\Users\harveyadmin\Desktop\Noah
vr.rig.tempPath = 
vr.rig.experimenter = vr.exper.variables.experimenterName;
vr.rig.optogenetics = 0;
vr.rig.daqSetup = 0;
    case 'odin'
    case 'loki'
end

switch vr.rig.experimenter
    case
path = ['C:\Users\harveyadmin\Desktop\Noah\DATA\Current Mice\' vr.experimenter sprintf('%03d',vr.mouseNum)];
tempPath = 'C:\Users\harveyadmin\Desktop\Noah\DATA\Temporary';

if ~exist(tempPath,'dir');
    mkdir(tempPath);
end
if ~exist(path,'dir')
    mkdir(path);
end
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
save(vr.pathTempMatCell,'-struct','vr','conds');

% setup and start the DAQ acquisition
if ~vr.debugMode
    daqreset; %reset DAQ in case it's still in use by a previous Matlab program
    vr.ai = analoginput('nidaq','dev1'); % connect to the DAQ card
    addchannel(vr.ai,0:1); % start channels 0 and 1
    set(vr.ai,'samplerate',1000,'samplespertrigger',1e7); % define buffer
    start(vr.ai); % start acquisition

    vr.ao = analogoutput('nidaq','dev1');
    addchannel(vr.ao,0);
    set(vr.ao,'samplerate',10000);
    
    if vr.optogenetics
        vr.dio = digitalio('nidaq', 'Dev1');
        addline(vr.dio, 0:1, 1, 'Out'); % TTL on the 'PIF' BNC.
        set(vr.dio,'TimerFcn',@daqcallback_PP); %this callback will stop the dio, and putvalue 0, whatever the value before
        set(vr.dio,'TimerPeriod',vr.TimerDuration);
        putvalue(vr.dio.Line(1:2), [0;0]);
        vr.isLED = getvalue(vr.dio);
    end
end

%Set up alternate analog out object for outputting iteration number
if ~vr.debugMode && vr.imaging
    vr.aoCOUNT = analogoutput('nidaq','dev1');
    addchannel(vr.aoCOUNT,1);
    set(vr.aoCOUNT,'samplerate',1000);
end

%initialize counters
vr.streak = 0;
vr.inITI = 0;
vr.isReward = 0;
vr.startTime = now;
vr.trialStartTime = rem(now,1);
vr.numTrials = 0;
vr.numRewards = 0;
vr.trialResults = [];
vr.itiCorrect = 2;
vr.itiMiss = 4;

%initialize text boxes
vr.text(1).string = '';
vr.text(1).position = [1 .8];
vr.text(1).size = .03;
vr.text(1).color = [1 0 1];

vr.text(2).string = '';
vr.text(2).position = [1 .7];
vr.text(2).size = .03;
vr.text(2).color = [1 1 0];

vr.text(3).string = '';
vr.text(3).position = [1 .6];
vr.text(3).size = .03;
vr.text(3).color = [0 1 1];

vr.text(4).string = '';
vr.text(4).position = [1 .5];
vr.text(4).size = .03;
vr.text(4).color = [.5 .5 1];

vr.text(5).string = '';
vr.text(5).position = [1 .4];
vr.text(5).size = .03;
vr.text(5).color = [1 .5 .5];

vr.text(6).string = '';
vr.text(6).position = [1 .3];
vr.text(6).size = .03;
vr.text(6).color = [0 1 1];

%move pointer
set(0,'pointerlocation',[0 0]);

end

