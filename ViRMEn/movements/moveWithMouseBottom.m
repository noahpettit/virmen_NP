function velocity = moveWithDualSensors(vr)

velocity = [0 0 0 0];

% Access global mvData
global mvData
data = mvData;

offset = [1.685 1.686 1.686]; %calibrated 8/4, 9/7 AH

data = data - offset;

% Update velocity
alpha = -115; %-44 % gain change

velocity(1) = alpha*data(2)*cos(vr.position(4));
velocity(2) = alpha*data(1)*sin(vr.position(4));
velocity(4) = beta*data(2);