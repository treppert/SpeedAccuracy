function [ ] = plot_SpkCorr_SAT( nPairSummary , nPairDB , binfo , ninfo , spikes )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

DIR_PRINT = 'C:\Users\TDT\Dropbox\SAT\Figures\Spike-Correlation-SEF-FEF\';
SecondArea = 'FEF';

% KK_Da = [2, 3, 4, 5, 8, 9];   KK_Eu = [11, 12, 13]; %SC & SEF
KK_Da = [2, 3, 4, 5, 6, 8, 9];   KK_Eu = []; %FEF & SEF

KK_All = [ KK_Da , KK_Eu ];
nPairSummary = nPairSummary(KK_All,:);
N_SESS = size(nPairSummary, 1);

% T_BASE = 3500 + [-600 20]; %baseline (re. stimulus)
T_BASE = 3500 + [-350 20];
T_VIS  = 3500 +  [75 200]; %visual response (re. stimulus)
% T_ERR  = 3500 + [100 300]; %error-related (re. saccade)
T_ERR  = 3500 + [50 350];

%function for curve fitting
f_Fit = @(x,xdata) x(1) + x(2)*xdata + x(3)*xdata.^2 + x(4)*xdata.^3;
p0 = [5 0 0 0]; %fit parameter initialization
opt_ = optimset('Display','off'); %turn off messages from lsqcurvefit

%% Isolate all pairs of SEF & SC neurons
iiPairKeep = [];

for kk = 1:N_SESS
  
  firstPairKK = nPairSummary.firstPairUID(kk);
  lastPairKK  = nPairSummary.lastPairUID(kk);
  
  idxFirstPair = find(ismember(nPairDB.Pair_UID, firstPairKK));
  idxLastPair  = find(ismember(nPairDB.Pair_UID, lastPairKK));
  
  for ii = idxFirstPair:idxLastPair
    
    %determine if we have a SEF-SC pair
    X_area = nPairDB.X_area{ii};
    Y_area = nPairDB.Y_area{ii};
    
    if ((strcmp(X_area,'SEF') && strcmp(Y_area,SecondArea)) || (strcmp(X_area,SecondArea) && strcmp(Y_area,'SEF')))
      iiPairKeep = cat(2, iiPairKeep, ii);
    end
    
  end%for:cellPair(ii)
  
end%for:session(kk)

nPairDB = nPairDB(iiPairKeep,:);

%% Compute spike counts for intervals of interest
CELL = {'X','Y'};
N_PAIR = size(nPairDB, 1);

logPVal_Acc_Base = NaN(1,N_PAIR); logPVal_Fast_Base = NaN(1,N_PAIR);
logPVal_Acc_Vis  = NaN(1,N_PAIR); logPVal_Fast_Vis  = NaN(1,N_PAIR);
logPVal_Acc_Err  = NaN(1,N_PAIR); logPVal_Fast_Err  = NaN(1,N_PAIR);

Pair_UID = cell(N_PAIR,1);
X_Type = cell(N_PAIR,1);
Y_Type = cell(N_PAIR,1);
X_Area = cell(N_PAIR,1);
Y_Area = cell(N_PAIR,1);

