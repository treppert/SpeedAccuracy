function [ varargout ] = calc_avg_baseline_SAT( spikes , ninfo , binfo , moves )
%calc_avg_baseline_SAT Summary of this function goes here
%   Detailed explanation goes here

CONTROL_ERR_DIR = false;

TIME_STIM = 3500;
TIME_BASE = ( -700 : -1 );
IDX_BASE = TIME_BASE([1,end]) + TIME_STIM;

NUM_CELLS = length(spikes);

%initialize baseline X condition
mu_bline = new_struct({'acc','fast','all'}, 'dim',[1,NUM_CELLS]);
mu_bline = populate_struct(mu_bline, {'acc','fast','all'}, NaN);
sd_bline = mu_bline;

%initialize baseline X condition X error
mu_bline_A = new_struct({'corr','err'}, 'dim',[1,NUM_CELLS]); %timing error
mu_bline_A = populate_struct(mu_bline_A, {'corr','err'}, NaN);
mu_bline_F = mu_bline_A; %direction error

binfo = index_timing_errors_SAT(binfo, moves);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  idx_A = (binfo(kk).condition == 1);
  idx_F = (binfo(kk).condition == 3);
  
  idx_corr_F = (~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold) & idx_F);
  idx_corr_A = (~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold) & idx_A);
  idx_errdir_F = (binfo(kk).err_dir & ~binfo(kk).err_time & idx_F);
%   idx_errdir_F = (binfo(kk).err_dir & idx_F);
  idx_errtime_A = (~binfo(kk).err_dir & binfo(kk).err_time & idx_A);
  
  num_sp_bline = NaN(1,binfo(kk).num_trials);
  for jj = 1:binfo(kk).num_trials
    num_sp_bline(jj) = sum((spikes(cc).SAT{jj} > IDX_BASE(1)) & (spikes(cc).SAT{jj} > IDX_BASE(2)));
  end
  
  mu_bline(cc).all = mean(num_sp_bline);          sd_bline(cc).all = std(num_sp_bline);
  mu_bline(cc).acc = mean(num_sp_bline(idx_A));   sd_bline(cc).acc = std(num_sp_bline(idx_A));
  mu_bline(cc).fast = mean(num_sp_bline(idx_F));  sd_bline(cc).fast = std(num_sp_bline(idx_F));
  
  %control for direction of error movements
  %****************************************
  if (CONTROL_ERR_DIR)
    [idx_errdir_F, idx_corr_F] = equate_respdir_err_vs_corr(idx_errdir_F, idx_corr_F, moves(kk).octant);
    [idx_errtime_A, idx_corr_A] = equate_respdir_err_vs_corr(idx_errtime_A, idx_corr_A, moves(kk).octant);
  end
  %****************************************
  
  mu_bline_A(cc).corr = mean(num_sp_bline(idx_corr_A));
  mu_bline_A(cc).err = mean(num_sp_bline(idx_errtime_A));
  mu_bline_F(cc).corr = mean(num_sp_bline(idx_corr_F));
  mu_bline_F(cc).err = mean(num_sp_bline(idx_errdir_F));
  
end%for:cells(kk)

if (nargout > 0)
  varargout{1} = mu_bline;
  if (nargout > 1)
    varargout{2} = sd_bline;
    if (nargout > 2)
      varargout{3} = mu_bline_A;
      if (nargout > 3)
        varargout{4} = mu_bline_F;
      end
    end
  end
  return
end

%% Plotting - Bar
if (false)
Y_BAR = [mean([mu_bline.acc]), mean([mu_bline_A.corr]), mean([mu_bline_A.err]), ...
  mean([mu_bline.fast]), mean([mu_bline_F.corr]), mean([mu_bline_F.err])];

Y_ERR = [std([mu_bline.acc]), std([mu_bline_A.corr]), std([mu_bline_A.err]), ...
  std([mu_bline.fast]), std([mu_bline_F.corr]), std([mu_bline_F.err])] / sqrt(NUM_CELLS);

figure(); hold on
bar(1:6, Y_BAR, 0.5)
errorbar_no_caps(1:6, Y_BAR, 'err',Y_ERR)
ppretty()

[~,pval] = ttest([mu_bline_A.err] - [mu_bline_A.corr]);
fprintf('T-test ACC (errtime - corr) -- pval = %g\n', pval)

[~,pval] = ttest([mu_bline_F.err] - [mu_bline_F.corr]);
fprintf('T-test FAST (errdir - corr) -- pval = %g\n', pval)

