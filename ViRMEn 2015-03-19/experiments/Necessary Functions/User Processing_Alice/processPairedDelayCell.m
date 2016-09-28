function [pairedData] = processPairedDelayCell(dataCell)
%processPairedCell.m This function processes the data cell and returns
%important parameters for paired data
%
%dataCell should be a cell array of structures
%
%ASM 9/17/12

%get NoDelay and Delay trials
noDelayCell = getTrials(dataCell,'maze.delay == 0');
delayCell = getTrials(dataCell,'maze.delay == 1');

if ~isempty(noDelayCell)
    %NoDelay
    
    %get number of trials, rewards, and rewards received
    pairedData.nTrialsNoDelay = length(noDelayCell);
    pairedData.nRewardsNoDelay = sum(findTrials(noDelayCell,'result.correct==1'));
    pairedData.nRewardsRecNoDelay = sum(getCellVals(noDelayCell,'result.rewardSize'));
    
    %calculate percent corrects
    pairedData.percCorrNoDelay = 100*pairedData.nRewardsNoDelay/pairedData.nTrialsNoDelay;
    
    %calculate percent/fraction left/white
    pairedData.percLeftNoDelay = 100*sum(findTrials(noDelayCell,'result.leftTurn==1'))/pairedData.nTrialsNoDelay;
    pairedData.percWhiteNoDelay = 100*sum(findTrials(noDelayCell,'result.whiteTurn==1'))/pairedData.nTrialsNoDelay;
    pairedData.fracLeftNoDelay = 100*sum(findTrials(noDelayCell,'maze.leftTrial==1'))/pairedData.nTrialsNoDelay;
    pairedData.fracWhiteNoDelay = 100*sum(findTrials(noDelayCell,'maze.whiteTrial==1'))/pairedData.nTrialsNoDelay;
    
    %calculate mean+-std trial duration
    pairedData.meanDurNoDelay = mean(getCellVals(noDelayCell,'time.duration'));
    pairedData.stdDurNoDelay = std(getCellVals(noDelayCell,'time.duration'));
    
    %calculate session time
    if ~isfield(dataCell{1}.info,'itiCorrect') %this is only present because I did not originally include itiMiss and itiCorrect in my structures. Should be irrelevant otherwise
        dataCell{1}.info.itiCorrect = 2;
        dataCell{1}.info.itiMiss = 4;
    end
    pairedData.sessionTimeNoDelay = (sum(getCellVals(noDelayCell,'time.duration'))+...
        dataCell{1}.info.itiCorrect*pairedData.nRewardsNoDelay +...
        dataCell{1}.info.itiMiss*(pairedData.nTrialsNoDelay-pairedData.nRewardsNoDelay))/60;
    
    %calculate trialsPerMin and rewardsPerMin
    pairedData.trialsPerMinNoDelay = pairedData.nTrialsNoDelay/pairedData.sessionTimeNoDelay;
    pairedData.rewPerMinNoDelay = pairedData.nRewardsNoDelay/pairedData.sessionTimeNoDelay;
else
    pairedData.nTrialsNoDelay = NaN;
    pairedData.nRewardsNoDelay = NaN;
    pairedData.nRewardsRecNoDelay = NaN;
    pairedData.percCorrNoDelay = NaN;
    pairedData.percLeftNoDelay = NaN;
    pairedData.percWhiteNoDelay = NaN;
    pairedData.fracLeftNoDelay = NaN;
    pairedData.fracWhiteNoDelay = NaN;
    pairedData.meanDurNoDelay = NaN;
    pairedData.stdDurNoDelay = NaN;
    pairedData.sessionTimeNoDelay = NaN;
    pairedData.trialsPerMinNoDelay = NaN;
    pairedData.rewPerMinNoDelay = NaN;
end

if ~isempty(delayCell)
    %NO NoDelay
    %get number of trials, rewards, and rewards received
    pairedData.nTrialsDelay = length(delayCell);
    pairedData.nRewardsDelay = sum(findTrials(delayCell,'result.correct==1'));
    pairedData.nRewardsRecDelay = sum(getCellVals(delayCell,'result.rewardSize'));
    
    %calculate percent corrects
    pairedData.percCorrDelay = 100*pairedData.nRewardsDelay/pairedData.nTrialsDelay;
    
    %calculate percent/fraction left/white
    pairedData.percLeftDelay = 100*sum(findTrials(delayCell,'result.leftTurn==1'))/pairedData.nTrialsDelay;
    pairedData.percWhiteDelay = 100*sum(findTrials(delayCell,'result.whiteTurn==1'))/pairedData.nTrialsDelay;
    pairedData.fracLeftDelay = 100*sum(findTrials(delayCell,'maze.leftTrial==1'))/pairedData.nTrialsDelay;
    pairedData.fracWhiteDelay = 100*sum(findTrials(delayCell,'maze.whiteTrial==1'))/pairedData.nTrialsDelay;
    
    %calculate mean+-std trial duration
    pairedData.meanDurDelay = mean(getCellVals(delayCell,'time.duration'));
    pairedData.stdDurDelay = std(getCellVals(delayCell,'time.duration'));
    
    %calculate session time
    if ~isfield(dataCell{1}.info,'itiCorrect') %this is only present because I did not originally include itiMiss and itiCorrect in my structures. Should be irrelevant otherwise
        dataCell{1}.info.itiCorrect = 2;
        dataCell{1}.info.itiMiss = 4;
    end
    pairedData.sessionTimeDelay = (sum(getCellVals(delayCell,'time.duration'))+...
        dataCell{1}.info.itiCorrect*pairedData.nRewardsDelay +...
        dataCell{1}.info.itiMiss*(pairedData.nTrialsDelay-pairedData.nRewardsDelay))/60;
    
    %calculate trialsPerMin and rewardsPerMin
    pairedData.trialsPerMinDelay = pairedData.nTrialsDelay/pairedData.sessionTimeDelay;
    pairedData.rewPerMinDelay = pairedData.nRewardsDelay/pairedData.sessionTimeDelay;
else
    pairedData.nTrialsDelay = NaN;
    pairedData.nRewardsDelay = NaN;
    pairedData.nRewardsRecDelay = NaN;
    pairedData.percCorrDelay = NaN;
    pairedData.percLeftDelay = NaN;
    pairedData.percWhiteDelay = NaN;
    pairedData.fracLeftDelay = NaN;
    pairedData.fracWhiteDelay = NaN;
    pairedData.meanDurDelay = NaN;
    pairedData.stdDurDelay = NaN;
    pairedData.sessionTimeDelay = NaN;
    pairedData.trialsPerMinDelay = NaN;
    pairedData.rewPerMinDelay = NaN;
end
end