function velocity = moveWithDualSensors_linear(vr)

velocity = [0 0 0 0];

% Access global mvData
global mvData
data = mvData;

% disp(data); % leaving this here for calibration purposes 

if ~isfield(vr, 'ops');
    vr.ops = getRigSettings;
end
    

offset = vr.ops.ballSensorOffset;

data = data - offset;

forwardGain = vr.ops.forwardGain;
viewAngleGain = 0;%vr.ops.viewAngleGain;

% Update velocity
alpha = forwardGain; % = -115; %-44 % gain
beta = viewAngleGain; % = -1;

velocity(1) = alpha*data(1)*cos(vr.position(4));
velocity(2) = alpha*data(1)*sin(vr.position(4));
velocity(4) = beta*data(2);

% disp(vr.position);
% disp([vr.position velocity]);