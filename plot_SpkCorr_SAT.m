function [ ] = plot_SpkCorr_SAT( nPairSummary , nPairDB , binfo , ninfo , spikes )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

DIR_PRINT = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figures\Spike-Correlation-SEF-SC\';

KK_Da = [2, 3, 4, 5, 8, 9];   KK_Eu = [11, 12, 13]; %SC & SEF
% KK_Da = [2, 3, 4, 5, 6, 8, 9];   KK_Eu = []; %FEF & SEF

KK_All = [ KK_Da , KK_Eu ];
nPairSummary = nPairSummary(KK_All,:);
N_SESS = size(nPairSummary, 1);

T_BASE = 3500 + [-600 20]; %baseline (re. stimulus)
T_VIS  = 3500 +  [75 200]; %visual response (re. stimulus)
T_ERR  = 3500 + [100 300]; %error-related (re. saccade)

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
    
    if ((strcmp(X_area,'SEF') && strcmp(Y_area,'SC')) || (strcmp(X_area,'SC') && strcmp(Y_area,'SEF')))
      iiPairKeep = cat(2, iiPairKeep, ii);
    end
    
  end%for:cellPair(ii)
  
end%for:session(kk)

nPairDB = nPairDB(iiPairKeep,:);

%% Compute spike counts for intervals of interest
N_PAIR = size(nPairDB, 1);

logPVal_Base = NaN(1,N_PAIR);
logPVal_Vis  = NaN(1,N_PAIR);
logPVal_Err  = NaN(1,N_PAIR);

