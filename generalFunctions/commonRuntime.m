 function vr = commonRuntime(vr,phase)

global lickCount
global mvData
vr.cond = vr.trial(vr.tN).type;
vr.binN = find(vr.condition(vr.cond).binEdges<vr.position(2),1,'last');
vr.binN(vr.binN>(length(vr.condition(vr.cond).binEdges)-1)) = length(vr.condition(vr.cond).binEdges)-1;
vr.binN(vr.binN<1) = 1;
    

switch phase
    case 'iterStart'
        vr.isLick = lickCount - vr.lastLickCount;
        vr.lastLickCount = lickCount;
        vr.rawMovement = mvData;
        vr.iN = vr.iN+1;
        vr.reward = 0;
        vr.punishment = 0;
        vr.isVisible = ~vr.isBlackout;
        switch vr.keyPressed
            case 76 % L key
                vr.isLick = 1;
            case 82
                % R key to deliver reward manually
                vr = giveReward(vr,vr.session.rewardSize);
            case 80
                % P key to give air puff
                vr = giveAirpuff(vr,vr.session.airPuffLength);
            case 49
                % "1" key pressed: switch world to world 1
                [vr.trial(vr.tN+1:end).type] = deal(1);
            case 50
                % "2" key pressed: switch world to world 2
                [vr.trial(vr.tN+1:end).type] = deal(2);
            case 51
                % "3" key pressed: switch world to world 3
                [vr.trial(vr.tN+1:end).type] = deal(3);
            case 52
                [vr.trial(vr.tN+1:end).type] = deal(4);
        end
        
        % first check to see if this spatial bin has been evaluated.
        if ~ismember(vr.binN,vr.binsEvaluated)
            % we have not evaluated this bin yet
            if vr.condition(vr.cond).requiresLick(vr.binN) && vr.isLick>0
                % then the mouse has licked
                if rand<=vr.condition(vr.cond).rProb(vr.binN)
                    % give reward
                    vr = giveReward(vr,vr.session.rewardSize);
                end
                if rand<=vr.condition(vr.cond).pProb(vr.binN)
                    % give punishment (air puff)
                    vr = giveAirpuff(vr,vr.session.airPuffLength);
                end
                vr.binsEvaluated = [vr.binsEvaluated; vr.binN];
            end
            
            if ~vr.condition(vr.cond).requiresLick(vr.binN)
                if rand<=vr.condition(vr.cond).rProb(vr.binN)
                    % give reward
                    vr = giveReward(vr,vr.session.rewardSize);
                end
                if rand<=vr.condition(vr.cond).pProb(vr.binN)
                    % give punishment (air puff)
                    vr = giveAirpuff(vr,vr.session.airPuffLength);
                end
                vr.binsEvaluated = [vr.binsEvaluated; vr.binN];
            end
            
        end
        
    case 'iterEnd'
        
        vr.trial(vr.tN).totalReward = vr.trial(vr.tN).totalReward+vr.reward;
        vr.trial(vr.tN).licksInBin(vr.binN) = vr.trial(vr.tN).licksInBin(vr.binN)+vr.isLick;
        vr.trial(vr.tN).rewardInBin(vr.binN) = vr.trial(vr.tN).rewardInBin(vr.binN)+vr.reward;
        vr.trial(vr.tN).punishmentInBin(vr.binN) = vr.trial(vr.tN).punishmentInBin(vr.binN)+vr.punishment;
        
        % % draw the text
        if vr.drawText
            % 1 is maze name
            vr.text(1).string = upper(strrep([vr.session.sessionID],'_',' '));
            
            vr.text(2).string = upper(['TIME: ' datestr(now-vr.session.startTime,'HH.MM.SS')]);
            vr.text(3).string = upper(['TRIAL: ' num2str(vr.tN)]);
            vr.text(4).string = upper(['REWARDS: ' num2str(sum([vr.trial(1:vr.tN).totalReward]))]);
            % 5 is lick
            if vr.isLick
                vr.text(5).string = upper(['LICK! ']);
            else
                vr.text(5).string = upper(['']);
            end
            vr.text(6).string = upper(['BIN: ', num2str(vr.binN)]);
            vr.text(7).string = upper(['DIST: ', num2str(round(785-vr.position(2)))]);
        end
        
        % % save the iteration
        vr = saveIter(vr);
        
    case 'trialEnd'
            vr.trial(vr.tN).duration = (now-vr.trial(vr.tN).start)*(24*60*60);
 
            % update performance metrics
            vr.session.nTrials = vr.tN;
            vr.session.nCorrect = sum([vr.trial(1:vr.tN).isCorrect]);
            vr.session.nRewards = num2str(sum([vr.trial(:).totalReward]));
            
            % determine rpm
            lastNTrials = (vr.tN-1):-1:max((vr.tN-2),1);
            vr.rpm = sum([vr.trial(lastNTrials).totalReward])./(sum([vr.trial(lastNTrials).duration])/60);
            vr.rpm = vr.rpm/vr.session.rewardSize;

            %% SAVE TRIAL
    
            vr = saveTrial(vr);
            
            %% NEW TRIAL STARTS HERE     
            vr.trialEnded = 0;
            vr.tN = vr.tN+1;
            vr = outputSyncPulse(vr);

            vr.trial(vr.tN).start = now();
            vr.trial(vr.tN).N = vr.tN;    
            vr.trial(vr.tN).rewardN = 0;
            
        if vr.drawText 
            vr.text(8).string = upper('HELLO');
            vr.text(9).string = upper(['RPM: ', num2str(vr.rpm)]);
            vr.text(10).string = upper(['TTYPE: ', num2str(vr.trial(vr.tN).type)]);
        end
        
        
end


end