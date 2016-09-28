function [data] = createSaveStruct(mouseNum,experimenter,conds,whiteMazes,...
    leftMazes,mazeName,condition,leftTrial,whiteTrial,rewardSize,itiCorrect,itiMiss,...
    correct,leftTurn,whiteTurn,streak,startTime,stopTime,sessionStartTime,varargin)
%CREATECELL This is a function to create a structure with all information
%from a given trial. Runs at the completion of every trial
%
%To add fields which are used in every experiments, input a section for them
%above BEFORE varargin and sort them into the proper field below. For
%fields which will only be used in some experiments, there is no need to
%store them as an input argument. They will be created below in the
%variable argument section. 
%
%For variable fields, add a new case to the switch statement and follow the
%format provided. The case should be an uppercase string of the variable
%name. Inside the case statement, provide the name of the field and set it
%equal to 'varargin{i+1}'. 
%
%When calling the function, variable fields should be inputted like
%parameters for other matlab functions in the format, 'string',value. For
%example, to specify a variable named whiteDots, the arguments would look
%like (...,'whiteDots',vr.whiteDots). The string will be compared to the
%switch statement and must be identical (though case doesn't matter).
%
%mouseNum = animal number eg. 005
%experimenter = name of experimenter eg. ASM
%conds = cell array of conditions eg. {'Black Left', 'White Right'}
%whiteMazes = logical array of whether each condition is white or black
%leftMazes = logical array of whether each condition is left or right
%mazeName = name of maze
%itiCorrect = duration of ITI following correct trial
%itiMiss = duration of ITI following miss trial
%
%condition = which condition is current maze
%whiteDots = 1x8 logical of whether each alcove is white or black
%leftTrial = logical of whether correct answer is left or right
%whiteTrial = logical of whether correct answer is white or black
%
%
%correct = logical of whether result was correct
%leftTurn = logical of whether mouse turned left
%whiteTurn = logical of whether mouse turned toward white
%streak = numeric of mouse's current streak
%
%startTime = trial start time as datenum
%stopTime = trial stop time as datenum
%duration = trial duration as datenum

%Required fields. DO NOT MODIFY
data.info.mouse = mouseNum;
data.info.date = datestr(now,'yymmdd');
data.info.experimenter = experimenter;
data.info.conditions = conds;
data.info.itiCorrect = itiCorrect;
data.info.itiMiss = itiMiss;
data.info.name = mazeName;
data.result.correct = correct;
data.time.start = startTime;
data.time.stop = stopTime;

%MODIFY BELOW
%store info
data.info.whiteMazes = whiteMazes;
data.info.leftMazes = leftMazes;

%store maze design information
data.maze.condition = condition;
data.maze.leftTrial = leftTrial;
data.maze.whiteTrial = whiteTrial;

%store result information
data.result.rewardSize = rewardSize;
data.result.leftTurn = leftTurn;
data.result.whiteTurn = whiteTurn;
data.result.streak = streak;

%store time info
data.time.durationMatlabUnits = stopTime - startTime;
data.time.duration = second(data.time.durationMatlabUnits);
data.time.sessionStart = sessionStartTime;


%Variable Arguments
if isodd(length(varargin)) %check for odd varargin
    error('Must have even number of variable input arguments. Please list value following modifier');
end

for i=1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Arugment specifier must be a string. Please check vararg: ',num2str(i)]);
    end
    
    switch upper(varargin{i}) %ADD ARGUMENTS HERE
        case 'WHITEDOTS'
            data.maze.whiteDots = varargin{i+1};
        case 'NUMWHITE'
            data.maze.numWhite = varargin{i+1};
        case 'INTGRADED'
            data.maze.intGraded = varargin{i+1};
        case 'LENGTHFAC'
            data.maze.lengthFac = varargin{i+1};
        case 'SCALEFAC'
            data.maze.scaleFac = varargin{i+1};
        case 'TWOTOWERS'
            data.maze.twoTowers = varargin{i+1};
        case 'DELAY'
            data.maze.delay = varargin{i+1};
        case 'GREYFAC'
            data.maze.greyFac = varargin{i+1};
        case 'NETCOUNT'
            data.result.netCount = varargin{i+1};
        case 'BLOCK' 
            data.maze.block = varargin{i+1};
        case 'NUMREWPER'
            data.maze.numRewPer = varargin{i+1};
        case 'CRUTCHTRIAL'
            data.maze.crutchTrial = varargin{i+1};
        case 'CRUTCHIDENTITY'
            data.info.crutchIdentity = varargin{i+1};
        case 'LEFTDOTLOC'
            data.maze.leftDotLoc = varargin{i+1};
        case 'NUMLEFT' 
            data.maze.numLeft = varargin{i+1};
        case 'DELAYLENGTH'
            data.maze.delayLength = varargin{i+1};
    end

end

