%plotHistogram_PostPrimarySaccade_SAT.m
% load('C:\Users\Thomas Reppert\Dropbox\SAT\dataBehavior_SAT_DaEu_Check.mat')

numSession = 14;

numSacc = [];

idxSacc_Acc = [];
idxSacc_Fast = [];

for kk = 1:numSession
  
  %get index of saccade to Target
  idxSacc2Tgt = allSaccades_DaEu.saccIndexOnTarget{kk};
  %label trials with no saccade to Target
  idxSacc2Tgt(isnan(idxSacc2Tgt)) = 10;
  
  %index by trial outcome
  idx_Corr = ~(binfoSAT_DaEu.err_dir{kk} | binfoSAT_DaEu.err_time{kk} | binfoSAT_DaEu.err_hold{kk} | binfoSAT_DaEu.err_nosacc{kk});
  idx_ErrChoice = (binfoSAT_DaEu.err_dir{kk});
  
  %index by task condition
  idx_Acc = ((binfoSAT_DaEu.condition{kk} == 1) & idx_ErrChoice);
  idx_Fast = ((binfoSAT_DaEu.condition{kk} == 3) & idx_ErrChoice);
  
  %get number of saccades
  numSacc = cat(1, numSacc, allSaccades_DaEu.nSaccades{kk}(idx_ErrChoice));
  %get index of saccade to Target
  idxSacc_Acc = cat(1, idxSacc_Acc, idxSacc2Tgt(idx_Acc));
  idxSacc_Fast = cat(1, idxSacc_Fast, idxSacc2Tgt(idx_Fast));
  
end

Normalization = 'count';
figure(); hold on
histogram(idxSacc_Fast, 'FaceColor',[0 .7 0], 'Normalization',Normalization, 'BinEdges',(0:.25:10))
histogram(idxSacc_Acc, 'FaceColor','r', 'Normalization',Normalization, 'BinEdges',(0:.25:10))
ppretty([3.2,2])

clear vars -except *_DaEu
