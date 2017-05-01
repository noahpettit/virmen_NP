function vr = rewardTone(vr, duration)

if ~isfield(vr, 'arduino');
    vr.arduino = [];
end

if isempty(vr.arduino);
    vr.arduino = serial('COM9','BaudRate',9600);
    fopen(vr.arduino);
    pause(2);
end

uint8(round(duration*255));
fwrite(vr.arduino,uint8(round(duration*255)),'uint8');

end