for ii = 1:N_PAIR
  
  X_unitNum = nPairDB.X_unitNum(ii);
  Y_unitNum = nPairDB.Y_unitNum(ii);
  
  X_spikes = spikes(X_unitNum).SAT;
  Y_spikes = spikes(Y_unitNum).SAT;
  
  %save information on neuron type
  if (nPairDB.X_visGrade(ii) >= 2)
    X_Type{ii} = cat(2, X_Type{ii}, 'Vis');
  end
  if (nPairDB.X_moveGrade(ii) >= 2)
    X_Type{ii} = cat(2, X_Type{ii}, 'Move');
  end
  if (nPairDB.X_errGrade(ii) >= 2)
    X_Type{ii} = cat(2, X_Type{ii}, 'Err');
  end
  if (nPairDB.Y_visGrade(ii) >= 2)
    Y_Type{ii} = cat(2, Y_Type{ii}, 'Vis');
  end
  if (nPairDB.Y_moveGrade(ii) >= 2)
    Y_Type{ii} = cat(2, Y_Type{ii}, 'Move');
  end
  if (nPairDB.Y_errGrade(ii) >= 2)
    Y_Type{ii} = cat(2, Y_Type{ii}, 'Err');
  end
  
  %save pair UID and neuron area
  Pair_UID{ii} = nPairDB.Pair_UID{ii};
  X_Area{ii} = nPairDB.X_area{ii};
  Y_Area{ii} = nPairDB.Y_area{ii};
  
  kk = ismember({binfo.session}, nPairDB.X_sess(ii));
  
  %index by isolation quality
  X_idxIso = identify_trials_poor_isolation_SAT(ninfo(X_unitNum), binfo(kk).num_trials);
  Y_idxIso = identify_trials_poor_isolation_SAT(ninfo(Y_unitNum), binfo(kk).num_trials);
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial oucome
%   idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
%   idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  trialAcc = find(idxAcc & ~(X_idxIso | Y_idxIso));
  trialFast = find(idxFast & ~(X_idxIso | Y_idxIso));
