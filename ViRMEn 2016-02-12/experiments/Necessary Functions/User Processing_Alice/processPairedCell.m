function [pairedData] = processPairedCell(dataCell)
%processPairedCell.m This function processes the data cell and returns
%important parameters for paired data
%
%dataCell should be a cell array of structures
%
%ASM 9/17/12

%get tower and no tower trials
singleTowerCell = getTrials(dataCell,'maze.twoTowers == 0');
twoTowersCell = getTrials(dataCell,'maze.twoTowers == 1');

if ~isempty(singleTowerCell)
    %TOWER
    
    %get number of trials, rewards, and rewards received
    pairedData.nTrialsTower = length(singleTowerCell);
    pairedData.nRewardsTower = sum(findTrials(singleTowerCell,'result.correct==1'));
    pairedData.nRewardsRecTower = sum(getCellVals(singleTowerCell,'result.rewardSize'));
    
    %calculate percent corrects
    pairedData.percCorrTower = 100*pairedData.nRewardsTower/pairedData.nTrialsTower;
    
    %calculate percent/fraction left/white
    pairedData.percLeftTower = 100*sum(findTrials(singleTowerCell,'result.leftTurn==1'))/pairedData.nTrialsTower;
    pairedData.percWhiteTower = 100*sum(findTrials(singleTowerCell,'result.whiteTurn==1'))/pairedData.nTrialsTower;
    pairedData.fracLeftTower = 100*sum(findTrials(singleTowerCell,'maze.leftTrial==1'))/pairedData.nTrialsTower;
    pairedData.fracWhiteTower = 100*sum(findTrials(singleTowerCell,'maze.whiteTrial==1'))/pairedData.nTrialsTower;
    
    %calculate mean+-std trial duration
    pairedData.meanDurTower = mean(getCellVals(singleTowerCell,'time.duration'));
    pairedData.stdDurTower = std(getCellVals(singleTowerCell,'time.duration'));
    
    %calculate session time
    if ~isfield(dataCell{1}.info,'itiCorrect') %this is only present because I did not originally include itiMiss and itiCorrect in my structures. Should be irrelevant otherwise
        dataCell{1}.info.itiCorrect = 2;
        dataCell{1}.info.itiMiss = 4;
    end
    pairedData.sessionTimeTower = (sum(getCellVals(singleTowerCell,'time.duration'))+...
        dataCell{1}.info.itiCorrect*pairedData.nRewardsTower +...
        dataCell{1}.info.itiMiss*(pairedData.nTrialsTower-pairedData.nRewardsTower))/60;
    
    %calculate trialsPerMin and rewardsPerMin
    pairedData.trialsPerMinTower = pairedData.nTrialsTower/pairedData.sessionTimeTower;
    pairedData.rewPerMinTower = pairedData.nRewardsTower/pairedData.sessionTimeTower;
else
    pairedData.nTrialsTower = NaN;
    pairedData.nRewardsTower = NaN;
    pairedData.nRewardsRecTower = NaN;
    pairedData.percCorrTower = NaN;
    pairedData.percLeftTower = NaN;
    pairedData.percWhiteTower = NaN;
    pairedData.fracLeftTower = NaN;
    pairedData.fracWhiteTower = NaN;
    pairedData.meanDurTower = NaN;
    pairedData.stdDurTower = NaN;
    pairedData.sessionTimeTower = NaN;
    pairedData.trialsPerMinTower = NaN;
    pairedData.rewPerMinTower = NaN;
end

if ~isempty(twoTowersCell)
    %NO TOWER
    %get number of trials, rewards, and rewards received
    pairedData.nTrialsNoTower = length(twoTowersCell);
    pairedData.nRewardsNoTower = sum(findTrials(twoTowersCell,'result.correct==1'));
    pairedData.nRewardsRecNoTower = sum(getCellVals(twoTowersCell,'result.rewardSize'));
    
    %calculate percent corrects
    pairedData.percCorrNoTower = 100*pairedData.nRewardsNoTower/pairedData.nTrialsNoTower;
    
    %calculate percent/fraction left/white
    pairedData.percLeftNoTower = 100*sum(findTrials(twoTowersCell,'result.leftTurn==1'))/pairedData.nTrialsNoTower;
    pairedData.percWhiteNoTower = 100*sum(findTrials(twoTowersCell,'result.whiteTurn==1'))/pairedData.nTrialsNoTower;
    pairedData.fracLeftNoTower = 100*sum(findTrials(twoTowersCell,'maze.leftTrial==1'))/pairedData.nTrialsNoTower;
    pairedData.fracWhiteNoTower = 100*sum(findTrials(twoTowersCell,'maze.whiteTrial==1'))/pairedData.nTrialsNoTower;
    
    %calculate mean+-std trial duration
    pairedData.meanDurNoTower = mean(getCellVals(twoTowersCell,'time.duration'));
    pairedData.stdDurNoTower = std(getCellVals(twoTowersCell,'time.duration'));
    
    %calculate session time
    if ~isfield(dataCell{1}.info,'itiCorrect') %this is only present because I did not originally include itiMiss and itiCorrect in my structures. Should be irrelevant otherwise
        dataCell{1}.info.itiCorrect = 2;
        dataCell{1}.info.itiMiss = 4;
    end
    pairedData.sessionTimeNoTower = (sum(getCellVals(twoTowersCell,'time.duration'))+...
        dataCell{1}.info.itiCorrect*pairedData.nRewardsNoTower +...
        dataCell{1}.info.itiMiss*(pairedData.nTrialsNoTower-pairedData.nRewardsNoTower))/60;
    
    %calculate trialsPerMin and rewardsPerMin
    pairedData.trialsPerMinNoTower = pairedData.nTrialsNoTower/pairedData.sessionTimeNoTower;
    pairedData.rewPerMinNoTower = pairedData.nRewardsNoTower/pairedData.sessionTimeNoTower;
else
    pairedData.nTrialsNoTower = NaN;
    pairedData.nRewardsNoTower = NaN;
    pairedData.nRewardsRecNoTower = NaN;
    pairedData.percCorrNoTower = NaN;
    pairedData.percLeftNoTower = NaN;
    pairedData.percWhiteNoTower = NaN;
    pairedData.fracLeftNoTower = NaN;
    pairedData.fracWhiteNoTower = NaN;
    pairedData.meanDurNoTower = NaN;
    pairedData.stdDurNoTower = NaN;
    pairedData.sessionTimeNoTower = NaN;
    pairedData.trialsPerMinNoTower = NaN;
    pairedData.rewPerMinNoTower = NaN;
end
end