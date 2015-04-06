function vr = chooseNextWorld(vr,worlds)

if isempty(worlds)
    vr.currentWorld = randi(vr.nWorlds);
else
    worldChoice = randi(length(worlds));
    vr.currentWorld = worlds(worldChoice);
end