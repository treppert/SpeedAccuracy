function [ ] = plot_nTrials_X_Condition( binfoSAT )
%plot_nTrials_X_Condition Summary of this function goes here
%   Detailed explanation goes here

idxMonkey = ismember(binfoSAT.monkey, {'D','E'});
idxSEF = (binfoSAT.recordedSEF);

binfoSAT = binfoSAT(idxMonkey & idxSEF, :);
numSess = sum(idxMonkey & idxSEF);

nTrial_AccCorr = NaN(1,numSess);      nTrial_FastCorr = NaN(1,numSess);
nTrial_AccErrChc = NaN(1,numSess);    nTrial_FastErrChc = NaN(1,numSess);
nTrial_AccErrTime = NaN(1,numSess);   nTrial_FastErrTime = NaN(1,numSess);

for kk = 1:numSess
  
  idxAcc = (binfoSAT.condition{kk} == 1);
  idxFast = (binfoSAT.condition{kk} == 3);
  
  idxCorr = ~(binfoSAT.err_dir{kk} | binfoSAT.err_time{kk} | binfoSAT.err_hold{kk} | binfoSAT.err_nosacc{kk});
  idxErrChc = (binfoSAT.err_dir{kk} & ~binfoSAT.err_time{kk});
  idxErrTime = (binfoSAT.err_time{kk} & ~binfoSAT.err_dir{kk});
  
  idxClearFast = binfoSAT.clearDisplayFast{kk};
  
  nTrial_AccCorr(kk) = sum(idxAcc & idxCorr);
  nTrial_AccErrChc(kk) = sum(idxAcc & idxErrChc);
  nTrial_AccErrTime(kk) = sum(idxAcc & idxErrTime);
  nTrial_FastCorr(kk) = sum(idxFast & idxCorr);
  nTrial_FastErrChc(kk) = sum(idxFast & idxErrChc);
  nTrial_FastErrTime(kk) = sum(idxFast & idxErrTime & ~idxClearFast);
  
end% for : session(kk)

figure()
BIN_WIDTH = 5;
BIN_LIMIT = [0, 700];

subplot(2,3,1)
histogram(nTrial_AccCorr, 'FaceColor','r', 'BinWidth',BIN_WIDTH)
subplot(2,3,2)
histogram(nTrial_AccErrChc, 'FaceColor','r', 'BinWidth',BIN_WIDTH)
subplot(2,3,3)
histogram(nTrial_AccErrTime, 'FaceColor','r', 'BinWidth',BIN_WIDTH)
subplot(2,3,4)
histogram(nTrial_FastCorr, 'FaceColor',[0 .7 0], 'BinWidth',BIN_WIDTH)
subplot(2,3,5)
histogram(nTrial_FastErrChc, 'FaceColor',[0 .7 0], 'BinWidth',BIN_WIDTH)
subplot(2,3,6)
histogram(nTrial_FastErrTime, 'FaceColor',[0 .7 0], 'BinWidth',BIN_WIDTH)

ppretty([6.4,4], 'YMinorTick','off')

end% fxn : plot_nTrials_X_Condition()

