function velocity = moveWithDualSensors(vr)

velocity = [0 0 0 0];

% Access global mvData
global mvData
data = mvData;

%disp(data); % leaving this here for calibration purposes 

offset = [1.7140    1.7140    1.7145]; %calibrated 1/24/2017 NP

data = data - offset;

% Update velocity
alpha = vr.session.forwardGain; % = -115; %-44 % gain
beta = vr.session.viewAngleGain; % = -1;

velocity(1) = alpha*data(1)*cos(vr.position(4));
velocity(2) = alpha*data(1)*sin(vr.position(4));
velocity(4) = beta*data(2);