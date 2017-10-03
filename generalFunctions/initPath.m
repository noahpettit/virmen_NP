function vr = initPath(vr)

% get path info for specific experimenter strings

ops = getRigSettings(vr.session.rig);

vr.session.savePathFinal = [ops.dataDirectory vr.exper.variables.mouseID filesep vr.session.sessionID];
vr.session.savePathTemp = [ops.dataDirectory vr.exper.variables.mouseID filesep vr.session.sessionID filesep 'temp'];

% make directories if they do not already exist 
if ~exist(vr.session.savePathFinal,'dir')
    mkdir(vr.session.savePathFinal);
end
if ~exist(vr.session.savePathTemp,'dir')
    mkdir(vr.session.savePathTemp);
end