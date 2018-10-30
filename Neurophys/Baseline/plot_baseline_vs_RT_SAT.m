function [ varargout ] = plot_baseline_vs_RT_SAT( binfo , moves , ninfo , spikes , condition )
%plot_baseline_vs_RT_SAT Summary of this function goes here
%   Detailed explanation goes here

PLOT_INDIV_CELLS = true;
MIN_NUM_CELLS = 3; %for plotting across all cells
LIM_RT = [100,1200];

if strcmp(condition, 'acc')
  BIN_RT = (400 : 40 : 700);
elseif strcmp(condition, 'fast')
  BIN_RT = (200 : 30 : 400);
else
  error('Input "condition" is incorrect')
end

RT_PLOT = BIN_RT(1:end-1) + diff(BIN_RT)/2;
NUM_BIN = length(RT_PLOT);
MIN_PER_BIN = 10; %minimum number of trials per RT bin

TIME_BASE = ( -700 : -1 );
IDX_BASE = TIME_BASE([1,end]) + 3500;

NUM_CELLS = length(spikes);

binfo = index_timing_errors_SAT(binfo, moves);

%initializations
sp_Corr = NaN(NUM_CELLS,NUM_BIN);

%stats
rho = NaN(1,NUM_CELLS);
pval = NaN(1,NUM_CELLS);

for cc = 15:15%NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  TRIAL_POOR_ISOLATION = false(1,binfo(kk).num_trials); %initialize NaN indexing for this cell
  
  idx_A = (binfo(kk).condition == 1);
  idx_F = (binfo(kk).condition == 3);
  
  if strcmp(condition, 'fast')
    idx_corr = (~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold) & idx_F);
  else
    idx_corr = (~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold) & idx_A);
  end
  
  %remove outlier values for RT
  RT = double(moves(kk).resptime);
  RT((RT > LIM_RT(2)) | (RT < LIM_RT(1))) = NaN;
  
  num_sp_bline = NaN(1,binfo(kk).num_trials);
  for jj = 1:binfo(kk).num_trials
    num_sp_bline(jj) = sum((spikes(cc).SAT{jj} > IDX_BASE(1)) & (spikes(cc).SAT{jj} > IDX_BASE(2)));
  end
  
  %remove trials based on poor isolation
  if (ninfo(cc).iRem1)
    TRIAL_POOR_ISOLATION(ninfo(cc).iRem1 : ninfo(cc).iRem2) = true;
    num_sp_bline(TRIAL_POOR_ISOLATION) = NaN;
  end
  
  if (PLOT_INDIV_CELLS)
    fit_lin = fit(RT(idx_corr & ~TRIAL_POOR_ISOLATION & ~isnan(RT))', num_sp_bline(idx_corr & ~TRIAL_POOR_ISOLATION & ~isnan(RT))', 'poly1');
    figure(); hold on
    plot(RT(idx_corr & ~TRIAL_POOR_ISOLATION), num_sp_bline(idx_corr & ~TRIAL_POOR_ISOLATION), 'ko')
    plot([BIN_RT(1),BIN_RT(end)], fit_lin([BIN_RT(1),BIN_RT(end)]), 'k-')
    ppretty()
    pause(1.0)
  end
  
  %linear regression to determine cells that show a postive relationship
  [rho(cc),pval(cc)] = corr(RT(idx_corr & ~TRIAL_POOR_ISOLATION & ~isnan(RT))', num_sp_bline(idx_corr & ~TRIAL_POOR_ISOLATION & ~isnan(RT))', 'type','Spearman');
  
  %use the regression results to exclude neurons
  if ~((rho(cc) > 0) && (pval(cc) < .05)); continue; end
  
  %bin spike counts by RT
  for jj = 1:NUM_BIN
    idx_jj = (((RT > BIN_RT(jj)) & (RT < BIN_RT(jj+1))) & idx_corr & ~TRIAL_POOR_ISOLATION);
    
    if (sum(idx_jj) >= MIN_PER_BIN) %enforce min number of trials
      sp_Corr(cc,jj) = mean(num_sp_bline(idx_jj)) - mean(num_sp_bline(~TRIAL_POOR_ISOLATION & (idx_A | idx_F)));
    end
  end%for:RT_bins(jj)
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = rho;
  if (nargout > 1)
    varargout{2} = pval;
  end
end
return
%% Plotting
if strcmp(condition, 'acc')
  COLOR_PLOT = 'r';
else
  COLOR_PLOT = [0 .7 0];
end

sp_Corr(:,sum(~isnan(sp_Corr),1) < MIN_NUM_CELLS) = NaN;
NUM_SEM = sum(~isnan(sp_Corr),1);

%perform a linear fit to the data
xx_fit = repmat(RT_PLOT', NUM_CELLS,1);
yy_fit = reshape(sp_Corr', NUM_CELLS*NUM_BIN,1);
i_nan = isnan(yy_fit);
xx_fit(i_nan) = [];
yy_fit(i_nan) = [];
[fit_lin,gof_lin] = fit(xx_fit, yy_fit, 'poly1');

figure(); hold on
% plot(RT_PLOT, sp_Corr, 'ko')
plot(RT_PLOT, fit_lin(RT_PLOT), '-', 'color',COLOR_PLOT)
errorbar_no_caps(RT_PLOT, nanmean(sp_Corr), 'err',nanstd(sp_Corr)./sqrt(NUM_SEM), 'color',COLOR_PLOT)
ppretty()

pause(0.25)

figure(); hold on
plot([-.2 .3], -log(.05)*ones(1,2), '-', 'Color',[.5 .5 .5])
plot([-.2 .3], -log(.01)*ones(1,2), '-', 'Color',[.5 .5 .5])
plot([-.2 .3], -log(.001)*ones(1,2), '-', 'Color',[.5 .5 .5])
plot(rho, -log(pval), 'ko')
ppretty('image_size',[3.2,5])

end%fxn:plot_baseline_vs_RT_SAT()

