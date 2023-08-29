function [RevisedData, NumofSlot] = sqframechanger(varargin)
% Changing the sampling squence frame of the signal
%
% Usage:
%    [RevisedData, NumofSlot] = sqframechanger(OriginalData,TargetFrame,DispOptn)
% Output:
%   RevisedData	: Revised signal after framing the original data
%   NumofSlot   : Number of slots for the original data (length -1)
% Input: 
%   OrignalData : Original signal (ECG) data
%   TargetFrame : Original Signal to change the frequency
%   DispOptn    : Ploting the comparison graphes between two signals
%
% Note:
%   - Required function for the timesliced ECG framing 
%   - DispOptn: Display option for ploting [0 - Off, 1 - On]
%
% Made by Amang Kim [v0.2 Draft || 4/10/2019]
% Package of amgecg (Amang ECG) Toolbox [Rel Ver. 0.6 || 4/18/2019]



%------------------------------------
inputs={'OrignalData', 'TargetFrame', 'DispOptn'};
DispOptn = 0;
TargetFrame  = 220;

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end
%------------------------------------
DataLen = length(OrignalData);
ecg0 = OrignalData(:);
ecg1 =[];

UnitFrame = TargetFrame;

stidx = 1;
endidx = DataLen;
onelength = endidx - (stidx-1);
sq0len = onelength-1;

%onelength
len_b=lcm(UnitFrame,onelength);
ecg_b=zeros(len_b,1);

%=================================

sq0 = [0:sq0len];
sq1 = [0:sq0len/UnitFrame:sq0len];
sqb = [0:sq0len/len_b:sq0len];
[idx_0 idx_b]=find(abs(sq0(:)-sqb(:)')<0.005);

ecg_b([idx_b])=ecg0([idx_0]);
base_ref = [idx_b ecg_b(idx_b)];

base_len = length(idx_b);

for i=1:base_len-1
    st_idx=idx_b(i);
    ed_idx=idx_b(i+1);
    idx_num = ed_idx - st_idx -1;
    
    for j=1:idx_num
        ecg_b(st_idx+j)= ecg_b(st_idx)+(ecg_b(ed_idx)-ecg_b(st_idx))*(j/(idx_num+1));               
    end    
    
end

[idx_1 idx_1b]=find(abs(sq1(:)-sqb(:)')<0.005);
ecg1([idx_1])=ecg_b([idx_1b]);

%=================================

RevisedData = ecg1(:);
NumofSlot = sq0len;

if DispOptn==1 %--------------------------------------------    
    figure
        
    subplot(2,1,1);
    ax1 = gca;
    ax1.XLim = [0 onelength-1];
    plot(sq0,ecg0);
	title (['Original Signal (Number of Slots =' num2str(onelength-1) ')' ]);

    subplot(2,1,2);
    ax2 = gca;
    ax2.XLim = [0 UnitFrame];
    plot([0:UnitFrame],ecg1, 'r');
    title (['Revised Signal (Number of Slots =' num2str(UnitFrame) ')']); 
    
end %------------------------------------------------------

end