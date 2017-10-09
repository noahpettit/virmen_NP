function ops = getRigSettings(varargin)
% I am altering this to be a much more general function that can be called
% by other functions (such as calibration and testing functions)
% either pass in rigName string, or no variables or empty string. second
% two cases matlab will try to determine rig automatically

switch nargin
    case 1
        rigName = varargin{1};
    case 0
        rigName = '0'; % flag to find automatically
end

%
switch rigName
    case 'loki'
        ops.rigName = rigName;
        % daq settings
        ops.dev = 'dev1';
        ops.movementCh = {'ai1','ai2','ai3'};
        ops.lickCh = 'ctr0'; % counter channel
        ops.rewardCh = 'port0/line2'; % note reward is now with digital channel!
        ops.airPuffCh = 'port0/line7';
        ops.doClock = {'Dev1/PFI1','Dev1/PFI2'};
        ops.outputSyncSignal = 1;
        ops.analogSyncCh = 'ao1';
        ops.digitalSyncCh = 'port0/line3';
        
        % base data directory settings
        ops.dataDirectory = 'C:\DATA\Noah\';
        
        % reward calibration info
        ops.pulseDur =      [0  0.01    0.05    0.1     0.2     ];
        ops.mL =            [0  0.0009  0.0056  0.0180  0.05    ];
        ops.uL = ops.mL*1000;
        
    case '0' % try to find name automatically
        disp('trying to identify computer automatically....');
        % try to determine rig name automatically
        name = getenv('COMPUTERNAME');
        switch name
            case 'DESKTOP-E5K8NDE'
                rigName = 'noah_desktop';
            case 'HARVEYLAB-PC'
                % note that this name may be the same across multiple rigs!
                % better to manually supply 
                rigName = 'loki';
            case 'harveylab'
                % this is how you could check using computer IP address /
                % hard address, etc
                % computer name is more elegant though 
                [status,cmdout] = system('ipconfig -all');
            otherwise
                error('rig name not found! check getRigDAQSettings.m');
        end
        disp(['computer identified as ' rigName]);
        ops = getRigSettings(rigName);
    otherwise
        error('rig name not found! check getRigDAQSettings.m'); 
        
end



end