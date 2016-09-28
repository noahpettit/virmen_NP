%getLeftMazes.m

%function to convert leftMazes into array

%ASM 6/13/12

function [leftMazes] = getLeftMazes(exper)
    leftMazes = zeros(1,length(exper.variables.leftMazes));
    for k = 1:length(exper.variables.leftMazes)
        leftMazes(1,k) = str2double(exper.variables.leftMazes(k));
    end
end