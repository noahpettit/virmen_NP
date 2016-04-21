function vr = makeSwitchingSessionFigs(vr,sessionData,switchPoints)


sessionFigs = figure;

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

subplot(2,2,1),
bar(reshape(pCor,4,[])),
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


subplot(2,2,2), hold on,
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
subplot(2,2,3), hold on,
bar(y);

title('Second Half Performance');
xlabel('Block');
ylabel('Percent Correct')

%% Make strategy plots

trials = unique(sessionData(end,:));
cue = nan(1,max(trials));
turn = nan(1,max(trials));
for trial = trials
    trialInd = find(sessionData(end,:)==trial);
    cue(trial) = mod(mode(sessionData(1,trialInd)),2); %Black 0, White 1
    turn(trial) =  sessionData(5,trialInd(end-10))>0; %I think positive is 'right'?            
end

tCode = nan(1,max(trials));
for trial = trials(1:end-1)
    if cue(trial) == cue(trial+1) %If cue is identical
        if turn(trial) == turn(trial+1)
            tCode(trial) = 0; %'Indeterminate' = 0
        else
            tCode(trial) = 1; %'Guess' = 1
        end
    elseif turn(trial) == turn(trial+1) %If cue changes but turn does not
        if turn(trial) == 1
            tCode(trial) = 2; %'Right Bias' = 2
        else
            tCode(trial) = 3; %'Left Bias' = 3
        end
    else %Cue and turn changes
        if cue(trial) == turn(trial) %if BR or WL
            tCode(trial) = 4; %'Context A' = 4
        else
            tCode(trial) = 5; %'Context B' = 5
        end
    end
end

toResolve = find(tCode==0);
while ~isempty(toResolve)
    transition = toResolve(1); %Find first unresolved transition
    preTrans = find(tCode(1:transition)~=0,1,'last'); %Find in-transition
    postTrans = find(tCode(transition:end)~=0,1,'first')-1+transition; %Find out-transition
    
    if tCode(preTrans)==tCode(postTrans) % If consistency, assign value
        tCode(preTrans+1:postTrans-1) = tCode(preTrans);
    elseif isempty(preTrans) %If no in-transition, assign out value
        preTrans = 1;
        tCode(1:postTrans-1) = tCode(postTrans);
    elseif isempty(postTrans) %If no out-transition, assign in value
        postTrans = length(tCode);
        tCode(preTrains+1:end) = tCode(preTrans);
    elseif tCode(preTrans) == 1 % If first value only is guess, assign second value
        tCode(preTrans+1:postTrans-1) = tCode(postTrans);
    elseif tCode(postTrans) == 1 %If second value only is guess, assign first
        tCode(preTrans+1:postTrans-1) = tCode(preTrans);
    end
    
    toResolve(ismember(toResolve,preTrans:postTrans))=[];
end
     
filtLength = 21;
sWin = gausswin(filtLength)/sum(gausswin(filtLength));
%     figure,hold on
%     for c = 0:5
%         plot(conv(double(tCode==c),sWin,'same'),'linewidth',2)
%     end
%     legend('Indeterminate','Guess','R-Bias','L-Bias','Context-A','Context-B'),
subplot(2,2,4),hold on
plot(conv(double(tCode==4),sWin,'same'),'linewidth',2),
plot(conv(double(tCode==2|tCode==3),sWin,'same'),'linewidth',2),
plot(conv(double(tCode==1),sWin,'same'),'linewidth',2),
plot(conv(double(tCode==5),sWin,'same'),'linewidth',2),
legend('Context-A','Bias','Guess','Context-B'),
for switchPoint = switchPoints
    line([switchPoint switchPoint],[0 1],'linewidth',2,'Color','g','linestyle','--')
end
axis tight
