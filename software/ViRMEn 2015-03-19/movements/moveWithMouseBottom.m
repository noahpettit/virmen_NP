function velocity = moveWithMouseBottom(vr)

velocity = [0 0 0 0];

% Access global mvData
global mvData
data = mvData;

% Update velocity
alpha = -30; %-44
beta = 0.3; %-0.4
velocity(1) = alpha*data(1)*cos(vr.position(4));
velocity(2) = alpha*data(1)*sin(vr.position(4));
velocity(4) = beta*data(2);