function [vr] = commonTerminationVIRMEN(vr)
%commonTerminationVIRMEN This function contains the common termination
%information for every virmen maze

fclose(vr.fid);
if vr.numTrials ~= 0
    [dataCell] = catCells2011(vr.pathTempMatCell,'data'); %#ok<NASGU>
    save(vr.pathMatCell,'dataCell');
    delete(vr.pathTempMatCell);
end
copyfile(vr.pathTempMat,vr.pathMat);
copyfile(vr.pathTempDat,vr.pathDat);
delete(vr.pathTempMat);
fid = fopen(vr.pathDat);
data = fread(fid,'float');
data = reshape(data,str2double(vr.exper.variables.reshapeSize),...
    numel(data)/str2double(vr.exper.variables.reshapeSize));
assignin('base','data',data);
stop(vr.ai)
stop(vr.dio)
putvalue(vr.dio, 0);
save(vr.pathMat,'data','vr','-append');
delete(vr.dio)
fclose(fid);
end

