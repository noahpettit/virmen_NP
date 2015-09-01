function [trainData,trainExper] = loadTrainDates(dateCell)

numSeshs = length(dateCell);

for numSesh = 1:numSeshs
    dirInfo = dir(dateCell{numSesh});
    trainDatDir = find([dirInfo.isdir]);
    trainDatDir(1:2) = [];
    if ~isempty(trainDatDir)
        warning(sprintf('\n Directory %s Contains Subfolders: ',dateCell{numSesh})),
        for dirNum = trainDatDir
            fprintf('\n #%d: %s ',dirNum,dirInfo(dirNum).name);
        end
        folderNum = input('\n Choose Desired Folder #: ');
        dateCell{numSesh} = fullfile(dateCell{numSesh},dirInfo(dirNum).name);
    end
    
    
    seshFile = fullfile(dateCell{numSesh},'sessionData.mat');
    dat = load(seshFile);
    trainData{numSesh} = dat.sessionData;
    trainExper{numSesh} = dat.experData;
end