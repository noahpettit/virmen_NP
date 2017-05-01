function [vr] = saveTrial(vr,trialInd)
tic;
disp('saving trial data...');
session = vr.session;
trial = vr.trial(trialInd);

% get rid of empty entries in vr.iter
iter = vr.iter([vr.iter(:).trialN] == trialInd);

save([vr.session.savePathTemp filesep vr.session.baseFilename '_session_tN' sprintf('%03d',trialInd) '.mat'], 'session');
save([vr.session.savePathTemp filesep vr.session.baseFilename '_trial_tN' sprintf('%03d',trialInd) '.mat'], 'trial');
save([vr.session.savePathTemp filesep vr.session.baseFilename '_iter_tN' sprintf('%03d',trialInd) '.mat'], 'iter');

% now clear fields of iter that have been saved
names = fieldnames(iter);
ind2clear = find([vr.iter(:).trialN] == trialInd);

for k=1:length(names)
    if strcmp(names{k}, 'trialN') || strcmp(names{k}, 'iterN')
        % do nothing 
    else
        % erase the field value 
        eval(['[vr.iter(ind2clear).' names{k} '] = deal([]);']);
    end
end
toc
end