pause(0.25)
end
%% Plotting - CDF
if (false)
Y_CDF = (1:NUM_CELLS) / NUM_CELLS;

X_cdf_A_corr = sort([mu_bline_A.corr]);
X_cdf_A_err = sort([mu_bline_A.err]);
X_cdf_F_corr = sort([mu_bline_F.corr]);
X_cdf_F_err = sort([mu_bline_F.err]);

figure(); hold on
plot(X_cdf_A_corr, Y_CDF, 'r-', 'LineWidth',0.75)
plot(X_cdf_A_err, Y_CDF, 'r--', 'LineWidth',1.5)
ppretty()

pause(0.25)

figure(); hold on
plot(X_cdf_F_corr, Y_CDF, '-', 'Color',[0 .7 0], 'LineWidth',0.75)
plot(X_cdf_F_err, Y_CDF, '--', 'Color',[0 .7 0], 'LineWidth',1.5)
ppretty()

pause(0.25)
end
%% Plotting - Histogram X condition
if (true)
figure()
subplot(3,1,1); histogram([mu_bline.all], 'FaceColor',[.6 .6 .6], 'BinWidth',10)
subplot(3,1,2); histogram([mu_bline.acc], 'FaceColor','r', 'BinWidth',10)
subplot(3,1,3); histogram([mu_bline.fast], 'FaceColor',[0 .7 0], 'BinWidth',10)
ppretty('image_size',[6,8])
end
%% Plotting - Histogram X condition X error
if (false)
  diff_bline_F = [mu_bline_F.err]-[mu_bline_F.corr];
  diff_bline_A = [mu_bline_A.err]-[mu_bline_A.corr];
  
  [~,pval_F,~,tstatF] = ttest(diff_bline_F);
  [~,pval_A,~,tstatA] = ttest(diff_bline_A);
  fprintf('FAST: t(%d) = %g, p = %g\n', tstatF.df, tstatF.tstat, pval_F)
  fprintf('ACC: t(%d) = %g, p = %g\n', tstatA.df, tstatA.tstat, pval_A)
  
  figure(); hold on
  histogram(diff_bline_F, 'FaceColor',[0 .7 0], 'BinWidth',5)
  plot([0 0], [0 10], 'k-')
  plot(mean(diff_bline_F)*ones(1,2), [0 10], 'k--')
  ppretty()
  
  pause(0.25)
  
  figure(); hold on
  histogram(diff_bline_A, 'FaceColor','r', 'BinWidth',5)
  plot([0 0], [0 10], 'k-')
  plot(mean(diff_bline_A)*ones(1,2), [0 10], 'k--')
  ppretty()
  
  pause(0.25)
end
%% Plotting - Scatter X condition
if (false)
% figure(); hold on
% % plot([mu_bline.acc], [mu_bline.fast], 'ko')
% plot([mu_bline_A.corr], [mu_bline_F.corr], 'ko')
% plot([0 200], [0 200], '--', 'Color',[.5 .5 .5])
% ppretty('image_size',[5,4])
% 
% pause(0.25)

figure()
% histogram([mu_bline.acc] - [mu_bline.fast], 'FaceColor',[.5 .5 .5])
histogram([mu_bline_A.corr] - [mu_bline_F.corr], 'FaceColor',[.5 .5 .5])
ppretty('image_size',[3,4])

[~,pval,~,tstat] = ttest([mu_bline_A.corr] - [mu_bline_F.corr]);
fprintf('ACC: %g +- %g   FAST: %g +- %g\n', mean([mu_bline_A.corr]), std([mu_bline_A.corr])/sqrt(NUM_CELLS), ...
  mean([mu_bline_F.corr]), std([mu_bline_F.corr])/sqrt(NUM_CELLS))
fprintf('t-test for sig. diff. (A - F) -- pval = %g  t(%d) = %g\n', pval, tstat.df, tstat.tstat)
end
%% Plotting - Scatter X condition X error
if (false)
figure(); hold on
plot([mu_bline_A.corr], [mu_bline_A.err], 'ro')
plot([0 200], [0 200], '--', 'Color',[.5 .5 .5])
ppretty('image_size',[5,4])

pause(0.25)

figure(); hold on
plot([mu_bline_F.corr], [mu_bline_F.err], 'o', 'Color',[0 .7 0])
plot([0 200], [0 200], '--', 'Color',[.5 .5 .5])
ppretty('image_size',[5,4])
end

end%fxn:calc_avg_baseline_SAT()

