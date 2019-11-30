function [RRFramedECG] = ecgrpeakframe(varargin)
% Slicing the ECG signal based on the RR-Peaks for using ML training
%
% Usage:
%	[RRFramedECG (RRF)] = ecgrpeakframe(OrignalData, Freq, TargetFrame, Display)
%
% Output: 
%   RRF.NumofSlice   : Number of slice
%   RRF.RRave_sec    : Average R-R duration [sec]
%   RRF.Mean         : Reference plot based on the Mean
%   RRF.Mode         : Reference plot based on the Mode 
%   RRF.RawDat       : Sliced dataset [MxN]
%
% Input:
%   OrignalData     : Original ECG data
%   Freq            : Sampling frequency of ECG data
%   TargetFrame     : Target number of grids between one RR-peaks
%   Display         : Display option [0 (Off), 1 (2D-plot), 3(3D-plot)]
% 
% Note:
%   - Required Matlab file(s): sqframechanger, deltamean, rpeakdetect
%   - Supporting 3D Plot option
%   - Allow the multiple input arguments
%	
% Made by Amang Kim [v0.3 || 7/1/2019]


%------------------------------------
inputs={'OrignalData', 'Freq', 'TargetFrame', 'DispOptn'};
DispOptn = 0;
TargetFrame  = 220;

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end
%------------------------------------

d1 = OrignalData(:);
sfq = Freq;
a=rpeakdetect(0.6, sfq, d1,0);
NumSlice = length(a);

ecg1set = [];
ecg1 =[];
Dat4ML = [];

UnitFrame = TargetFrame;
OneGrid = (UnitFrame /22);

ad = a(:,2);
[delt s]=  deltamean(ad);

ave_RR_sec = delt/sfq;
stm = [0:ave_RR_sec/UnitFrame:ave_RR_sec];

RR_sec = s./sfq;
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
        %Dat4ML = [Dat4ML; [stm(:) ecg1]];  
    end
end

MeanPlot = mean(ecg1set,2);
ModePlot = mode(ecg1set,2);

[m n] = size(ecg1set);

if DispOptn==1 %--------------------------------------------
    
    figure
    hold on
    ax = gca;
    ax.XLim = [0 ave_RR_sec];
    title(['R-R Peak Cycle ECG Signal (Unit Frame = ' num2str(UnitFrame) ')']);
    xlabel('Time [sec]');
    ylabel('Amplitute [mV]');
    grid on
    plot(stm, ecg1set);
    hold off

end
if DispOptn==3 %--------------------------------------------
    
    figure
    hold on
    ax = gca;
    ax.YLim = [0 ave_RR_sec];
    title(['R-R Peak Cycle ECG Signal (Unit Frame = ' num2str(UnitFrame) ')']);
    xlabel(['Sliced Samples (' num2str(n) ')']);
    ylabel('Time [sec]');
    zlabel('Amplitute [mV]');
    grid on
    surf([1:n],stm, ecg1set);
    hold off

end %------------------------------------------------------


%----------------------------------
R.NumofSlice = n;
R.UnitFrame = UnitFrame;
R.RRave_sec = ave_RR_sec;
R.RR_sec = RR_sec;
R.Mean = MeanPlot;
R.Mode = ModePlot;
R.RawDat = ecg1set;
%R.Dat4ML = Dat4ML;

RRFramedECG=R;
%----------------------------------


end

