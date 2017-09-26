function [] = saveIter(vr)

iterVec = [];
for k = 1:size(vr.session.saveVar,1)
    iterVec = [iterVec;reshape(eval(['vr.' vr.session.saveVar{k,1}]),vr.session.saveVar{k,2},1)];
end
if length(iterVec)<28
iterVec(length(iterVec)+1:28) = 0;
end
fwrite(vr.iterFileID,iterVec,'double');

end