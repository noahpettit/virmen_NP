function [out] = dNumToMin(dNum)
%dNumToMin.m Takes in date number and converts to minutes

dVec = datevec(dNum);
out = 60*dVec(4) + dVec(5) + dVec(6)/60;