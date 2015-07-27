function vr = chooseNextWorld(vr,worlds)
    
if isempty(worlds)
    vr.currentWorld = randi(vr.nWorlds);
else
    if isfield(vr,'penaltyProb')
       if ~ismember(vr.numTrials, vr.sessionSwitchpoints) & ~vr.isReward
            worlds(end+1:end+vr.penaltyProb) = vr.currentWorld,
       end  
    end
    
    worldChoice = randi(length(worlds));
    vr.currentWorld = worlds(worldChoice);
end