%rrifcorescript
%RRIF_Core_Script

%amgecgsec_rrif_localsetup;

%---------------------------------------------
FileRecord =[kucsu edb];
TargetRecord = [FileRecord 999]; 
FileRecord = [FileRecord Unknown];
%FileRecord = Unknown;

%NumofTrial=150
NumofTestSample=length(FileRecord)
NumofTrial=NumofTestSample;

TestPath = SamplePath2
FileRecRef =FileRecord;
TestStart = StartTime;        % Duration for scanning

%Set = [0.4 15] % [87/150 92.924%]
%Set = [0.4 30] % [90/150 90%]

Set = [0.4 15];

TestEnd = Set(2);

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
    
    %TestID=ceil(rand*NumofTestSample);
    TestID=i1;
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
        % UCL @220 [5.4283e-05 0.0023 0.0193]    0.0064            
        if min(ERange) >= UCL_val  
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

    % Training @ 220 -- APR_min_mean_max: [0.5200 0.7831 0.9714]   
    if max_Prob <= 0.52
        Reject = [Reject Actual];
        Actual = -1;
        Predict = -1;
    else
        if(Actual ~= Predict)
            FalseDetect=[FalseDetect; [Actual Predict]];
            %------------------------ Module for Checking Sliced ECG        
            %rrif_checksum;
            %-------------------------------------------------------
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
%UnknownFalse = length(Unknown) - length(UnknownCorrect);
%False = length(FalseDetect(:,1))-UnknownFalse-length(find(FalseDetect(:,1) == PredictUnknown));

CorrectUnknown = length(find(CorrectDetect(:,1)>=900));
FalseUnknown = length(find(FalseDetect(:,1)>=900));
Correct = length(CorrectDetect(:,1))-CorrectUnknown;
False = length(FalseDetect(:,1))-FalseUnknown;

%Confusion = [Correct CorrectUnknown; False FalseUnknown]
%Confusion = [Correct False; FalseUnknown CorrectUnknown]

Confusion = [Correct FalseUnknown; False CorrectUnknown]
%WithinDetect = Confusion(1,1)/(Correct+False);
WithinDetect = (CorrectUnknown+Correct)/ ValidSamples;
disp(['The accuracy of the testing for ' num2str(ValidSamples) ' is ' num2str(WithinDetect*100) '%......']);
%---------------------------------------------------------
