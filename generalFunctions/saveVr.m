function [vr] = saveVr(vr)

save([vr.session.savePathFinal filesep vr.session.sessionID '_vr.mat'],'vr');

