function daqcallback_PP(obj, event)
%DAQCALLBACK Display event information for the specified event.
%
%    DAQCALLBACK(OBJ, EVENT) a callback function which displays a 
%    message which contains the type of the event and the name 
%    of the object which caused the event to occur.  If an error
%    event occurs, the time of the event and the error message 
%    is also displayed.
%
%    By default, an analog input object's DataMissedFcn and 
%    RuntimeErrorFcn properties are set to @daqcallback and an 
%    analog output object's RuntimeErrorFcn property is set to 
%    @daqcallback.
%
%    If the event type is DataMissed, the object is stopped. 
%
%    DAQCALLBACK should only be used as a property value for a
%    callback property.  To display event information on an object,
%    SHOWDAQEVENTS should be used.
%
%    Example:
%      ai = analoginput('winsound');
%      addchannel(ai, 1);
%      set(ai, 'TriggerFcn', @daqcallback);
%
%    See also DAQHELP, PROPINFO, SHOWDAQEVENTS, DEMODAQ_CALLBACK.
%

%    MP 9-21-98
%    Copyright 1998-2005 The MathWorks, Inc.
%    $Revision: 1.2.2.6 $  $Date: 2005/06/27 22:31:52 $

% Define error message.
error1 = 'Type ''daqhelp daqcallback'' for an example using DAQCALLBACK.';

switch nargin
case 0
   error('daq:daqcallback:argcheck', 'This function may not be called with 0 inputs.\nType ''daqhelp daqcallback'' for an example using DAQCALLBACK.');
case 1
   error('daq:daqcallback:argcheck', error1);
case 2
   if ~isa(obj, 'daqdevice') || ~isa(event, 'struct')
      error('daq:daqcallback:argcheck', error1);
   end   
   if ~(isfield(event, 'Type') && isfield(event, 'Data'))
      error('daq:daqcallback:argcheck', error1);
   end
end
  

% Determine the type of event.
EventType = event.Type;

switch lower(EventType)
case {'start', 'trigger', 'stop', 'timer', 'samplesacquired', 'samplesoutput', 'error'}
   % Determine the time of the error event.
   EventData = event.Data;
   EventDataTime = EventData.AbsTime;
   
   % Convert the clock time to a datenum so that it can be converted to the
   % display string.
   EventDataTime = num2cell(EventDataTime);
   EventDataTime = datenum(EventDataTime{:});

   % Create a display indicating the type of event, the time of the event and
   % the name of the object.
   fprintf([EventType ' event occurred at ' datestr(EventDataTime,13),...
         ' for the object: ' obj.Name '.\n']);
   %PP
%    stop(obj)
   putvalue(obj, 0)
   global LED_TimedOut
   LED_TimedOut = 1;
%    assignin('base','LED_TimedOut',LED_TimedOut); 
   fprintf([obj.Name ' turned off - but not stopped - by ' EventType ' at ' datestr(EventDataTime,13),...
        '.\n']);
   % PP
   
   
   % Display the error string.
   if strcmp(lower(EventType), 'error')
      fprintf([EventData.String '\n']);
   end
case 'datamissed'
   % Create a display indicating the type of event and the name of the 
   % object.
   fprintf([EventType ' event occurred for the object: ' obj.Name '.\n']);
   stop(obj)
otherwise
   % Create a display indicating the type of event and the name of the 
   % object.
   fprintf([EventType ' event occurred for the object: ' obj.Name '.\n']);
end



