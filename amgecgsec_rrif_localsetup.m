% amgecgsec_rrif_localsetup
% Collected dataset for demostrating the time sliced ECG
% Sources from nsrdb, edb, eiddb from physionet and cse (KU) data
% Data Access: C:\AMG_Lounge\Mathwork_AMG\amgecgdb\amgecgsec
% Data Revision: R07
% Update: 2019.06.26

%--------------- Path & Filename Setup

SigDB = 'amgecgsec';
OriginalPath = 'C:\AMG_Lounge\Mathwork_AMG\Physionet\nsrdb\';
SamplePath='D:\Mathwork_AMG\amgecgdb\amgecgsec\train\';
SamplePath2 = 'D:\Mathwork_AMG\amgecgdb\amgecgsec\test\';

%--------Full FileRecord R05
%kucsu = [101:125]; 
%edb = [401:450];

kucsu = [101:125]; 
edb = [401:435];
Unknown = [901:910];

FileRecord =[kucsu edb];


%-----------------------
PeakRatio = 0.6;    % Default annotation peak ratio for annotation
%FileRecord = [101:115];
%Unknown = [117:128];

SampleSize = length (FileRecord);

% ------------ Required Values

NumofId = SampleSize;
%NumofTrial = 60;

StartTime = 0;
EndTime = 50;       % Sample time for generating [Sec]
%SliceTime = 0.6;
UnitFrame = 220;
%------------------------------------   


