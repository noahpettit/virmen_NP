function vr = giveRewardPump(vr, nRewards)

% calibrate here microsteps per ml
% ml per microstep
mlPerStep = 0.1650/1000;
stepPerML = 1/mlPerStep;

rewardSize = 0.004;
multiplier = 1;

nStepsPerReward = rewardSize/mlPerStep;

nSteps = round(nStepsPerReward*nRewards*multiplier);

if isempty(vr)
    % then we're in manual delivery mode
    delete(instrfind);
    vr = struct();
end

try

if ~isfield(vr, 'rewardPump')
    % initialize reward pump 
    vr.rewardPump.arduino = arduino('COM12', 'Uno', 'Libraries', 'Adafruit\MotorShieldV2');
    vr.rewardPump.shield = addon(vr.rewardPump.arduino, 'Adafruit\MotorShieldV2');
    vr.rewardPump.sm = stepper(vr.rewardPump.shield, 1, 200, 'RPM', 1000, 'StepType','double');
    vr.rewardPump.sm.RPM = 1000;
end
move(vr.rewardPump.sm,nSteps);
release(vr.rewardPump.sm);

catch
    delete(instrfind);
if ~isfield(vr, 'rewardPump')
    % initialize reward pump 
    vr.rewardPump.arduino = arduino('COM12', 'Uno', 'Libraries', 'Adafruit\MotorShieldV2');
    vr.rewardPump.shield = addon(vr.rewardPump.arduino, 'Adafruit\MotorShieldV2');
    vr.rewardPump.sm = stepper(vr.rewardPump.shield, 1, 200, 'RPM', 1000, 'StepType','double');
    vr.rewardPump.sm.RPM = 1000;
end
move(vr.rewardPump.sm,nSteps);
release(vr.rewardPump.sm);
end


end