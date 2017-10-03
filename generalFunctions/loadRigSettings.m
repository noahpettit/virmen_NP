function vr = loadRigSettings(vr)

ops = getRigSettings('loki');
% get path info for specific experimenter strings
switch vr.session.rig
    case 'default'
        % save path
        vr.session.savePathFinal = ['C:\DATA\' 'Noah' '\currentMice\' vr.exper.variables.mouseID];
        vr.session.savePathTemp = ['C:\DATA\' 'Noah' '\currentMice\'  vr.exper.variables.mouseID filesep 'temp'];
        % daq settings
        vr.session.dev = 'dev1';
        vr.session.movementInput = 'ai1:3';
        vr.session.lickCh = 'p0.0';
        vr.session.rewardCh = 'p0.1';
        vr.session.airPuffCh = 'p0.2';
        vr.session.analogSyncCh = '';
        vr.session.digitalSyncCh = '';


    case 'noah_deskPC'
                
    case 'behaviorRig1'
    
    case 'behaviorRig2'
    
    case 'loki'
        % save path
        vr.session.savePathFinal = ['C:\DATA\' 'Noah\' vr.exper.variables.mouseID filesep vr.session.sessionID];
        vr.session.savePathTemp = ['C:\DATA\' 'Noah\' vr.exper.variables.mouseID filesep vr.session.sessionID filesep 'temp'];
        % daq settings
        vr.session.dev = 'dev1';
        vr.session.movementInput = 'ai1:3';
        vr.session.lickCh = 'p0.5';
        vr.session.rewardCh = 'ao0';
        vr.session.airPuffCh = 'p0.7';
        vr.session.analogSyncCh = 'ao1';
        vr.session.digitalSyncCh = 'p0.3';
        
    otherwise
        error('rig name did not match any of the specified strings. check getRigSettings.m file and make sure there is an entry for it.');
end

% make directories if they do not already exist 
if ~exist(vr.session.savePathFinal,'dir')
    mkdir(vr.session.savePathFinal);
end
if ~exist(vr.session.savePathTemp,'dir')
    mkdir(vr.session.savePathTemp);
end