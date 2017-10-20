%%  PRESS CTRL-ENTER TO RUN CELLS
daqreset;
vr = initDAQ([]);
%%
giveReward(vr,4);
%%
giveAirpuff(vr,0.1);
%% test lick sensor
% listen for licks for 10 seconds
tic;
global lickCount
lastLick = lickCount;
while toc<10
    if lickCount>lastLick
        disp('lick!');
    end
    lastLick = lickCount;
    disp(num2str(lickCount));
    pause(0.1);
end