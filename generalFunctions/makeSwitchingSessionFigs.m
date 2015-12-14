function vr = makeSwitchingSessionFigs(vr,sessionData,switchPoints)

%% input handling
if ~exist('switchPoints','var') || isempty(switchPoints)
    switchPoints = 100;
end

%% Format Trials
trials = unique(sessionData(end,:));
for nTrial = trials
    trialInd = find(sessionData(end,:)==nTrial);
    world(nTrial) = mode(sessionData(1,trialInd));
    reward(nTrial) = sum(sessionData(9,trialInd));
    notITI = sessionData(8,trialInd) == 0;
    validTrialInd = trialInd(notITI);
    timePerTrial(nTrial) = sum(sessionData(10,validTrialInd));
end

%% pCor by Trial Plot
for cond = 1:8
    condInd = find(world==cond);
    if isempty(condInd)
        pCor(cond) = nan;
    else
        pCor(cond) = mean(reward(condInd));
    end
end

figure,bar(reshape(pCor,4,[])),
xlabel('1 = Dark Right || 2 = Light Left || 3 = Dark Left || 4 = Light Right')
ylabel('% Correct')

%% Smoothed pCor + Time plots

filtLength = 9;
halfFiltL = floor(filtLength/2);
trialFilt = ones(filtLength,1)/filtLength;
filtCorrect = conv([reward(halfFiltL:-1:1), ...
    reward, ...
    reward(max(trials)-1:-1:max(trials)-halfFiltL)],...
    trialFilt,'valid');
reflectedTimePerTrial = [timePerTrial(halfFiltL:-1:1), ...
    timePerTrial, ...
    timePerTrial(max(trials)-1:-1:max(trials)-halfFiltL)];
filtTime = conv(reflectedTimePerTrial,trialFilt,'valid');


figure, hold on,
[hAx, hLine1, hLine2] = plotyy(trials,filtTime,trials,filtCorrect);
hLine1.LineWidth = 2;
hLine2.LineWidth = 2;
%line([1 max(trials)], [1-max(trialFilt) 1-max(trialFilt)],'Color','g','linestyle','--')
%line([1 max(trials)], [max(trialFilt) max(trialFilt)],'Color','g','linestyle','--')
line([1 max(trials)], [1/2 1/2],'Color','k','linewidth',2,'Parent',hAx(2),'linestyle','--')
for switchPoint = switchPoints
    line([switchPoint switchPoint],[-0.05 1.05],'linewidth',2,'Color','g','Parent',hAx(2),'linestyle','--')
end
xlim(hAx(1),[1 max(trials)]),
xlim(hAx(2),[1 max(trials)]),
ylim(hAx(2),[-0.05 1.05]),
ylim(hAx(1),[0, max(filtTime)+1]),
xlabel('Trials'),
ylabel(hAx(2),'Percent Correct'),
ylabel(hAx(1),'Trial Duration (s)'),
title(sprintf('Smoothed Performance with %2.0f point Boxcar',filtLength)),
%% Plot Percent Correct by Block

nBlocks = length(switchPoints) +1;
switchInd = [1, switchPoints, inf];
for nBlock = 1 : nBlocks
    blockInd(nBlock, :) = (1:max(trials)) >= switchInd(nBlock) & (1 : max(trials)) < switchInd(nBlock +1);
end

for nBlock = 1 : nBlocks
    thisBlock = find(blockInd(nBlock,:));
    invalidTrials = thisBlock(1:floor(length(thisBlock)/2));
    block = blockInd(nBlock,:);
    block(invalidTrials) = 0;
    pattern = world < 5; 
    pCorPattern(nBlock) = mean(reward(pattern & block));
    pCorNotPattern(nBlock) = mean(reward(~pattern & block));
end


y = [pCorPattern; pCorNotPattern]';
figure, hold on,
bar(y);

title('Second Half Performance');
xlabel('Block');
ylabel('Percent Correct')