%   trialAcc = find(idxAcc & idxErr & ~(X_idxIso | Y_idxIso));
%   trialFast = find(idxFast & idxErr & ~(X_idxIso | Y_idxIso));
  
  sp_Acc.X = X_spikes(trialAcc);    sp_Fast.X = X_spikes(trialFast);
  sp_Acc.Y = Y_spikes(trialAcc);    sp_Fast.Y = Y_spikes(trialFast);
  
  %compute spike counts for Baseline Period and Visual Response Period
  %****************************************
  for cc = 1:2
    sp_Acc_Base.(CELL{cc})  = cellfun(@(x) sum((x > T_BASE(1)) & (x < T_BASE(2))), sp_Acc.(CELL{cc}));
    sp_Fast_Base.(CELL{cc}) = cellfun(@(x) sum((x > T_BASE(1)) & (x < T_BASE(2))), sp_Fast.(CELL{cc}));
    sp_Acc_Vis.(CELL{cc})  = cellfun(@(x) sum((x > T_VIS(1)) & (x < T_VIS(2))), sp_Acc.(CELL{cc}));
    sp_Fast_Vis.(CELL{cc}) = cellfun(@(x) sum((x > T_VIS(1)) & (x < T_VIS(2))), sp_Fast.(CELL{cc}));
  end
  %****************************************
  
  %compute spike counts for Error Period
  %****************************************
  RT_Acc  = binfo(kk).resptime(trialAcc);   numAcc = length(trialAcc);
  RT_Fast = binfo(kk).resptime(trialFast);  numFast = length(trialFast);
  
  X_Acc_sp_Err = NaN(1,numAcc);   Y_Acc_sp_Err = NaN(1,numAcc);
  X_Fast_sp_Err = NaN(1,numFast);   Y_Fast_sp_Err = NaN(1,numFast);
  
  for jj = 1:numAcc %Accurate condition
    t_Err_jj = RT_Acc(jj) + T_ERR;
    for cc = 1:2
      sp_Acc_Err.(CELL{cc})(jj)  = cellfun(@(x) sum((x > T_BASE(1)) & (x < T_BASE(2))), sp_Acc.(CELL{cc}));
    end
    X_Acc_sp_Err(jj) = sum((X_Acc_spikes{jj} > t_Err_jj(1)) & (X_Acc_spikes{jj} < t_Err_jj(2)));
    Y_Acc_sp_Err(jj) = sum((Y_Acc_spikes{jj} > t_Err_jj(1)) & (Y_Acc_spikes{jj} < t_Err_jj(2)));
  end
  for jj = 1:numFast %Fast condition
    t_Err_jj = RT_Fast(jj) + T_ERR;
    X_Fast_sp_Err(jj) = sum((X_Fast_spikes{jj} > t_Err_jj(1)) & (X_Fast_spikes{jj} < t_Err_jj(2)));
    Y_Fast_sp_Err(jj) = sum((Y_Fast_spikes{jj} > t_Err_jj(1)) & (Y_Fast_spikes{jj} < t_Err_jj(2)));
  end
  %****************************************
  
  %FIT THE SPIKE COUNT VS. TRIAL NUMBER DATA
  sp_Base = struct('X',[], 'Y',[]);
  
  
  %combine data across conditions
  trialAll = [trialAcc trialFast];
  X_sp_Base = [X_Acc_sp_Base X_Fast_sp_Base];   Y_sp_Base = [Y_Acc_sp_Base Y_Fast_sp_Base];
  X_sp_Vis = [X_Acc_sp_Vis X_Fast_sp_Vis];      Y_sp_Vis = [Y_Acc_sp_Vis Y_Fast_sp_Vis];
  X_sp_Err = [X_Acc_sp_Err X_Fast_sp_Err];      Y_sp_Err = [Y_Acc_sp_Err Y_Fast_sp_Err];
  
  p_X_Base = lsqcurvefit(f_Fit, p0, trialAll, X_sp_Base, [], [], opt_);
  p_Y_Base = lsqcurvefit(f_Fit, p0, trialAll, Y_sp_Base, [], [], opt_);
  p_X_Vis = lsqcurvefit(f_Fit, p0, trialAll, X_sp_Vis, [], [], opt_);
  p_Y_Vis = lsqcurvefit(f_Fit, p0, trialAll, Y_sp_Vis, [], [], opt_);
  p_X_Err = lsqcurvefit(f_Fit, p0, trialAll, X_sp_Err, [], [], opt_);
  p_Y_Err = lsqcurvefit(f_Fit, p0, trialAll, Y_sp_Err, [], [], opt_);
  
  %COMPUTE FIT RESIDUALS
  X_Acc_sp_Base_Res = X_Acc_sp_Base - f_Fit(p_X_Base,trialAcc);
  Y_Acc_sp_Base_Res = Y_Acc_sp_Base - f_Fit(p_Y_Base,trialAcc);
  X_Acc_sp_Vis_Res = X_Acc_sp_Vis - f_Fit(p_X_Vis,trialAcc);
  Y_Acc_sp_Vis_Res = Y_Acc_sp_Vis - f_Fit(p_Y_Vis,trialAcc);
  X_Acc_sp_Err_Res = X_Acc_sp_Err - f_Fit(p_X_Err,trialAcc);
  Y_Acc_sp_Err_Res = Y_Acc_sp_Err - f_Fit(p_Y_Err,trialAcc);
  X_Fast_sp_Base_Res = X_Fast_sp_Base - f_Fit(p_X_Base,trialFast);
  Y_Fast_sp_Base_Res = Y_Fast_sp_Base - f_Fit(p_Y_Base,trialFast);
  X_Fast_sp_Vis_Res = X_Fast_sp_Vis - f_Fit(p_X_Vis,trialFast);
  Y_Fast_sp_Vis_Res = Y_Fast_sp_Vis - f_Fit(p_Y_Vis,trialFast);
  X_Fast_sp_Err_Res = X_Fast_sp_Err - f_Fit(p_X_Err,trialFast);
  Y_Fast_sp_Err_Res = Y_Fast_sp_Err - f_Fit(p_Y_Err,trialFast);
  
  
  %COMPUTE SPEARMAN RANK CORRELATION COEFFICIENT AND P-VALUE
