function [ ] = Fig07C_plotRscSinglePair( spkCorr )

% %pre-filter to SEF neurons that contribute to SEF-SC pairs
% % uNumKeep = [5, 23, 36, 37, 38, 40, 41, 93, 100, 101, 102, 103, 100, 113, 114, 117, 118];
% % idxKeep = ismember(spkCorr.X_unitNum, uNumKeep);
% % spkCorr = spkCorr(idxKeep,:);

%PAIR_0263 - Da-20130828001-15b-U40(SEF)  and Da-20130828001-17a-U42(SC)
%PAIR_0507 - Eu-20130827001-13a-U106(SEF) and Eu-20130827001-17a-U111(SC)
%PAIR_0195 - Da-20130828001-14a-U37(SEF)  and Da-20130828001-10a-U31(FEF)
%PAIR_0251 - Da-20130828001-14a-U37(SEF)  and Da-20130828001-17a-U42(SC)

% pairID_List = unique(spkCorr.PairUid);
pairID_List = {'PAIR_0263','PAIR_0507','PAIR_0195','PAIR_0251'};
numPair = length(pairID_List);

%initialize lists of spike count correlation
rsc_FastCorr = NaN(1,numPair);    rsc_AccCorr = NaN(1,numPair);
rsc_FastCE =   NaN(1,numPair);    rsc_AccCE = NaN(1,numPair);
rsc_FastTE =   NaN(1,numPair);    rsc_AccTE = NaN(1,numPair);
pval_FastCE =  NaN(1,numPair);    pval_AccCE = NaN(1,numPair);
pval_FastTE =  NaN(1,numPair);    pval_AccTE = NaN(1,numPair);

for pp = 1:numPair
  
  pair_pp = pairID_List{pp};
  idx_pp = strcmp(spkCorr.PairUid, pair_pp);
  
  idxFastCorr = (idx_pp & strcmp(spkCorr.satOutcome, 'FastCorrect'));
  idxAccCorr = (idx_pp & strcmp(spkCorr.satOutcome, 'AccurateCorrect'));
  idxFastCE = (idx_pp & strcmp(spkCorr.satOutcome, 'FastErrorChoice'));
  idxAccCE = (idx_pp & strcmp(spkCorr.satOutcome, 'AccurateErrorChoice'));
  idxFastTE = (idx_pp & strcmp(spkCorr.satOutcome, 'FastErrorTiming'));
  idxAccTE = (idx_pp & strcmp(spkCorr.satOutcome, 'AccurateErrorTiming'));
  
  rsc_FastCorr(pp) = spkCorr.rscObserved(idxFastCorr);
  rsc_AccCorr(pp) = spkCorr.rscObserved(idxAccCorr);
  rsc_FastCE(pp) = spkCorr.rscObserved(idxFastCE);
  rsc_AccCE(pp) = spkCorr.rscObserved(idxAccCE);
  rsc_FastTE(pp) = spkCorr.rscObserved(idxFastTE);
  rsc_AccTE(pp) = spkCorr.rscObserved(idxAccTE);
  
  pval_FastCE(pp) = spkCorr.pvalObserved(idxFastCE);
  pval_AccCE(pp) = spkCorr.pvalObserved(idxAccCE);
  pval_FastTE(pp) = spkCorr.pvalObserved(idxFastTE);
  pval_AccTE(pp) = spkCorr.pvalObserved(idxAccTE);
  
end % for : pair(pp)


%% Plotting - Scatterplot of space of Rsc for each condition
if (false)
figure()

subplot(2,2,1); hold on
scatter(rsc_FastCorr, rsc_FastCE, 20, [0 .7 0])
xlabel('rSC - Correct')
ylabel('rSC - Choice error')

subplot(2,2,2); hold on
scatter(rsc_FastCorr, rsc_FastTE, 20, [0 .7 0])
xlabel('rSC - Correct')
ylabel('rSC - Timing error')

subplot(2,2,3); hold on
scatter(rsc_AccCorr, rsc_AccCE, 20, 'r')
xlabel('rSC - Correct')
ylabel('rSC - Choice error')

subplot(2,2,4); hold on
scatter(rsc_AccCorr, rsc_AccTE, 20, 'r')
xlabel('rSC - Correct')
ylabel('rSC - Timing error')

ppretty([6.4,5])
return
end
%% Find pairs of interest
CONDITION = 'Fast'; %{'Fast','Acc'}
limRsc_Corr = [-0.2 0.2];
lim_pval = 0.06;

