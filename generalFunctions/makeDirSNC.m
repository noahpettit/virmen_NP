function vr = makeDirSNC(vr)

if vr.debugMode
    vr.mouseNum = randi(1e6,1)+1e3;
    vr.basePath = 'C:\DATA\Debug';
else    
    mouseInfo = inputdlg('Input the Mouse Number: ');
    vr.mouseNum = str2double(mouseInfo{1});
    vr.basePath = 'C:\DATA\Annie';
end
vr.date = date;
vr.fullPath = [vr.basePath filesep num2str(vr.mouseNum) filesep vr.date];

if ~exist(vr.fullPath,'dir')
    mkdir(vr.fullPath);
else
    warning('Path Already Exists!');
    subFolder = input('Input specification: ','s');
    vr.fullPath = [vr.fullPath filesep subFolder];
    mkdir(vr.fullPath);
end    