%   [rho_Acc_Base, pval_Acc_Base] = corr(X_Acc_sp_Base', Y_Acc_sp_Base', 'Type','Spearman');
%   [rho_Acc_Vis,  pval_Acc_Vis]  = corr(X_Acc_sp_Vis',  Y_Acc_sp_Vis', 'Type','Spearman');
%   [rho_Acc_Err,  pval_Acc_Err]  = corr(X_Acc_sp_Err',  Y_Acc_sp_Err', 'Type','Spearman');
%   [rho_Fast_Base, pval_Fast_Base] = corr(X_Fast_sp_Base', Y_Fast_sp_Base', 'Type','Spearman');
%   [rho_Fast_Vis,  pval_Fast_Vis]  = corr(X_Fast_sp_Vis',  Y_Fast_sp_Vis', 'Type','Spearman');
%   [rho_Fast_Err,  pval_Fast_Err]  = corr(X_Fast_sp_Err',  Y_Fast_sp_Err', 'Type','Spearman');
  [rho_Acc_Base, pval_Acc_Base] = corr(X_Acc_sp_Base_Res', Y_Acc_sp_Base_Res', 'Type','Spearman');
  [rho_Acc_Vis,  pval_Acc_Vis]  = corr(X_Acc_sp_Vis_Res',  Y_Acc_sp_Vis_Res', 'Type','Spearman');
  [rho_Acc_Err,  pval_Acc_Err]  = corr(X_Acc_sp_Err_Res',  Y_Acc_sp_Err_Res', 'Type','Spearman');
  [rho_Fast_Base, pval_Fast_Base] = corr(X_Fast_sp_Base_Res', Y_Fast_sp_Base_Res', 'Type','Spearman');
  [rho_Fast_Vis,  pval_Fast_Vis]  = corr(X_Fast_sp_Vis_Res',  Y_Fast_sp_Vis_Res', 'Type','Spearman');
  [rho_Fast_Err,  pval_Fast_Err]  = corr(X_Fast_sp_Err_Res',  Y_Fast_sp_Err_Res', 'Type','Spearman');
  
  %save (signed) rank correlation p-value
  logPVal_Acc_Base(ii) = sign(rho_Acc_Base) * -log(pval_Acc_Base);
  logPVal_Acc_Vis(ii)  = sign(rho_Acc_Vis)  * -log(pval_Acc_Vis);
  logPVal_Acc_Err(ii)  = sign(rho_Acc_Err)  * -log(pval_Acc_Err);
  logPVal_Fast_Base(ii) = sign(rho_Fast_Base) * -log(pval_Fast_Base);
  logPVal_Fast_Vis(ii)  = sign(rho_Fast_Vis)  * -log(pval_Fast_Vis);
  logPVal_Fast_Err(ii)  = sign(rho_Fast_Err)  * -log(pval_Fast_Err);
  
  
  
  %PLOT CORRELATION
