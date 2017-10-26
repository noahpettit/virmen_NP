function [vr] = saveIter(vr)

% if ~isfield(vr, 'saveOnIter')
%     disp('save on iter does not exist. creating...');
%     vr.saveOnIter = {};
%     % by default we'll just save everything. keep in mind that the size of
%     % these
%     % entries cannot change!
%     names = fieldnames(vr.iter);
%     exclude = zeros(length(names));
%     for k =1:length(names);
%         vr.saveOnIter{k,1} = names{k};
%         vr.saveOnIter{k,2} = numel(getfield(vr.iter(1),names{k}));
%         if vr.saveOnIter{k,2}==0;
%             disp([[vr.saveOnIter{k,1}] ' is being excluded from saveOnIter. Initialize w/ nonempty matrix!']);
%             exclude(k) = 1;
%         end
%     end
%     vr.saveOnIter(exclude,:) = [];
% end

sz = cell2mat(vr.saveOnIter(:,2));

% now check if binary file exists
if ~isfield(vr, 'iterFileID');
vr.iterFileID = fopen([vr.session.savePathFinal filesep vr.session.sessionID '_iterBinary.bin'],'a');
end

% check if the index file exsits
if ~exist([vr.session.savePathFinal filesep vr.session.sessionID '_iterBinaryVariableNames.mat']);
    saveOnIter = vr.saveOnIter;
    save([vr.session.savePathFinal filesep vr.session.sessionID '_iterBinaryVariableNames.mat'],'saveOnIter');
end

ind = cumsum(sz);
vec = zeros(sum(sz),1);
for k =1:size(vr.saveOnIter,1)
    val = getfield(vr,vr.saveOnIter{k,1});
    if numel(val)~=vr.saveOnIter{k,2}
        val
        error(['Length of ' vr.saveOnIter{k,1} 'is not' num2str(vr.saveOnIter{k,2})]);
    end
    vec = [vec; val(:)];
end

fwrite(vr.iterFileID,vec,'double');
