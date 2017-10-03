function [] = archiveVirmenCode(vr)

virmenArchivePath = [vr.session.savePathFinal filesep 'virmenArchive' filesep vr.session.sessionID '_virmenArchive'];
if ~exist(virmenArchivePath,'dir')
    mkdir(virmenArchivePath);
end
% need to 
P = mfilename('fullpath');
[s,rhash] = system(['git -C ' P ' rev-parse HEAD']);

copyfile(P(1:strfind(P,[filesep 'generalFunctions'])),virmenArchivePath);
disp('virmen code archived');




