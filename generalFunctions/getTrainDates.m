function [dateCell,dateList] = getTrainDates(mouseNum,monthSpec,yearSpec,homeDir)

if ~exist('monthSpec','var') || isempty(monthSpec)
    monthSpec = '*';
end

if ~exist('yearSpec','var') || isempty(yearSpec)
    yearSpec = '*';
end

if ~exist('homeDir','var') || isempty(homeDir)
%     homeDir = 'Z:\HarveyLab\Annie H';
    homeDir = 'Z:\HarveyLab\Deane K';
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