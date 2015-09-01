function [dateCell,dateList] = getTrainDates(mouseNum,monthSpec,yearSpec,homeDir)

if ~exist('monthSpec','var')
    monthSpec = '*';
end

if ~exist('yearSpec','var')
    yearSpec = '*';
end

if ~exist('homeDir','var')
    homeDir = 'Z:\HarveyLab\Annie H';
end

currentFolder = pwd;
mouseDir = fullfile(homeDir,num2str(mouseNum));
cd(mouseDir),

specString = ['*-' monthSpec '-' yearSpec];
dateList = ls(specString);
dateOrder = sort(datenum(dateList));
dateList = datestr(dateOrder);

for sesh = 1:size(dateList,1)
    dateCell{sesh} = fullfile(mouseDir,dateList(sesh,:));
end

cd(currentFolder),