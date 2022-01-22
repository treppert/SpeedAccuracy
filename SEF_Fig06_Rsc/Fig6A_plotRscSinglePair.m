function [ ] = Fig6A_plotRscSinglePair( spkCorr )

%PAIR_0195 - Da-20130828001-14a-U37(SEF)  and Da-20130828001-10a-U31(FEF)
%PAIR_0251 - Da-20130828001-14a-U37(SEF)  and Da-20130828001-17a-U42(SC)
%PAIR_0263 - Da-20130828001-15b-U40(SEF)  and Da-20130828001-17a-U42(SC)
%PAIR_0507 - Eu-20130827001-13a-U106(SEF) and Eu-20130827001-17a-U111(SC)

pairID_List = {'PAIR_0195','PAIR_0251','PAIR_0263','PAIR_0507'};
numPair = length(pairID_List);

spkCorr = spkCorr(ismember(spkCorr.PairUid, pairID_List), :);
% spkCorr = sortrows(spkCorr,{'PairUid'});

%initialize lists of spike count correlation
rsc_FastCorr = NaN(1,numPair);    rsc_AccCorr = NaN(1,numPair);
rsc_FastCE =   NaN(1,numPair);    rsc_AccTE = NaN(1,numPair);
pval_FastCE =  NaN(1,numPair);    pval_AccTE = NaN(1,numPair);

for pp = 1:numPair
  
  pair_pp = pairID_List{pp};
  idx_pp = strcmp(spkCorr.PairUid, pair_pp);
  
  idxFastCorr = (idx_pp & strcmp(spkCorr.satOutcome, 'FastCorrect'));
  idxAccCorr = (idx_pp & strcmp(spkCorr.satOutcome, 'AccurateCorrect'));
  idxFastCE = (idx_pp & strcmp(spkCorr.satOutcome, 'FastErrorChoice'));
  idxAccTE = (idx_pp & strcmp(spkCorr.satOutcome, 'AccurateErrorTiming'));
  
  rsc_FastCorr(pp) = spkCorr.rscObserved(idxFastCorr);
  rsc_AccCorr(pp) = spkCorr.rscObserved(idxAccCorr);
  rsc_FastCE(pp) = spkCorr.rscObserved(idxFastCE);
  rsc_AccTE(pp) = spkCorr.rscObserved(idxAccTE);
  
  pval_FastCE(pp) = spkCorr.pvalObserved(idxFastCE);
  pval_AccTE(pp) = spkCorr.pvalObserved(idxAccTE);
  
end % for : pair(pp)

CONDITION = 'Fast'; 
if strcmp(CONDITION, 'Fast') %pairs (pp) #1-3
  idx_PAIR = [15, 19];
  colorPlot = [0 .7 0];
elseif strcmp(CONDITION, 'Acc') %just pair (pp) #4
  idx_PAIR = [3, 11];
  colorPlot = 'r';
end


%% Plotting
pairFileHeader = 'C:\Users\Tom\Dropbox\__SEF_SAT_\JPSTH_SAT\satSefPaper\analysis\spkCorr\spkCorr_SEF-';
area2 = spkCorr.unitArea2(1:6:end); %FEF/SC

ptsPlot = linspace(-5, +5, 50); %points for plotting

%create Gaussian filter matrix
[xG, yG] = meshgrid(-5:+5); %grid for Gaussian filter
sigma = 2.0; %width of filter
g = exp(-xG.^2./(2.*sigma.^2)-yG.^2./(2.*sigma.^2));
g = g./sum(g(:));

%pre-set axis limits for each pair
xLim = {[-2.5,+2.5], [-2.5,+2.5], [-3.0, +3.0], [-2.5, +2.5]};
yLim = {[-2.0,+3.0], [-2.5,+2.5], [-2.5, +2.5], [-2.0, +3.0]};

