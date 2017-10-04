function [] = testReward(rig,nRewards)
% reward delivery function

h = msgbox('Testing ... press OK to stop');
for k = 1:nRewards
    giveReward(rig,4,'uL');
    pause(0.2);
    disp([num2str(k) ' rewards of 4 uL given']);
    if ~ishandle(h)
        disp('aborted calibration');
        break
    end  
end
if ishandle(h)
    close(h);
end
end