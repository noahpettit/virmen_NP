function ops = getRigSettings(varargin)
% I am altering this to be a much more general function that can be called
% by other functions (such as calibration and testing functions)

switch nargin
    case 1
        rigName = varargin{1};
    case 0
        % try to determine rig name automatically
        [ret, name] = system('hostname');   
        if ret ~= 0
            % assumes PC
              name = getenv('COMPUTERNAME');
        end
        switch name
            case 'DESKTOP-E5K8NDE'
                rigName = 'noah_desktop';
        end
end

%
switch rigName
    case 'loki'
        ops.rigName = rigName;
        % daq settings
        ops.dev = 'dev1';
        ops.movementInput = 'ai1:3';
        ops.lickCh = 'port0/line5';
        ops.rewardCh = 'ao0';
        ops.airPuffCh = 'port0/line7';
        ops.doClock = {'Dev1/PFI1','Dev1/PFI2'};
        ops.analogSyncCh = 'ao1';
        ops.digitalSyncCh = 'p0.3';
        
        % base data directory settings
        ops.dataDirectory = 'C:\DATA\Noah\';
        
        % reward calibration info
        ops.pulseDur =      [0  0.01    0.05    0.1     0.2     ];
        ops.mL =            [0  0.0009  0.0056  0.0180  0.05    ];
        ops.uL = ops.mL*1000;
        
    otherwise
        error('rig name not found! check getRigDAQSettings.m');
end



end