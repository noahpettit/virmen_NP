function vr = initPath(vr)

% get path info for specific experimenter strings

ops = getRigSettings(vr.session.rig);

vr.session.savePathFinal = [ops.dataDirectory vr.mouseID filesep vr.session.sessionID];
vr.session.savePathTemp = [ops.dataDirectory vr.mouseID filesep vr.session.sessionID filesep 'temp'];

% make directories if they do not already exist 
if ~exist(vr.session.savePathFinal,'dir')
    mkdir(vr.session.savePathFinal);
end
if ~exist(vr.session.savePathTemp,'dir')
    mkdir(vr.session.savePathTemp);
end

% now check if binary file exists
if ~isfield(vr, 'trialFileID');
vr.trialFileID = fopen([vr.session.savePathFinal filesep vr.session.sessionID '_trialBinary.bin'],'a');
end

% now check if binary file exists
if ~isfield(vr, 'iterFileID');
vr.iterFileID = fopen([vr.session.savePathFinal filesep vr.session.sessionID '_iterBinary.bin'],'a');
end

