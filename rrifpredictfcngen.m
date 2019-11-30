function [Structed_Ref_Set] = rrifpredictfcngen(varargin)
% Generating the RR-Interval Framed Sliced ECG Reference Structured Set by using ML
%
% Usage:
%	[Structed_Ref_Set (SRS)] = rrifpredictfcngen(DBpath, FileRecord, SampleTime, SliceTime, FilGenOptn)
%
% Output: SRS([1:SampleSize])
%   SRS.ID          :  Signal ID (file name) ['String']
%   SRS.NumofSlice  :  Number of training slices for each ECG signal [1 x 1] 
%   SRS.ECG_Ref     :  Trained ECG signals [SliceTime x 1]
%   SRS.MSE         :  Mean Square Error between Sliced signal and Reference Signal [1 x NumberOfSlice]
%   SRS.RMSER       :  Error ratio of the root MSE [1 x NumberOfSlice]
%   SRS.AccuR       :  Accuracy rate based on the variance
%
% Input:
%   DBpath       :  Path of ECG database (either local or webDB) ['String']
%   FileRecord   :  The set of file names to be trained [1 x N]
%   SampleTime   :  Sampling Time [sec] [1 x 1]
%   SliceTime    :  Time for slice (template size) [1 x 1]
%
% Note:
%   - Required Matlab file(s): rangecontrol, sigslice_td, ecgpreprocess
%   - SampleSize = length (FileRecord)
%   - The reference is generated in the time domain
%   - Updating the reference ECG set structure
%   - Preprocess package is applied (ecgpreprocess)
%	
% Made by Amang Kim [v0.1 || 5/15/2019]



%(DBpath, FileRecord, SampleTime, SliceTime)
%-----------------------------
inputs={'DBpath', 'FileRecord', 'SampleTime', 'UnitFrame'};
UnitFrame = 220;

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end

%-----------------------------



%----------------------------------
SamplePath = DBpath;
StartTime = 0;
EndTime = SampleTime; 	% Sample time for generating [Sec]
NumofId = length(FileRecord);
%----------------------------------

PeakRatio = 0.6;                % Default annotation peak ratio
%----------------------------------


%---------------- Initial Output Setup
ref_dat=[];         % Reference Matrix
TrainRMSE=[];       % RSME 
BaseF=[];
ID_str0=[];
pre_idx=0;

PDFSet =[];


for i1=1:NumofId %-----------------------------------------------

    DB0_Idx = FileRecord(i1);
    DB0_str = num2str(DB0_Idx);
    SampleName=[SamplePath DB0_str '.mat'];
    disp (['Training the data of [' DB0_str ']...........']);
        
    [d0, sfq] = loadecgamg(SampleName,StartTime,EndTime);
    d1 =  ecgpreprocess(sfq, d0(:), [1 1 1], 0); %--------------nsrdb testing case
    TS = rrifsigfcn(d1, sfq, UnitFrame);
        

%------------------------------------------------
SRS(i1).ID = FileRecord(i1);
SRS(i1).DBPath = SamplePath;
SRS(i1).SampleTime = SampleTime;
SRS(i1).UnitFrame = [0 UnitFrame];
SRS(i1).NumofSlice = TS.NumSlice;
SRS(i1).RRI = TS.RR_Int;
SRS(i1).RefFcn = TS.RefFcn;
%------------------------------------------------
    
end %----------------------------------------------------- 

Structed_Ref_Set = SRS;


end % 2019 GitHub, Inc.
