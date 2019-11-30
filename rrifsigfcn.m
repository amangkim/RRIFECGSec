function [TrainedStruct] = rrifsigfcn(varargin)
% Generating the RR-Interval Framed sliced regference signal by using ML (in time domain)
%
% Usage:
%	[Structred_Reference (SR)] = rrifsigfcn (Sig_data, SampleFreq, TargetFrame, DisplayOption)
% Output: 
%   SR.SampleFreq:      Sampling Frequency
%   SR.NumberofSlice:   Number of slicing
%   SR.SliceWindow:     Sampling Time sequence
%   SR.RefData:         Base ECG data for the reference
%   SR.TrainData:       [[Time ECG]; Nx2] Training data
%   SR.RefFcn:          Regression Function with the time variables
% Input:
%   SliceTime [sec]:    Time for slicing the data [sec]
%   ECG_data:           ECG data from ML training
%   SampleFreq:         Sampling frequency of ECG data
%   CustFilter:          Off (0) or Custnomized filter
%   Display Option:     [0 (Off), 1 (2D-plot), 3(3D-plot)]
% 
% Note:
%   - Original m-code: ECGslice_time.m
%   - Required Matlab file(s): ECGtrainRegression, customfilter
%   - Adding the plotting feature
%   - Supporting 3D Plot option
%   - MSE of the data is included (SR.MSE)
%   - Revising the start index
%   - Allow the multiple input arguments
%	
% Made by Amang Kim [v0.2 || 7/1/2019]

%------------------------------------
inputs={'Sig_data', 'SampleFreq', 'TargetFrame', 'DisplayOption'};
TargetFrame = 220;
DisplayOption = 0;

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end
%------------------------------------

d1 = Sig_data(:);
sfq = SampleFreq;
a=rpeakdetect(0.6, sfq, d1,0);
NumSlice = length(a);

ecg1set = [];
ecg1 =[];
Dat4ML = [];
RRI0 = [];

UnitFrame = TargetFrame;
OneGrid = (UnitFrame /22);
slot = [0:UnitFrame];

ad = a(:,2);
[delt s]=  deltamean(ad);

ave_RR_sec = delt/sfq;
stm = [0:ave_RR_sec/UnitFrame:ave_RR_sec];
OneGrid_sec = (ave_RR_sec/UnitFrame)*OneGrid;


for i= 2:NumSlice    
    stidx = a(i-1,2);
    
    if stidx == 0
        i=i+1;
    end
    stidx = a(i-1,2);
    endidx = a(i,2);
    
    onelength = endidx - (stidx-1);
    ecg0 = d1(stidx:endidx);
    ecg1 = sqframechanger(ecg0,UnitFrame);
    
    ddecg=diff(diff(ecg1));
    ddl = length(find(ddecg)==0);
    qualidx = ddl/length(ddecg); %--------Threshold = 0.78
    
    if qualidx>=0.8
        ecg1set = [ecg1set ecg1];
        RRI=ave_RR_sec*ones(length(ecg1),1);
        Dat4ML = [Dat4ML; [RRI slot(:) ecg1]];  
    end

end

%--------------------- Regression Model
%[RefModel, RMSE_bar]= ECGtrainRegression(dat4train);
[RefModel, RMSE_bar]= RRIFMLModel(Dat4ML);
ref_plot=RefModel.predictFcn([RRI slot(:)]);

MSE0 = RMSE_bar^2;
%--------------------------------------

%---------------Diplay Option is ON
if DisplayOption==1
    plot(WindowTime,ref_plot,'r.-');
    hold off
end
%---------------- 3D Display Option
if DisplayOption==3
    dat3D(:,la+1) = ref_plot(:);
    slice_sq =[slice_sq la+1];
    
    figure
    hold on
    %xlabel(['sliced samples (' num2str(la) ')']);
    grid on 
    xlabel('sliced samples');
    zlabel('ECG amplitude (mV or V)');
    %ylabel(['Window Time (' num2str (WindowTime) '[sec])']);
    ylabel('Window Time (sec)');
    surf (slice_sq, WindowTime, dat3D);
    grid off
    hold off
    %mesh(dat3D);
end
%----------------------------------

%---------------------------------------
S.RefFcn = RefModel.predictFcn;
S.MSE = MSE0;
S.NumSlice = NumSlice;
S.UnitFrame = UnitFrame;
S.RR_Int  = ave_RR_sec;

TrainedStruct=S;
%---------------------------------------

end