for ii = 1:N_PAIR
  
  X_unitNum = nPairDB.X_unitNum(ii);
  Y_unitNum = nPairDB.Y_unitNum(ii);
  
  X_spikes = spikes(X_unitNum).SAT;
  Y_spikes = spikes(Y_unitNum).SAT;
    
  kk = ismember({binfo.session}, nPairDB.X_sess(ii));
  
  %index by isolation quality
  X_idxIso = identify_trials_poor_isolation_SAT(ninfo(X_unitNum), binfo(kk).num_trials);
  Y_idxIso = identify_trials_poor_isolation_SAT(ninfo(Y_unitNum), binfo(kk).num_trials);
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  
  trialAcc = find(idxAcc & ~(X_idxIso | Y_idxIso));
  trialFast = find(idxFast & ~(X_idxIso | Y_idxIso));
  
  X_Acc_spikes = X_spikes(trialAcc);   X_Fast_spikes = X_spikes(trialFast);
  Y_Acc_spikes = Y_spikes(trialAcc);   Y_Fast_spikes = Y_spikes(trialFast);
  
  %compute spike counts for Baseline Period
  %****************************************
  X_Acc_sp_Base  = cellfun(@(x) sum((x > T_BASE(1)) & (x < T_BASE(2))), X_Acc_spikes);
  X_Fast_sp_Base = cellfun(@(x) sum((x > T_BASE(1)) & (x < T_BASE(2))), X_Fast_spikes);
  Y_Acc_sp_Base  = cellfun(@(x) sum((x > T_BASE(1)) & (x < T_BASE(2))), Y_Acc_spikes);
  Y_Fast_sp_Base = cellfun(@(x) sum((x > T_BASE(1)) & (x < T_BASE(2))), Y_Fast_spikes);
  %****************************************
  
  %compute spike counts for Visual Response Period
  %****************************************
  X_Acc_sp_Vis  = cellfun(@(x) sum((x > T_VIS(1)) & (x < T_VIS(2))), X_Acc_spikes);
  X_Fast_sp_Vis = cellfun(@(x) sum((x > T_VIS(1)) & (x < T_VIS(2))), X_Fast_spikes);
  Y_Acc_sp_Vis  = cellfun(@(x) sum((x > T_VIS(1)) & (x < T_VIS(2))), Y_Acc_spikes);
  Y_Fast_sp_Vis = cellfun(@(x) sum((x > T_VIS(1)) & (x < T_VIS(2))), Y_Fast_spikes);
  %****************************************
  
  %compute spike counts for Error Period
  %****************************************
  RT_Acc  = binfo(kk).resptime(trialAcc);   numAcc = length(trialAcc);
  RT_Fast = binfo(kk).resptime(trialFast);  numFast = length(trialFast);
  
  X_Acc_sp_Err = NaN(1,numAcc);   Y_Acc_sp_Err = NaN(1,numAcc);
  X_Fast_sp_Err = NaN(1,numFast);   Y_Fast_sp_Err = NaN(1,numFast);
  
  for jj = 1:numAcc %Accurate condition
    t_Err_jj = RT_Acc(jj) + T_ERR;
    X_Acc_sp_Err(jj) = sum((X_Acc_spikes{jj} > t_Err_jj(1)) & (X_Acc_spikes{jj} < t_Err_jj(2)));
    Y_Acc_sp_Err(jj) = sum((Y_Acc_spikes{jj} > t_Err_jj(1)) & (Y_Acc_spikes{jj} < t_Err_jj(2)));
  end
  for jj = 1:numFast %Fast condition
    t_Err_jj = RT_Fast(jj) + T_ERR;
    X_Fast_sp_Err(jj) = sum((X_Fast_spikes{jj} > t_Err_jj(1)) & (X_Fast_spikes{jj} < t_Err_jj(2)));
    Y_Fast_sp_Err(jj) = sum((Y_Fast_spikes{jj} > t_Err_jj(1)) & (Y_Fast_spikes{jj} < t_Err_jj(2)));
  end
  %****************************************
  
  %combine data across conditions
  X_sp_Base = [X_Acc_sp_Base X_Fast_sp_Base];   Y_sp_Base = [Y_Acc_sp_Base Y_Fast_sp_Base];
  X_sp_Vis = [X_Acc_sp_Vis X_Fast_sp_Vis];      Y_sp_Vis = [Y_Acc_sp_Vis Y_Fast_sp_Vis];
  X_sp_Err = [X_Acc_sp_Err X_Fast_sp_Err];      Y_sp_Err = [Y_Acc_sp_Err Y_Fast_sp_Err];
  
  %COMPUTE SPEARMAN RANK CORRELATION COEFFICIENT AND P-VALUE
  [rho_Base, pval_Base] = corr(X_sp_Base', Y_sp_Base', 'Type','Spearman');
  [rho_Vis,  pval_Vis]  = corr(X_sp_Vis', Y_sp_Vis', 'Type','Spearman');
  [rho_Err,  pval_Err]  = corr(X_sp_Err', Y_sp_Err', 'Type','Spearman');
  
  %save (signed) rank correlation p-value
  logPVal_Base(ii) = sign(rho_Base) * -log(pval_Base);
  logPVal_Vis(ii)  = sign(rho_Vis)  * -log(pval_Vis);
  logPVal_Err(ii)  = sign(rho_Err)  * -log(pval_Err);
  
  %PLOT CORRELATION AND SPIKE COUNT VS. TRIAL NUMBER
