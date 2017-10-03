function [] = archiveVirmenCode(vr,experimentCodeFullPath)

virmenArchivePath = [vr.session.savePathFinal filesep 'virmenArchive' filesep vr.session.sessionID '_virmenArchive'];
if ~exist(virmenArchivePath,'dir')
    mkdir(virmenArchivePath);
end
% need to 
P = mfilename('fullpath');
[s,rhash] = system(['git -C ' P ' rev-parse HEAD'])
copyfile(experimentCodeFullPath(1:strfind(check,[filesep 'experiments'])),virmenArchivePath);
disp('virmen code archived');




