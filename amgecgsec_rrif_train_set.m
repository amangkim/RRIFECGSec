% amgecgsec_rrif_train_set
% Access Path: C:\AMG_Lounge\Mathwork_AMG\amgecgdb\amgecgsec
% Made by Amang Kim
% Update: 4/1/2019

clear all;
amgecgsec_rrif_localsetup;
%amgecgdb_localsetup

%--------------------------------------------------
SigDB
SamplePath

NumofId
%NumofTrial;

StartTime;
EndTime;       % Sample time for generating [Sec]
PeakRatio     % Default annotation peak ratio for annotation

FileRecord =FileRecord(1:NumofId);
SampleTime = EndTime

disp('Ready for testing the trained data............');

pause;
%--------------------------------------------------
Dat4Train = [];
DBpath=SamplePath;

SRS = rrifpredictfcngen(DBpath, FileRecord, SampleTime);

TargetFull = [SigDB '_RefRRIFECG_FcnSet.mat']; 


disp(['Saving the record of ',TargetFull, '.......']);
save(TargetFull,'SRS')
disp(['Saving is competed..................................']);


for j = 1:NumofId
    Dat4Train = [Dat4Train; SRS(j).Dat4ML];
end

disp(['The Machine Learning Training is Ready..................................']);