%   figure()
%   
%   subplot(2,3,1); hold on %correlation -- Baseline
%   title([nPairDB.X_sess{ii}, ' -- Baseline: R_{Sp} = ', num2str(rho_Base), '  p_{Sp} = ', num2str(pval_Base)], 'FontSize',8)
%   scatter(X_sp_Base, Y_sp_Base, 25, 'k', 'filled', 'MarkerFaceAlpha',0.3)
%   xlabel([nPairDB.X_unit{ii}, ' (',nPairDB.X_area{ii},')', ' (sp/s)'])
%   ylabel([nPairDB.Y_unit{ii}, ' (',nPairDB.Y_area{ii},')', ' (sp/s)'])
%   
%   subplot(2,3,2); hold on %correlation -- Visual Response
%   title(['Vis. response: R_{Sp} = ', num2str(rho_Vis), '  p_{Sp} = ', num2str(pval_Vis)], 'FontSize',8)
%   scatter(X_sp_Vis, Y_sp_Vis, 25, 'k', 'filled', 'MarkerFaceAlpha',0.3)
%   xlabel([nPairDB.X_unit{ii}, ' (',nPairDB.X_area{ii},')', ' (sp/s)'])
%   ylabel([nPairDB.Y_unit{ii}, ' (',nPairDB.Y_area{ii},')', ' (sp/s)'])
%   
%   subplot(2,3,3); hold on %correlation -- Error Period
%   title(['Post-response: R_{Sp} = ', num2str(rho_Err), '  p_{Sp} = ', num2str(pval_Err)], 'FontSize',8)
%   scatter(X_sp_Err, Y_sp_Err, 25, 'k', 'filled', 'MarkerFaceAlpha',0.3)
%   xlabel([nPairDB.X_unit{ii}, ' (',nPairDB.X_area{ii},')', ' (sp/s)'])
%   ylabel([nPairDB.Y_unit{ii}, ' (',nPairDB.Y_area{ii},')', ' (sp/s)'])
%   
%   subplot(2,3,4); hold on %spike count vs. trial -- Baseline
%   scatter(trialAcc, X_Acc_sp_Base, 25, 'r', 'filled');
%   scatter(trialFast, X_Fast_sp_Base, 25, [0 .7 0], 'filled');
%   scatter(trialAcc, Y_Acc_sp_Base, 25, [.5 0 0], 'filled');
%   scatter(trialFast, Y_Fast_sp_Base, 25, [0 .4 0], 'filled');
%   legend({nPairDB.X_unit{ii} nPairDB.X_unit{ii} nPairDB.Y_unit{ii} nPairDB.Y_unit{ii}}, ...
%     'Location','north', 'Orientation','horizontal')
%   xlabel('Trial number'); ylabel('Activity (sp/s)')
%   
%   subplot(2,3,5); hold on %spike count vs. trial -- Visual Response
%   scatter(trialAcc, X_Acc_sp_Vis, 25, 'r', 'filled');
%   scatter(trialFast, X_Fast_sp_Vis, 25, [0 .7 0], 'filled');
%   scatter(trialAcc, Y_Acc_sp_Vis, 25, [.5 0 0], 'filled');
%   scatter(trialFast, Y_Fast_sp_Vis, 25, [0 .4 0], 'filled');
%   legend({nPairDB.X_unit{ii} nPairDB.X_unit{ii} nPairDB.Y_unit{ii} nPairDB.Y_unit{ii}}, ...
%     'Location','north', 'Orientation','horizontal')
%   xlabel('Trial number'); ylabel('Activity (sp/s)')
%   
%   subplot(2,3,6); hold on %spike count vs. trial -- Error Period
%   scatter(trialAcc, X_Acc_sp_Err, 25, 'r', 'filled');
%   scatter(trialFast, X_Fast_sp_Err, 25, [0 .7 0], 'filled');
%   scatter(trialAcc, Y_Acc_sp_Err, 25, [.5 0 0], 'filled');
%   scatter(trialFast, Y_Fast_sp_Err, 25, [0 .4 0], 'filled');
%   legend({nPairDB.X_unit{ii} nPairDB.X_unit{ii} nPairDB.Y_unit{ii} nPairDB.Y_unit{ii}}, ...
%     'Location','north', 'Orientation','horizontal')
%   xlabel('Trial number'); ylabel('Activity (sp/s)')
%   
%   ppretty([18,7])
%   
%   pause(.05)
%   print([DIR_PRINT, nPairDB.Pair_UID{ii}, '.tif'], '-dtiff')
%   pause(.05)
%   close()
  
end%for:cellPair(ii)


%% Plot summary statistics for all pairs
figure(); hold on
plot([.6 3.4],  -log(.05)*ones(1,2), 'k:'); plot([.6 3.4],  log(.05)*ones(1,2), 'k:')
plot([.6 3.4],  -log(.01)*ones(1,2), 'k:'); plot([.6 3.4],  log(.01)*ones(1,2), 'k:')
plot([.6 3.4], -log(.001)*ones(1,2), 'k:'); plot([.6 3.4], log(.001)*ones(1,2), 'k:')
plot((1:3), [logPVal_Base ; logPVal_Vis ; logPVal_Err]', 'k.-', 'MarkerSize',15)
xticks(1:3); xticklabels({'Base','Vis','Err'}); ylabel('-log(p)')
ppretty([6.4,4]); set(gca, 'XMinorTick','off')


end%fxn:myFunction()
