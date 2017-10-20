function vr = commonTermination(vr)

daqreset;
fclose(vr.iterFileID);
fclose(vr.trialFileID);
