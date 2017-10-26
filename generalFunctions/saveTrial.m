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
vr.trialFileID = fopen([vr.session.savePathFinal filesep vr.session.sessionID '_trialBinary.bin'],'a');
end

% check if the index file exsits
if ~exist([vr.session.savePathFinal filesep vr.session.sessionID '_trialBinaryVariableNames.mat']);
    saveOnTrial = vr.saveOnTrial;
    save([vr.session.savePathFinal filesep vr.session.sessionID '_trialBinaryVariableNames.mat'],'saveOnTrial');
end

ind = cumsum(sz);
vec = [];
for k =1:size(vr.saveOnTrial,1)
    val = getfield(vr.trial(vr.tN),vr.saveOnTrial{k,1});
    if numel(val)~=vr.saveOnTrial{k,2}
        val
        error(['Length of ' vr.saveOnTrial{k,1} 'is not' num2str(vr.saveOnTrial{k,2})]);
    end
    vec = [vec; val(:)];
end

fwrite(vr.trialFileID,vec,'double');
