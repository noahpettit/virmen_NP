function [vr] = saveSession(vr)

session = vr.session;
save([vr.session.savePathFinal filesep vr.session.sessionID '_session.mat'],'session');