%   figure()
%   %*********************************
%   %Correlations - Accurate condition
%   subplot(2,3,1); hold on %Baseline
%   title(['Baseline: R_{Sp} = ', num2str(rho_Acc_Base), '  p_{Sp} = ', num2str(pval_Acc_Base)], 'FontSize',9)
%   scatter(X_Acc_sp_Base_Res, Y_Acc_sp_Base_Res, 25, 'r', 'filled', 'MarkerFaceAlpha',0.1)
%   ylabel([nPairDB.X_sess{ii},'-',nPairDB.Y_unit{ii}, ' (',nPairDB.Y_area{ii},')', ' (sp/s)'])
%   
%   subplot(2,3,2); hold on %Visual Response
%   title(['Vis. response: R_{Sp} = ', num2str(rho_Acc_Vis), '  p_{Sp} = ', num2str(pval_Acc_Vis)], 'FontSize',9)
%   scatter(X_Acc_sp_Vis_Res, Y_Acc_sp_Vis_Res, 25, 'r', 'filled', 'MarkerFaceAlpha',0.1)
%   
%   subplot(2,3,3); hold on %Error Period
%   title(['Post-response: R_{Sp} = ', num2str(rho_Acc_Err), '  p_{Sp} = ', num2str(pval_Acc_Err)], 'FontSize',9)
%   scatter(X_Acc_sp_Err_Res, Y_Acc_sp_Err_Res, 25, 'r', 'filled', 'MarkerFaceAlpha',0.1)
%   %*********************************
%   
%   %*********************************
%   %Correlations - Fast condition
%   subplot(2,3,4); hold on %Baseline
%   title(['Baseline: R_{Sp} = ', num2str(rho_Fast_Base), '  p_{Sp} = ', num2str(pval_Fast_Base)], 'FontSize',9)
%   scatter(X_Fast_sp_Base_Res, Y_Fast_sp_Base_Res, 25, [0 .7 0], 'filled', 'MarkerFaceAlpha',0.1)
%   xlabel([nPairDB.X_sess{ii},'-',nPairDB.X_unit{ii}, ' (',nPairDB.X_area{ii},')', ' (sp/s)'])
%   ylabel([nPairDB.X_sess{ii},'-',nPairDB.Y_unit{ii}, ' (',nPairDB.Y_area{ii},')', ' (sp/s)'])
%   
%   subplot(2,3,5); hold on %Visual Response
%   title(['Vis. response: R_{Sp} = ', num2str(rho_Fast_Vis), '  p_{Sp} = ', num2str(pval_Fast_Vis)], 'FontSize',9)
%   scatter(X_Fast_sp_Vis_Res, Y_Fast_sp_Vis_Res, 25, [0 .7 0], 'filled', 'MarkerFaceAlpha',0.1)
%   xlabel([nPairDB.X_sess{ii},'-',nPairDB.X_unit{ii}, ' (',nPairDB.X_area{ii},')', ' (sp/s)'])
%   
%   subplot(2,3,6); hold on %Error Period
%   title(['Post-response: R_{Sp} = ', num2str(rho_Fast_Err), '  p_{Sp} = ', num2str(pval_Fast_Err)], 'FontSize',9)
%   scatter(X_Fast_sp_Err_Res, Y_Fast_sp_Err_Res, 25, [0 .7 0], 'filled', 'MarkerFaceAlpha',0.1)
%   xlabel([nPairDB.X_sess{ii},'-',nPairDB.X_unit{ii}, ' (',nPairDB.X_area{ii},')', ' (sp/s)'])
%   %*********************************
%   ppretty([18,7]); pause(0.25)
  
  
%   %PLOT SPIKE COUNT VS. TRIAL NUMBER
%   trialLim = [min(trialAll) max(trialAll)];
%   
%   figure()
%   %*********************************
%   %Spike count vs. trial number -- Neuron X
%   subplot(4,3,1); hold on %Baseline
%   title([nPairDB.X_sess{ii},'-',nPairDB.X_unit{ii},'-',nPairDB.X_area{ii}], 'FontSize',12)
%   scatter(trialAcc, X_Acc_sp_Base, 20, 'r', 'filled');
%   scatter(trialFast, X_Fast_sp_Base, 20, [0 .7 0], 'filled');
%   plot(sort(trialAll), f_Fit(p_X_Base,sort(trialAll)), 'k-', 'LineWidth',1.5)
%   ylabel('Activity (sp/s)')
%   
%   subplot(4,3,2); hold on %Visual Response
%   title([nPairDB.X_sess{ii},'-',nPairDB.X_unit{ii},'-',nPairDB.X_area{ii}], 'FontSize',12)
%   scatter(trialAcc, X_Acc_sp_Vis, 20, 'r', 'filled');
%   scatter(trialFast, X_Fast_sp_Vis, 20, [0 .7 0], 'filled');
%   plot(sort(trialAll), f_Fit(p_X_Vis,sort(trialAll)), 'k-', 'LineWidth',1.5)
%   
%   subplot(4,3,3); hold on %Error Period
%   title([nPairDB.X_sess{ii},'-',nPairDB.X_unit{ii},'-',nPairDB.X_area{ii}], 'FontSize',12)
%   scatter(trialAcc, X_Acc_sp_Err, 20, 'r', 'filled');
%   scatter(trialFast, X_Fast_sp_Err, 20, [0 .7 0], 'filled');
%   plot(sort(trialAll), f_Fit(p_X_Err,sort(trialAll)), 'k-', 'LineWidth',1.5)
%   %*********************************
%   
%   %*********************************
%   %RESIDUAL vs. trial number -- Neuron X
%   subplot(4,3,4); hold on %Baseline
%   scatter(trialAcc, X_Acc_sp_Base_Res, 20, 'r', 'filled');
%   scatter(trialFast, X_Fast_sp_Base_Res, 20, [0 .7 0], 'filled');
%   plot(trialLim, [0 0], 'k-', 'LineWidth',1.5)
%   ylabel('Residual (sp/s)')
%   
%   subplot(4,3,5); hold on %Visual Response
%   scatter(trialAcc, X_Acc_sp_Vis_Res, 20, 'r', 'filled');
%   scatter(trialFast, X_Fast_sp_Vis_Res, 20, [0 .7 0], 'filled');
%   plot(trialLim, [0 0], 'k-', 'LineWidth',1.5)
%   
%   subplot(4,3,6); hold on %Error Period
%   scatter(trialAcc, X_Acc_sp_Err_Res, 20, 'r', 'filled');
%   scatter(trialFast, X_Fast_sp_Err_Res, 20, [0 .7 0], 'filled');
%   plot(trialLim, [0 0], 'k-', 'LineWidth',1.5)
%   %*********************************
% 
%   
%   %*********************************
%   %Spike count vs. trial number -- Neuron Y
%   subplot(4,3,7); hold on %Baseline
%   title([nPairDB.X_sess{ii},'-',nPairDB.Y_unit{ii},'-',nPairDB.Y_area{ii}], 'FontSize',12)
%   scatter(trialAcc, Y_Acc_sp_Base, 20, 'r', 'filled');
%   scatter(trialFast, Y_Fast_sp_Base, 20, [0 .7 0], 'filled');
%   plot(sort(trialAll), f_Fit(p_Y_Base,sort(trialAll)), 'k-', 'LineWidth',1.5)
%   ylabel('Activity (sp/s)')
%   
%   subplot(4,3,8); hold on %Visual Response
%   title([nPairDB.X_sess{ii},'-',nPairDB.Y_unit{ii},'-',nPairDB.Y_area{ii}], 'FontSize',12)
%   scatter(trialAcc, Y_Acc_sp_Vis, 20, 'r', 'filled');
%   scatter(trialFast, Y_Fast_sp_Vis, 20, [0 .7 0], 'filled');
%   plot(sort(trialAll), f_Fit(p_Y_Vis,sort(trialAll)), 'k-', 'LineWidth',1.5)
%   
%   subplot(4,3,9); hold on %Error Period
%   title([nPairDB.X_sess{ii},'-',nPairDB.Y_unit{ii},'-',nPairDB.Y_area{ii}], 'FontSize',12)
%   scatter(trialAcc, Y_Acc_sp_Err, 20, 'r', 'filled');
%   scatter(trialFast, Y_Fast_sp_Err, 20, [0 .7 0], 'filled');
%   plot(sort(trialAll), f_Fit(p_Y_Err,sort(trialAll)), 'k-', 'LineWidth',1.5)
%   %*********************************
%   
%   %*********************************
%   %RESIDUAL vs. trial number -- Neuron Y
%   subplot(4,3,10); hold on %Baseline
%   scatter(trialAcc, Y_Acc_sp_Base_Res, 20, 'r', 'filled');
%   scatter(trialFast, Y_Fast_sp_Base_Res, 20, [0 .7 0], 'filled');
%   plot(trialLim, [0 0], 'k-', 'LineWidth',1.5)
%   xlabel('Trial number'); ylabel('Residual (sp/s)')
%   
%   subplot(4,3,11); hold on %Visual Response
%   scatter(trialAcc, Y_Acc_sp_Vis_Res, 20, 'r', 'filled');
%   scatter(trialFast, Y_Fast_sp_Vis_Res, 20, [0 .7 0], 'filled');
%   plot(trialLim, [0 0], 'k-', 'LineWidth',1.5)
%   xlabel('Trial number')
%   
%   subplot(4,3,12); hold on %Error Period
%   scatter(trialAcc, Y_Acc_sp_Err_Res, 20, 'r', 'filled');
%   scatter(trialFast, Y_Fast_sp_Err_Res, 20, [0 .7 0], 'filled');
%   plot(trialLim, [0 0], 'k-', 'LineWidth',1.5)
%   xlabel('Trial number')
%   %*********************************
%   ppretty([18,7]); pause(0.25)
  
