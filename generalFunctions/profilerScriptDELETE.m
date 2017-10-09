
ind = cumsum(sz);
vec = zeros(sum(sz),1);
for k =1:size(vr.saveOnTrial,1)
    val = getfield(vr.trial(vr.tN),vr.saveOnTrial{k,1});
    vec(ind(k):ind(k)+sz(k)-1) = val(:);
end
