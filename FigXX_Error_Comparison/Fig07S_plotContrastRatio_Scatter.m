function [ ] = Fig07S_plotContrastRatio_Scatter( unitInfo )
%Fig07S_plotContrastRatio_Scatter Summary of this function goes here
%   Detailed explanation goes here

DIR_SDF = 'C:\Users\Thomas Reppert\Dropbox\__SEF_SAT_\JPSTH_SAT\dataProcessed\dataset\satSdfs\';

idxSEF = ismember(unitInfo.area, {'SEF','NSEFN'});
idxDa = ismember(unitInfo.monkey, {'D'});
idxEu = ismember(unitInfo.monkey, {'E'});
idxErr = (unitInfo.errGrade >= 2);
idxRew = (abs(unitInfo.rewGrade) >= 2);
idxKeep = (idxSEF & (idxDa | idxEu) & (idxErr | idxRew));

unitInfo = unitInfo(idxKeep,:);
numNeuron = sum(idxKeep);

CR_Acc = NaN(1,numNeuron);
CR_Fast = NaN(1,numNeuron);

for nn = 1:numNeuron
  unitNum_cc = unitInfo.unitNum(nn);
  if (unitNum_cc < 10)
    strNum = ['00', num2str(unitNum_cc)];
  elseif (unitNum_cc < 100)
    strNum = ['0', num2str(unitNum_cc)];
  else
    strNum = num2str(unitNum_cc);
  end

  %collect SDFs for this neuron
  sdfData_cc = load([DIR_SDF, 'Unit_', strNum, '.mat']);
  sdf_AccCorr = sdfData_cc.sdfs.PostReward_sdfByTrial{1}(:,102:501); %400 ms
  sdf_AccErr = sdfData_cc.sdfs.PostReward_sdfByTrial{3}(:,102:501); %400 ms
  sdf_FastCorr = sdfData_cc.sdfs.PostSaccade_sdfByTrial{4}(:,202:501); %300 ms
  sdf_FastErr = sdfData_cc.sdfs.PostSaccade_sdfByTrial{5}(:,202:501); %300 ms

  %compute mean activation for each SDF
  A_AccCorr = mean(mean(sdf_AccCorr));  A_FastCorr = mean(mean(sdf_FastCorr));
  A_AccErr =  mean(mean(sdf_AccErr));   A_FastErr =  mean(mean(sdf_FastErr));

  %compute contrast ratios
  CR_Acc(nn) = (A_AccErr - A_AccCorr) / (A_AccErr + A_AccCorr);
  CR_Fast(nn) = (A_FastErr - A_FastCorr) / (A_FastErr + A_FastCorr);
end % for : neuron(nn)

%% Plotting
idxDa = ismember(unitInfo.monkey, {'D'});
idxEu = ismember(unitInfo.monkey, {'E'});
idxErr = (unitInfo.errGrade >= 2);
idxRew = (abs(unitInfo.rewGrade) >= 2);
idxErrOnly = (idxErr & ~idxRew);
idxRewOnly = (idxRew & ~idxErr);
idxBoth = (idxErr & idxRew);

idx_Da_Both = (idxDa & idxBoth);
idx_Eu_Both = (idxEu & idxBoth);
idx_Da_ErrOnly = (idxDa & idxErrOnly);
idx_Eu_ErrOnly = (idxEu & idxErrOnly);
idx_Da_RewOnly = (idxDa & idxRewOnly);
idx_Eu_RewOnly = (idxEu & idxRewOnly);

figure(); hold on
scatter(CR_Fast(idx_Da_Both), CR_Acc(idx_Da_Both), 40, [.4 .4 .4], 'o', 'filled')
scatter(CR_Fast(idx_Eu_Both), CR_Acc(idx_Eu_Both), 40, [.4 .4 .4], '^', 'filled')
scatter(CR_Fast(idx_Da_ErrOnly), CR_Acc(idx_Da_ErrOnly), 40, 'k', 'o', 'filled')
scatter(CR_Fast(idx_Eu_ErrOnly), CR_Acc(idx_Eu_ErrOnly), 40, 'k', '^', 'filled')
scatter(CR_Fast(idx_Da_RewOnly), CR_Acc(idx_Da_RewOnly), 40, 'k', 'o')
scatter(CR_Fast(idx_Eu_RewOnly), CR_Acc(idx_Eu_RewOnly), 40, 'k', '^')
ppretty([4.8,3]); ytickformat('%2.1f'); xtickformat('%2.1f')

end % fxn : Fig07S_plotContrastRatio_Scatter()

