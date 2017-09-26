function [vr] = initPath(vr, experimenterRigID)
%INITIALIZEPATHVIRMEN This is a function to initialize virmen path
%information run during the initialization block of all mazes

if nargin<2
    experimenterRigID = 'default';
end

% get path info for specific experimenter strings
switch experimenterRigID
    case 'default'
        % if experimenterRig was not defined
        vr.session.experimenter = 'XX';
        vr.session.savePathFinal = ['C:\DATA\' vr.session.experimenter '\currentMice\' vr.exper.variables.mouseID];
        vr.session.savePathTemp = ['C:\DATA\' vr.session.experimenter '\currentMice\'  vr.exper.variables.mouseID filesep 'temp'];

    case 'noah_deskPC'
        vr.session.experimenter = 'NP';
        vr.session.savePathFinal = ['C:\DATA\' vr.session.experimenter '\currentMice\' vr.exper.variables.mouseID];
        vr.session.savePathTemp = ['C:\DATA\' vr.session.experimenter '\currentMice\'  vr.exper.variables.mouseID filesep 'temp'];
        
    case 'noah_behaviorRig1'
        vr.session.experimenter = 'NP';
        vr.session.savePathFinal = ['C:\DATA\' vr.session.experimenter '\currentMice\' vr.exper.variables.mouseID];
        vr.session.savePathTemp = ['C:\DATA\' vr.session.experimenter '\currentMice\'  vr.exper.variables.mouseID filesep 'temp'];

    case 'lynn_behaviorRig1'
        vr.session.experimenter = 'LY';
        vr.session.savePathFinal = ['C:\DATA\' vr.session.experimenter '\currentMice\' vr.exper.variables.mouseID];
        vr.session.savePathTemp = ['C:\DATA\' vr.session.experimenter '\currentMice\'  vr.exper.variables.mouseID filesep 'temp'];
    
    case 'lynn_behaviorRig2'
        vr.session.experimenter = 'LY';
        vr.session.savePathFinal = ['C:\DATA\' vr.session.experimenter '\currentMice\' vr.exper.variables.mouseID];
        vr.session.savePathTemp = ['C:\DATA\' vr.session.experimenter '\currentMice\'  vr.exper.variables.mouseID filesep 'temp'];

end

% make directories if they do not already exist 
if ~exist(vr.session.savePathFinal,'dir')
    mkdir(vr.session.savePathFinal);
end
if ~exist(vr.session.savePathTemp,'dir')
    mkdir(vr.session.savePathTemp);
end

end