%   pause(.05)
%   print([DIR_PRINT, 'Correlation-',nPairDB.Pair_UID{ii}, '.tif'], '-dtiff')
% %   print([DIR_PRINT, 'CurveFitting-',nPairDB.Pair_UID{ii}, '.tif'], '-dtiff')
%   pause(.05)
%   close()
  
end%for:cellPair(ii)

%% Save table of neuron types for classification
idxCorr_Acc  = (logPVal_Acc_Err >= -log(.06));
idxCorr_Fast = (logPVal_Fast_Err >= -log(.06));

cellData = table(Pair_UID, X_Area, Y_Area, X_Type, Y_Type);
% cellData_Corr_Acc = cellData(idxCorr_Acc,:);      cellData_Corr_Fast = cellData(idxCorr_Fast,:);
% cellData_NCorr_Acc = cellData(~idxCorr_Acc,:);    cellData_NCorr_Fast = cellData(~idxCorr_Fast,:);

%organize table such that Neuron X is always from SEF
idxFlip = ~ismember(cellData.X_Area, {'SEF'});
cellData.tmp = cellData.X_Type;
cellData.X_Type(idxFlip) = cellData.Y_Type(idxFlip);
cellData.Y_Type(idxFlip) = cellData.tmp(idxFlip);
cellData.tmp = [];
cellData.X_Area(idxFlip) = {'SEF'};
cellData.Y_Area(idxFlip) = {SecondArea};

