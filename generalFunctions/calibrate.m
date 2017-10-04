function calibrate(n_pulses, delay, duration)

if nargin < 3
    duration = 0.2; % .012 -.029 duration = 0.035; %alice 130305
end
if nargin < 2
    delay = .5;
end
if nargin < 1
    n_pulses = 600;
end

daqreset;
aout=analogoutput('nidaq','Dev1');
d_to_a_solenoid=addchannel(aout,0); %can change to 0 1 2 or 3

% set up output pulse for solenoid

set (aout,'SampleRate',1000);
ActualRate = get(aout,'SampleRate');
pulselength=ActualRate*duration;
pulsedata=5.0*ones(pulselength,1); %5V amplitude
pulsedata(pulselength)=0; %reset to 0V at last time point

%set up number of pulses and pause between
for i=1:n_pulses
    disp(['i = ',num2str(i)]);
putdata(aout,pulsedata);
start(aout);
wait(aout,5);
pause(delay);
end


