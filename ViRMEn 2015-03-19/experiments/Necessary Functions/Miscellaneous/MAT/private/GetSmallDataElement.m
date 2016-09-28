function [n, type, values]=GetSmallDataElement(fh, fileformat)
% GetSmallDataElement returns a small data element from a MAT-file
% 
% Example:
% [N, TYPE, VALUES]=GetSmallDataElement(FH, FILEFORMAT)
%       FH is the file handle from fopen
%       FILEFORMAT is 'ieee-le' for a little-endian MAT-file, 'ieee-be' for
%       big-endian.
%       N is the number of values in the data element
%       TYPE is the data class
%       VALUES contains the returned data
%
% ---------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright � The Author & King's College London 2006
% ---------------------------------------------------------------------
%                               LICENSE
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% ---------------------------------------------------------------------

% Revised: 21/09/06 Now works with big-endian files on Windows


mi=StandardMiCodes();


temp=fread(fh,2,'uint16=>uint16');
if strcmp(fileformat,'ieee-le')
    n=temp(2);
    type=temp(1);
else
    n=temp(1);
    type=temp(2);
end
try
    t=mi{type};
catch
    % Problem - likely mixed v6/v7 unicode
    % Try this
    % 08.10.11
    n=0;
    t='unknown';
    type=8;
    values=[];
    return
end
    

% Overcome unicode problem with MAT-files higher than v6
% Unicode can appear if mixed v6/v7 SAVES are used in a file
if strfind(t,'UTF')
    if strfind(t,'8')
        t='uint8';
    end
    if strfind(t,'16')
        t='uint16';
    end
    if strfind(t,'32')
        t='uint32';
    end
end

k=double(4/sizeof(t));
values=zeros(1,k,t);
for i=1:k
    values(i)=fread(fh,1,[t '=>' t]);
end

end