%write to Excel
fileName = 'cellData-All-SEF-FEF.xlsx';
% writetable(cellData_Corr_Acc, [DIR_PRINT, fileName], 'Sheet',1, 'Range','B3')
% writetable(cellData_NCorr_Acc, [DIR_PRINT, fileName], 'Sheet',1, 'Range','H3')
% writetable(cellData_Corr_Fast, [DIR_PRINT, fileName], 'Sheet',1, 'Range','N3')
% writetable(cellData_NCorr_Fast, [DIR_PRINT, fileName], 'Sheet',1, 'Range','T3')
writetable(cellData, [DIR_PRINT, fileName], 'Sheet',1, 'Range','B3')

%% Plot summary statistics for all pairs
figure()
XPLOT_SCATTER = [ones(1,N_PAIR) , 2*ones(1,N_PAIR) , 3*ones(1,N_PAIR)];

subplot(1,2,1); hold on %Accurate condition
plot([.6 3.4],  -log(.05)*ones(1,2), 'k:'); plot([.6 3.4],  log(.05)*ones(1,2), 'k:')
plot([.6 3.4],  -log(.01)*ones(1,2), 'k:'); plot([.6 3.4],  log(.01)*ones(1,2), 'k:')
plot([.6 3.4], -log(.001)*ones(1,2), 'k:'); plot([.6 3.4], log(.001)*ones(1,2), 'k:')
scatter(XPLOT_SCATTER, [logPVal_Acc_Base , logPVal_Acc_Vis , logPVal_Acc_Err], 20, 'r', 'filled', 'MarkerFaceAlpha',0.4)
plot((1:3), [logPVal_Acc_Base ; logPVal_Acc_Vis ; logPVal_Acc_Err]', 'r-')
xticks(1:3); xticklabels({'Base','Vis','Err'}); ylabel('-log(p)')

subplot(1,2,2); hold on %Fast condition
plot([.6 3.4],  -log(.05)*ones(1,2), 'k:'); plot([.6 3.4],  log(.05)*ones(1,2), 'k:')
plot([.6 3.4],  -log(.01)*ones(1,2), 'k:'); plot([.6 3.4],  log(.01)*ones(1,2), 'k:')
plot([.6 3.4], -log(.001)*ones(1,2), 'k:'); plot([.6 3.4], log(.001)*ones(1,2), 'k:')
scatter(XPLOT_SCATTER, [logPVal_Fast_Base , logPVal_Fast_Vis , logPVal_Fast_Err], 20, [0 .7 0], 'filled', 'MarkerFaceAlpha',0.4)
plot((1:3), [logPVal_Fast_Base ; logPVal_Fast_Vis ; logPVal_Fast_Err]', '-', 'Color',[0 .7 0])
xticks(1:3); xticklabels({'Base','Vis','Err'}); ylabel('-log(p)')

ppretty([9,4]); set(gca, 'XMinorTick','off')


end%fxn:myFunction()
