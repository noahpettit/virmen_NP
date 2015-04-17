function vr = makeSwitchingSessionFigs(vr,sessionData)

trials = unique(sessionData(end,:));

for nTrial = trials
    trialInd = find(sessionData(end,:)==nTrial);
    world(nTrial) = mode(sessionData(1,trialInd));
    reward(nTrial) = sum(sessionData(9,trialInd));
end

for cond = 1:4
    condInd = find(world==cond);
    pCor(cond) = mean(reward(condInd));
end

figure,bar(pCor),
xlabel('1 = Dark Right || 2 = Light Left || 3 = Dark Left || 4 = Light Right')
ylabel('% Correct')