for pp = 1:1
  
  scPAIR = load([pairFileHeader, area2{pp}, '\mat\spkCorr_', pairID_List{pp}, '.mat']);
  
  %gather pair-specific data
  sc_X_Corr = scPAIR.spkCorr.xSpkCount_win_150ms{idx_PAIR(1)}; n_X = length(sc_X_Corr);
  sc_X_Err = scPAIR.spkCorr.xSpkCount_win_150ms{idx_PAIR(2)};
  sc_Y_Corr = scPAIR.spkCorr.ySpkCount_win_150ms{idx_PAIR(1)}; n_Y = length(sc_Y_Corr);
  sc_Y_Err = scPAIR.spkCorr.ySpkCount_win_150ms{idx_PAIR(2)};
  stats_Corr = scPAIR.spkCorr.rho_pval_static_150ms{idx_PAIR(1)}; %[rho, pval]
  stats_Err = scPAIR.spkCorr.rho_pval_static_150ms{idx_PAIR(2)};
  
  %z-score spike counts
  sc_X_z = zscore([sc_X_Corr ; sc_X_Err]);
  sc_X_Corr = sc_X_z(1:n_X);
  sc_X_Err = sc_X_z(n_X+1:end);
  sc_Y_z = zscore([sc_Y_Corr ; sc_Y_Err]);
  sc_Y_Corr = sc_Y_z(1:n_X);
  sc_Y_Err = sc_Y_z(n_X+1:end);
  
  %bin spike counts
  scPlot_Corr = histcounts2(sc_Y_Corr, sc_X_Corr, ptsPlot, ptsPlot);
  scPlot_Err =  histcounts2(sc_Y_Err,  sc_X_Err,  ptsPlot, ptsPlot);
  
  %compute line of best fit for significant correlations (Error)
  fitLine = fit(sc_X_Err, sc_Y_Err, 'poly1');
  
  figure()
  
  %scatterplot
  subplot(2,2,1); hold on; title(['Correct  R=', num2str(stats_Corr(1)), '  p=', num2str(stats_Corr(2))])
  scatter(sc_X_Corr, sc_Y_Corr, 30, colorPlot, 'filled', 'MarkerFaceAlpha',.3)
  subplot(2,2,2); hold on; title(['Error  R=', num2str(stats_Err(1)), '  p=', num2str(stats_Err(2))])
  scatter(sc_X_Err, sc_Y_Err, 30, colorPlot, 'filled', 'MarkerFaceAlpha',.3)
  plot(xLim{pp}, fitLine(xLim{pp}), 'k:', 'LineWidth',1.25)

  %density plot
  subplot(2,2,3); hold on; title(['Correct  R=', num2str(stats_Corr(1)), '  p=', num2str(stats_Corr(2))])
  imagesc(ptsPlot, ptsPlot, conv2(scPlot_Corr, g, 'same'));
  xlabel([scPAIR.cellPairInfo.X_sess{1}, '-', scPAIR.cellPairInfo.X_unit{1}, '-', scPAIR.cellPairInfo.X_area{1}])
  ylabel([scPAIR.cellPairInfo.Y_sess{1}, '-', scPAIR.cellPairInfo.Y_unit{1}, '-', scPAIR.cellPairInfo.Y_area{1}])
  subplot(2,2,4); hold on; title(['Error  R=', num2str(stats_Err(1)), '  p=', num2str(stats_Err(2))])
  imagesc(ptsPlot, ptsPlot, conv2(scPlot_Err, g, 'same'));
  plot(xLim{pp}, fitLine(xLim{pp}), 'k:', 'LineWidth',1.25)
  
  %set axis limits
  for sp = 1:4
    subplot(2,2,sp); set(gca, 'xlim',xLim{pp}, 'ylim',yLim{pp});
  end
  
  ppretty([7.2,6.2]); pause(.25)
  
end % for : pair (pp)

end % fxn : Fig6A_plotRscSinglePair()

