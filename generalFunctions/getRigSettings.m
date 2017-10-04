function ops = getRigSettings(rigName)
% I am altering this to be a much more general function that can be called
% by other functions (such as calibration and testing functions)

switch rigName
    case 'loki'
        % daq settings
        ops.dev = 'dev1';
        ops.movementInput = 'ai1:3';
        ops.lickCh = 'p0.5';
        ops.rewardCh = 'ao0';
        ops.airPuffCh = 'p0.7';
        ops.analogSyncCh = 'ao1';
        ops.digitalSyncCh = 'p0.3';
        
        % base data directory settings
        ops.dataDirectory = 'C:\DATA\Noah\';
        
        % reward calibration info
        ops.pulseDur =      [0  0.01    0.05    0.1     0.2];
        ops.mL =            [0  0.0009  0.0056  0.0180  0.05];
        ops.uL = ops.mL*1000;
        
    otherwise
        error('rig name not found! check getRigDAQSettings.m');
end



end