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
end

%% pCor by Trial Plot
for cond = 1:max(world)
    condInd = find(world==cond);
    pCor(cond) = mean(reward(condInd));
end

figure,bar(pCor),
xlabel('1 = Dark Right || 2 = Light Left || 3 = Dark Left || 4 = Light Right')
ylabel('% Correct')

%% Smoothed pCor Plot

filtLength = 5;
halfFiltL = floor(filtLength/2);
trialFilt = ones(filtLength,1)/filtLength;
filtCorrect = conv([reward(halfFiltL:-1:1), ...
    reward, ...
    reward(max(trials)-1:-1:max(trials)-halfFiltL)],...
    trialFilt,'valid');
figure, hold on,
plot(filtCorrect),
line([1 max(trials)], [1-max(trialFilt) 1-max(trialFilt)],'Color','g','linestyle','--')
line([1 max(trials)], [max(trialFilt) max(trialFilt)],'Color','g','linestyle','--')
line([1 max(trials)], [1/2 1/2],'Color','k')
for switchPoint = switchPoints
    line([switchPoint switchPoint],[-0.05 1.05],'Color','r')
end
xlim([1 max(trials)])
ylim([-0.05 1.05]),
xlabel('Trials'),
ylabel('Percent Correct')
title(sprintf('Smoothed Performance with %2.0f point Boxcar',filtLength)),