if strcmp(CONDITION, 'Fast')
  limRsc_Err = [0.2 0.7];
  rsc_Corr = rsc_FastCorr;
  pval_Err = pval_FastCE;
  rsc_Err  = rsc_FastCE; %NOTE: Change the next line in tandem with this one
  idx_PAIR = [15, 19]; %[15,19,23] NOTE: Change second index re. error type
  colorPlot = [0 .7 0];
elseif strcmp(CONDITION, 'Acc')
  limRsc_Err = [0.2 0.7];
  rsc_Corr = rsc_AccCorr;
  pval_Err = pval_AccCE;
  rsc_Err  = rsc_AccCE; %NOTE: Change the next line in tandem with this one
  idx_PAIR = [3, 7]; %[3,7,11] NOTE: Change second index re. error type
  colorPlot = 'r';
end

%identify all pairs that meet our criteria
idxKeep = ( ((rsc_Corr > limRsc_Corr(1)) & (rsc_Corr < limRsc_Corr(2))) & ...
  (((rsc_Err > +limRsc_Err(1)) & (rsc_Err < +limRsc_Err(2))) | ...
   ((rsc_Err < -limRsc_Err(1)) & (rsc_Err > -limRsc_Err(2)))) & ...
    (pval_Err < lim_pval) );
pairKeep = pairID_List(idxKeep);
numKeep = sum(idxKeep);

fprintf('Found %d pairs for the %s condition\n', sum(idxKeep), CONDITION)

spkCorr = spkCorr(ismember(spkCorr.PairUid, pairKeep),:);
spkCorr = sortrows(spkCorr,{'PairUid'});
area2 = spkCorr.unitArea2(1:6:end); %FEF/SC

%% Plotting
fileHeader = 'C:\Users\Tom\Dropbox\__SEF_SAT_\JPSTH_SAT\satSefPaper\analysis\spkCorr\spkCorr_SEF-';
dirPrint = 'C:\Users\Tom\Dropbox\ZZ\';

for pp = 1 : numKeep
%   if ~strcmp(area2{pp}, 'FEF'); continue; end
  scPAIR = load([fileHeader, area2{pp}, '\mat\spkCorr_', pairKeep{pp}, '.mat']);
  sc_X_Corr = scPAIR.spkCorr.xSpkCount_win_150ms{idx_PAIR(1)};
  sc_X_Err = scPAIR.spkCorr.xSpkCount_win_150ms{idx_PAIR(2)};
  sc_Y_Corr = scPAIR.spkCorr.ySpkCount_win_150ms{idx_PAIR(1)};
  sc_Y_Err = scPAIR.spkCorr.ySpkCount_win_150ms{idx_PAIR(2)};
  stats_Corr = scPAIR.spkCorr.rho_pval_static_150ms{idx_PAIR(1)}; %[rho, pval]
  stats_Err = scPAIR.spkCorr.rho_pval_static_150ms{idx_PAIR(2)};
  
  figure()
  subplot(1,2,1); hold on; title(['Correct  R=', num2str(stats_Corr(1)), '  p=', num2str(stats_Corr(2))])
  scatter(sc_X_Corr, sc_Y_Corr, 30, colorPlot, 'filled', 'MarkerFaceAlpha',.3)
  xlabel([scPAIR.cellPairInfo.X_sess{1}, '-', scPAIR.cellPairInfo.X_unit{1}, '-', scPAIR.cellPairInfo.X_area{1}])
  ylabel([scPAIR.cellPairInfo.Y_sess{1}, '-', scPAIR.cellPairInfo.Y_unit{1}, '-', scPAIR.cellPairInfo.Y_area{1}])
  subplot(1,2,2); hold on; title(['Error  R=', num2str(stats_Err(1)), '  p=', num2str(stats_Err(2))])
  scatter(sc_X_Err, sc_Y_Err, 30, colorPlot, 'filled', 'MarkerFaceAlpha',.3)
  ppretty([7,2.4])
  
  pause(.1); print([dirPrint, CONDITION, '_', pairKeep{pp}, '.tif'], '-dtiff'); pause(.1)
end % for : pair (pp) from pairKeepFast

end % fxn : Fig07C_plotRscSinglePair()

%% Extra - Find SEF neurons that contribute to both FEF *and* SC pairs
% %need SEF unit numbers contributing to each pair for this analysis
% idxSignif = (spkCorr.signif05 == 1);
% idxSEF_FEF = (idxSignif & strcmp(spkCorr.unitArea2, 'FEF'));
% idxSEF_SC = (idxSignif & strcmp(spkCorr.unitArea2, 'SC'));
% idxSEF_Split = intersect(

