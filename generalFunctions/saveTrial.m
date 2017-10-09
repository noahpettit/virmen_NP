function [vr] = saveTrial(vr)

if ~isfield(vr, 'saveOnTrial')
    vr.saveOnTrial = {};
    % by default we'll just save everything. keep in mind that the size of
    % these
    % entries cannot change!
    names = fieldnames(vr.trial);
    exclude = zeros(length(names),1);
    for k =1:length(names);
        vr.saveOnTrial{k,1} = names{k};
        vr.saveOnTrial{k,2} = numel(getfield(vr.trial(1),names{k}));
        if vr.saveOnTrial{k,2}==0;
            error(' Initialize vr.trial fields w/ nonempty matrix! Otherwise define saveOnTrial separately');
        end
    end
end

sz = cell2mat(vr.saveOnTrial(:,2));

% now check if binary file exists
if ~isfield(vr, 'trialFileID');
vr.trialFileID = fopen([vr.session.savePathTemp filesep vr.session.sessionID '_trialBinary.bin'],'a');
end

% check if the index file exsits
if ~exist([vr.session.savePathTemp filesep vr.session.sessionID '_trialBinaryVariableNames.mat']);
    saveOnTrial = vr.saveOnTrial;
    save([vr.session.savePathTemp filesep vr.session.sessionID '_trialBinaryVariableNames.mat'],'saveOnTrial');
end

ind = cumsum(sz);
vec = zeros(sum(sz),1);
for k =1:size(vr.saveOnTrial,1)
    val = getfield(vr.trial(vr.tN),vr.saveOnTrial{k,1});
    vec(ind(k):ind(k)+sz(k)-1) = val(:);
end

fwrite(vr.trialFileID,vec,'double');
