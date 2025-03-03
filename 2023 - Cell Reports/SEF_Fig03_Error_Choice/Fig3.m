%% Fig3.m -- Figure 3 header file
%**Note: Run plot_SDF_ErrChoice.m to get sdfAC sdfAE sdfFC sdfFE
% 
AREA = {'SEF'};
MONKEY = {'D','E'};
UNIT_PLOT = 134;

% plot_SDF_ErrChoice(behavData, unitData, 'area',AREA, 'monkey',MONKEY, 'uID',UNIT_PLOT) %Fig. 3A
% plot_Raster_ErrChoice(behavData, unitData, 'area',AREA, 'monkey',MONKEY, 'uID',UNIT_PLOT) %Fig. 3A

idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxFunction = ismember(unitData.CE, [-1,1]);
idxKeep = (idxArea & idxMonkey & idxFunction);
unitTest = unitData(idxKeep,:);
clear idx*

%Figures 3B, S3A
% Fig3B_EndptSS_Distr(behavData, 'monkey',MONKEY)

%Figures 3C, S3B,C,D
% Fig3C_Distr_tErrorChoice_SAT( unitTest )
% Fig3D_Barplot_CESignal( unitTest )

%Figures S3E-H
% Run script plot_SDF_X_Dir_RF_ErrChoice to calculate ratio rho for Fig.
% S3E. This script also plots individual neuron data (Figs. S3F-H).

%Response to reviews
% plot_ISI_X_Sacc2Endpt(behavData)
% plot_SpkCt_X_Sacc2Endpt(behavData, unitTest)


%% Compute magnitude of the choice error signal
nUnit = size(unitTest,1);
TWIN_TEST = ( 0 : +400); %test window re saccade onset

%initialize mean activation X condition X outcome
A.AC = NaN(nUnit,1); %Accurate Correct
A.AE = A.AC; %Accurate Error
A.FC = A.AC; %Fast Correct
A.FET = A.AC; %Fast Error then Target
A.FED = A.AC; %Fast Error then Distractor

for uu = 1:nUnit
  fprintf('%s \n', unitTest.ID{uu})
  kk = unitTest.SessionID(uu); %get session number

  %index by isolation quality
  idxIsoSAT = removeTrials_Isolation(unitTest.isoSAT{uu}, behavData.NumTrials(kk));
  %index by trial outcome
  idxCorrSAT = behavData.Correct{kk};
  idxErrChoice = behavData.ErrChoice{kk};
  %index by condition (SAT)
  idxAcc = ((behavData.Condition{kk} == 1) & ~idxIsoSAT);
  idxFast = ((behavData.Condition{kk} == 3) & ~idxIsoSAT);
  %index by second saccade endpoint
  idxTgt   = (behavData.Sacc2_Endpoint{kk} == 1);
  idxDistr = ismember(behavData.Sacc2_Endpoint{kk}, [2,3]);

  %Compute spike density function and align to epochs of interest
  spikesSAT = load_spikes_SAT(unitTest.Unit(uu), 'task','Search', 'user','Thomas Reppert');
  sdfSAT.VR  = compute_SDF_SAT(spikesSAT);
  sdfSAT.PS  = align_signal_on_response(sdfSAT.VR, behavData.Sacc_RT{kk});
  
  %Compute mean SDF across directions (re. primary saccade onset)
  sdfAccCorr  = mean(sdfSAT.PS(idxAcc & idxCorrSAT, 3500+TWIN_TEST),'omitnan');
  sdfFastCorr = mean(sdfSAT.PS(idxFast & idxCorrSAT, 3500+TWIN_TEST),'omitnan');
  sdfAccErr   = mean(sdfSAT.PS(idxAcc & idxErrChoice, 3500+TWIN_TEST),'omitnan');
  sdfFastErrT  = mean(sdfSAT.PS(idxFast & idxErrChoice & idxTgt,   3500+TWIN_TEST),'omitnan');
  sdfFastErrD  = mean(sdfSAT.PS(idxFast & idxErrChoice & idxDistr, 3500+TWIN_TEST),'omitnan');

  %Compute mean activation across time window of interest
  A.AC(uu) = mean(sdfAccCorr);
  A.AE(uu) = mean(sdfAccErr);
  A.FC(uu) = mean(sdfFastCorr);
  A.FET(uu) = mean(sdfFastErrT);
  A.FED(uu) = mean(sdfFastErrD);

end % for : unit (uu)

%Compute measure of error signal magnitude (contrast ratio)
%(given one neuron with error-suppressed activity, take absolute value)
magErrSignal.Acc  = abs((A.AE - A.AC) ./ (A.AE + A.AC)); %Accurate condition
magErrSignal.FastT = abs((A.FET - A.FC) ./ (A.FET + A.FC)); %Fast condition - Target
magErrSignal.FastD = abs((A.FED - A.FC) ./ (A.FED + A.FC)); %Fast condition - Distractor

%Compute mean and SD
muAcc  = mean(magErrSignal.Acc);   sdAcc  = std(magErrSignal.Acc);
muFastT = mean(magErrSignal.FastT); sdFastT = std(magErrSignal.FastT);
muFastD = mean(magErrSignal.FastD); sdFastD = std(magErrSignal.FastD);

%Plotting
figure(); hold on
bar(1,muAcc,  0.6,"grouped","red","EdgeColor","none")
bar(2,muFastT,0.6,"grouped","green","EdgeColor","none")
errorbar(1,muAcc,  sdAcc,  "vertical","Color",'k',"CapSize",0, 'LineWidth',1.4)
errorbar(2,muFastT,sdFastT,"vertical","Color",'k',"CapSize",0, 'LineWidth',1.4)
scatter(1+normrnd(0,.1,22,1),magErrSignal.Acc,20,'k',"filled", 'MarkerFaceAlpha',0.5)
scatter(2+normrnd(0,.1,22,1),magErrSignal.Fast,20,'k',"filled", 'MarkerFaceAlpha',0.5)
xticks([1 2]); xticklabels({'Acc','Fast'})
ppretty([1.4,2])

figure(); hold on
bar(1,muFastT,0.6,"grouped","FaceColor",[0 .8 0],"EdgeColor","none")
bar(2,muFastD,0.6,"grouped","FaceColor",[0 .3 0],"EdgeColor","none")
errorbar(1,muFastT,sdFastT,"vertical","Color",[0 .8 0],"CapSize",0, 'LineWidth',1.4)
errorbar(2,muFastD,sdFastD,"vertical","Color",[0 .3 0],"CapSize",0, 'LineWidth',1.4)
scatter(1+normrnd(0,.1,22,1),magErrSignal.FastT,20,'k',"filled", 'MarkerFaceAlpha',0.5)
scatter(2+normrnd(0,.1,22,1),magErrSignal.FastD,20,'k',"filled", 'MarkerFaceAlpha',0.5)
xticks([1 2]); xticklabels({'Tgt','Distr'})
ppretty([1.4,2])

clearvars -except behavData* unitData* pairData* ROOTDIR_SAT A magErrSignal
