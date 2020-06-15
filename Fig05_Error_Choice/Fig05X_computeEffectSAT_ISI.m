function [ ] = Fig05X_computeEffectSAT_ISI( bInfo , primarySacc , secondSacc , uInfo , uStats )
%Fig05X_computeEffectSAT_ISI 
%   Detailed explanation goes here
% 

MONKEY = {'D','E'};

idxMonkey = ismember(bInfo.monkey, MONKEY);
idxAreaRecorded = bInfo.recordedSEF;
idxKeep = (idxMonkey & idxAreaRecorded);

numSession = sum(idxKeep);
bInfo = bInfo(idxKeep,:);
primarySacc = primarySacc(idxKeep,:);
secondSacc = secondSacc(idxKeep,:);

%initialization - inter-saccade interval
isi_Acc = []; %concatenate all times across sessions
isi_Fast = [];
isi_Acc_mu = NaN(1,numSession); %compute mean for each session
isi_Fast_mu = NaN(1,numSession);
%initialization - time of second saccade re. primary saccade
t_sSacc_Acc = []; %for plotting
t_sSacc_Fast = [];


for kk = 1:numSession
  
  %compute inter-saccade interval
  ISI_kk = secondSacc.resptime{kk} - (primarySacc.resptime{kk} + primarySacc.duration{kk});
  %compute time of second saccade re. primary saccade
  t_sSacc_kk = secondSacc.resptime{kk} - primarySacc.resptime{kk};
  
  %index by condition
  idxAcc = (bInfo.condition{kk} == 1);
  idxFast = (bInfo.condition{kk} == 3);
  %index by trial outcome
  idxErr = (bInfo.err_dir{kk} & ~bInfo.err_time{kk});
  %index by second saccade endpoint
  idxTgt = (secondSacc.endpt{kk} == 1);
  idxDistr = (secondSacc.endpt{kk} == 2);
  
  %combine for easy indexing
  idxAcc = (idxAcc & idxErr & (idxTgt | idxDistr));
  idxFast = (idxFast & idxErr & (idxTgt | idxDistr));
  
  isi_Acc = cat(2, isi_Acc, ISI_kk(idxAcc));
  isi_Fast = cat(2, isi_Fast, ISI_kk(idxFast));
  t_sSacc_Acc = cat(2, t_sSacc_Acc, t_sSacc_kk(idxAcc));
  t_sSacc_Fast = cat(2, t_sSacc_Fast, t_sSacc_kk(idxFast));
  
  %save mean ISI
  isi_Acc_mu(kk) = median(ISI_kk(idxAcc));
  isi_Fast_mu(kk) = median(ISI_kk(idxFast));
  
end%for:cells(cc)

%get time of choice error signal for plotting
idxErrUnit = (ismember(uInfo.monkey, MONKEY) & (uInfo.errGrade >= 2));
tSignal_Acc = uStats.ChoiceErrorSignal_Time(idxErrUnit, 1);
tSignal_Fast = uStats.ChoiceErrorSignal_Time(idxErrUnit, 3);

%% Stats - t-test
ttestTom(isi_Acc_mu', isi_Fast_mu', 'paired')
ttestTom(tSignal_Acc', tSignal_Fast', 'paired')

%% Plotting - Distribution of timing
figure(); hold on

cdfplotTR(tSignal_Acc, 'Color','r')
cdfplotTR(tSignal_Fast, 'Color',[0 .7 0])
cdfplotTR(t_sSacc_Acc, 'Color','r')
cdfplotTR(t_sSacc_Fast, 'Color',[0 .7 0])

xlabel('Time from primary saccade (ms)');
ylabel('Cumulative probability'); ytickformat('%2.1f')
ppretty([4.8,3.0])

%% Plotting - Mean ISI
% figure(); hold on
% bar(1, mean(isi_Fast_mu), 'FaceColor',[0 .7 0])
% errorbar(1, mean(isi_Fast_mu), std(isi_Fast_mu)/sqrt(numSession), 'Color','k', 'CapSize',0)
% bar(2, mean(isi_Acc_mu), 'FaceColor','r')
% errorbar(2, mean(isi_Acc_mu), std(isi_Acc_mu)/sqrt(numSession), 'Color','k', 'CapSize',0)
% xlim([0 3]); ppretty([2,4])

end % fxn : Fig05X_computeEffectSAT_ISI ()

