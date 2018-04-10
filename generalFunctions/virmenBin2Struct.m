function vstruct = virmenBin2Struct(iterBin,varNames)
% iter binary is the file path of the binary file var names is a nx2 cell
% array listing variables saved in the vbinary file, where the first column
% is the name of that variable and the second column is the length of that
% variable
%% 
keyboard;
fid = fopen(iterBin);
A = fread(fid,'double');

vsize = cell2mat(varNames(:,2));
A = reshape(A,sum(vsize),length(A)/sum(vsize));

% make into a structure.
f = varNames(:,1); % field names
c = mat2cell(A,vsize,size(A,2));
vstruct = cell2struct(c,f,1);

fclose(fid);
