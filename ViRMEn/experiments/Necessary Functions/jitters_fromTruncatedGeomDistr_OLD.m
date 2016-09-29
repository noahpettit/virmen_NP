function vr = jitters_fromTruncatedGeomDistr(vr)
% TRUNCATED GEOMETRIC DISTRIBUTION. Need to set parameters based on the
% desired expected value.


% % EV == 20   % 10% of trials
nSamples = 20; %IMPORTANT! change accordingly to desired proportion
minDelay = 9; 
maxDelay = 22;
multiplicateby = 1;
p= .5;

% % % EV == 5.0445   % ~20% USED FIRST TIMES
% nSamples = 40; %IMPORTANT! change accordingly to desired proportion
% minDelay = 4; 
% maxDelay = 10;
% multiplicateby = 1;
% p= .47;

% % EV == 4.9549   % ~20%
% nSamples = 40; %IMPORTANT! change accordingly to desired proprotion
% minDelay = 3; 
% maxDelay = 11;
% multiplicateby = 1;
% p= .3;

% % EV == 4.0403   % ~25%
% nSamples = 50; %IMPORTANT! change accordingly to desired proprotion
% minDelay = 3;
% maxDelay = 10;
% multiplicateby = 1;
% p= .48;


% first create the vector of the geometric distribution (numerator)
NumGeomDist = zeros(1, maxDelay - minDelay + 1);
for i = 1: maxDelay - minDelay + 1
    NumGeomDist(i) = p*(1-p)^(i-1);
end
% denominator of the truncated geometric distribution
Denom = sum(NumGeomDist);
% truncated geometric distribution of probabilities
P=NumGeomDist/Denom;
xl = multiplicateby*(minDelay:maxDelay);
PP = cumsum(P);
EV = P*xl';
vr.pLEDtrials = 1/EV;


% RANDOM DRAWING FROM THE GEOMETRIC DISTRIBUTION:
cs = 0; %constrain the obtained sample to span the entire trial set
cnt = 0;
while (cs < 0.97*vr.Ntrials || cs > vr.Ntrials) && cnt < 200 
    jitt = [];
    for i = 1:nSamples %this could be done matrix-wise... 
        a = rand;
        jitt(i) = xl(find(PP >= a, 1));
    end
    cs = sum(jitt);
    cnt = cnt+1;
end
if cnt == 200
    error('error in while loop')
else
    vr.LEDjitt = jitt;
end
end
