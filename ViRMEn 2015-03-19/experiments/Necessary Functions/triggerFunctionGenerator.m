function [vr] = triggerFunctionGenerator(vr)
%draft
%triggerFunctionGenerator triggers a change of state in the function
%generator (on --> off; off --> on) 
% 
% parameters for the function generator (implemented separately)
% vr.OPTOphase: switch/case: 'cue', 'delay', 'reward'
% vr.OPTOispulses: 0 single pulse ON for entire phase duration
%                  1 many pulses ON at given frequency, for entire phase duration
% vr.OPTOduration: 
% vr.OPTOfrequency

pulseDur = 0.0006; %seconds

if ~vr.debugMode
    actualRate = get(vr.aoOPTO,'SampleRate'); %get sample rate
    pulselength=ceil(actualRate*pulseDur); %find duration (rate*duration in seconds *numRew)
    pulsedata=5.0*ones(pulselength,1); %5V amplitude
    pulsedata(pulselength)=0; %reset to 0V at last time point
    putdata(vr.ao,pulsedata);
    start(vr.ao);
    wait(vr.ao,5); %not clear why and how long. check better
end
% PP notes
%make sure you save trials with stimulation, add one more inptut channel,
%directly split from the output

end

