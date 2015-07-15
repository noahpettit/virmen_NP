function velocity = dualSensor_noStrafe(vr)

velocity = [0 0 0 0];

% Access global mvData
global mvData
data = mvData;

offset = [1.687 1.687 1.687];

data = data - offset;

% Update velocity
alpha = -115; %-44
beta = -4;
velocity(1) = alpha*data(1)*cos(vr.position(4));
velocity(2) = alpha*data(1)*sin(vr.position(4));
velocity(4) = beta*data(2);