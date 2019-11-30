% amgecgsec_full_rriftesting
% Testing ECG Signals based on ecgiddb
% Access Path: C:\AMG_Lounge\Mathwork_AMG\Physionet\ecgiddb\__R02
% Solution of the paper Optimzied [0.35 37]
% Made 
clear all
amgecgsec_rrif_localsetup;

RefSet = load('amgecgsec_RefRRIFECG_FcnSet.mat');
REF=RefSet.SRS;
%--------------------------------------------------
NumofId = length(REF)
UnitFrame = REF(1).UnitFrame(2)
%--------------------------------------------------
TargetRecord = [FileRecord 999]; 
FileRecord = [FileRecord Unknown];


NumofTrial=150
NumofTestSample=length(FileRecord)

TestPath = SamplePath2
FileRecRef =FileRecord;
TestStart = StartTime;        % Duration for scanning
Set = [0.4 15];

TestEnd = Set(2)
pause;

%--------------------------------------------------

ID_sq=[];
VID_sq=[];
AP_ID_sq=[];
FalseDetect=[];
CorrectDetect=[];
PredictUnknown =[];
Accu_set = [];
UnknownCorrect = [];
KnownFalse = [];
PredictKnown = [];
Reject = [];
RRI_Delta = [];
% ---------------------------

for i1=1:NumofTrial
    
    TestID=ceil(rand*NumofTestSample);
    DB0_Idx = FileRecord(TestID);
    DB0_str = num2str(DB0_Idx);
    SampleName=[TestPath DB0_str '.mat'];
    Heading=[DB0_str,' (',num2str(TestID),')'];
    
    
    [d0,sfq]=loadecgamg(SampleName, TestStart, TestEnd,0);
    %stm = stmgen(sfq,SliceTime);
    d1= ecgpreprocess(sfq, d0, [1 1 1], 0);
    slot = [0:UnitFrame];    
    
    s2 =[];
    MAER = [];
    MSE0 = [];
    MSE00 = [];
    
    TestSt = ecgrpeakframe(d1, sfq);
    TrainDat = TestSt.RawDat;
    TestingECG =TestSt.Mean;
    UnitFrame = TestSt.UnitFrame;
    NumofSlice = TestSt.NumofSlice;
    Test_RRI = TestSt.RRave_sec; 
    mmse0 = mean(mseamg(TrainDat, TestingECG));
       
    %=============================================
    UCL0 = [];
    RefAPU =[];
    APU0 = [];
    Ref_sq = [];
	AER0 = [];
    
    MAER1 = [];
    TestAPU = [];
    
    TargetOutput = zeros(1,NumofId+1);

            
    %--------------------------
    for i2=1:NumofSlice
        OneSlice = TrainDat(:,i2);
                
        MSE0 = [];
        ERange = [];
        idx_ERange = 0;
               
        
        for j = 1:NumofId
            Ref_RRI = REF(j).RRI*ones(length(slot),1);
            Ref_sq = REF(j).RefFcn([Ref_RRI slot(:)]);
            mse0= mseamg(OneSlice, Ref_sq);
            %mse0= mseamg([Test_RRI; OneSlice], [Rrf_RRI; Ref_sq]);
            
            MSE0 = [MSE0 mse0];
            RRI_Delta = [RRI_Delta abs(Test_RRI-REF(j).RRI)/REF(j).RRI];
        end        

        ERange = MSE0;
        if min(ERange) >= 0.0046  
            TargetOutput(NumofId+1) = TargetOutput(NumofId+1)+1;
            Predict = TargetRecord(NumofId+1);
            PredictUnknown = [PredictUnknown DB0_Idx];
        else
            [min_ERange, idx_ERange] = min(ERange);
            TargetOutput(idx_ERange) = TargetOutput(idx_ERange)+1;
        end
                
    end
    %--------------------------
    
    TargetProb = TargetOutput/sum(TargetOutput);
    [max_Prob, Prob_idx]=max(TargetProb);
    Actual = DB0_Idx;

	if Actual > 900
        Actual = 999;
    end
    
    Predict = TargetRecord(Prob_idx);

    if max_Prob <= 0.52
        Reject = [Reject Actual];
        Actual = -1;
        Predict = -1;
    else
        if(Actual ~= Predict)
            FalseDetect=[FalseDetect; [Actual Predict]];
        else
            CorrectDetect=[CorrectDetect; [Actual Predict]];
        end
    end    
	ID_sq = [ID_sq  Actual];
	VID_sq = [VID_sq Predict];    
   
end

[ID_sq(:) VID_sq(:)];
FalseDetect;
CorrectDetect;
ValidSamples = NumofTrial - length(Reject)
acc = sum(VID_sq == ID_sq)./numel(ID_sq);
DetectionRate = 1-length(Reject)/NumofTrial

%---------------------------------- Confusion Matrix (SCK)
CorrectUnknown = length(find(CorrectDetect(:,1)>=900));
FalseUnknown = length(find(FalseDetect(:,1)>=900));
Correct = length(CorrectDetect(:,1))-CorrectUnknown;
False = length(FalseDetect(:,1))-FalseUnknown;

Confusion = [Correct FalseUnknown; False CorrectUnknown]

WithinDetect = (CorrectUnknown+Correct)/ ValidSamples;
disp(['The accuracy of the testing for ' num2str(ValidSamples) ' is ' num2str(WithinDetect*100) '%......']);
%---------------------------------------------------------
