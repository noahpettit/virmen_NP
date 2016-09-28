function vr = jitters_fromTruncatedGeomDistr(vr)
% % example of inputs:
% vr.Ntrials = 200;                      % num trials in the whole session
% vr.pStimulatingTrials = 0.10;     % desired proportion of selected trials
% vr.pTruncatedDistrib = 0.4;      % distribution parameter. The min and max
%                                                % delays will be automatically assessed

nSamples_desired = vr.pStimulatingTrials * vr.Ntrials; %num of trials for stimulation
EV_desired = 1/vr.pStimulatingTrials;
p = vr.pTruncatedDistrib;

NumGeomDist = p * bsxfun(@power, (1-p), 0:49);
n_entries = find(NumGeomDist<=0.0001,1);
NumGeomDist = NumGeomDist(1:n_entries);
Dist = NumGeomDist / sum(NumGeomDist);
cumDist = cumsum(Dist);
EV = Dist * (1:n_entries)';
xl = (1:n_entries) + (EV_desired-EV);


%draw from a TRUNCATED GEOMETRIC DISTRIBUTION, slightly corrected.
cs = 0; %this will constrain the obtained sample to span the entire trial set
cnt = 0;
sign_p = [-1,1];
while (cs < 0.97*vr.Ntrials || cs > vr.Ntrials) && cnt < 200
    jitt = [];
    for i = 1:nSamples_desired %this could be done matrix-wise...
        a = rand;
        s = sign_p(unidrnd(2,1));
        jitt(i) = round(xl(find(cumDist >= a, 1)) +s*0.3*a); %the random correction is effective to avoid systematic biases in rounding xl values with decimal consistently =~.5
    end
    cs = sum(jitt);
    cnt = cnt+1;
end

if cnt == 200
    error('error in while loop - truncated geometric distribution. Check parameters.')
else
    vr.LEDjitt = jitt;
end
end