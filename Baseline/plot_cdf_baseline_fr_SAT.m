function [  ] = plot_cdf_baseline_fr_SAT( ninfo , spikes , binfo , moves )
%plot_cdf_baseline_fr_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);

TIME_STIM = 3500;
TIME_BASE = ( -700 : -1 );
IDX_BASE = TIME_BASE([1,end]) + TIME_STIM;

binfo = index_timing_errors_SAT(binfo, moves);

for cc = 1:NUM_CELLS
  
  kk = find(ismember({binfo.session}, ninfo(cc).sesh));
  
  %count spikes in the appropriate baseline interval
  num_sp_bline = NaN(1,binfo(kk).num_trials);
  for jj = 1:binfo(kk).num_trials
    num_sp_bline(jj) = sum((spikes(cc).SAT{jj} > IDX_BASE(1)) & (spikes(cc).SAT{jj} > IDX_BASE(2)));
  end
  
  idx_acc = (binfo(kk).condition == 1);
  idx_fast = (binfo(kk).condition == 3);
  
  Nsp_bline_A = sort(num_sp_bline(idx_acc));
  Nsp_bline_F = sort(num_sp_bline(idx_fast));
  
  %perform a two-sample t-test, assuming equal variances
  [~,pval] = ttest2(Nsp_bline_A', Nsp_bline_F');
  
  yy_A = (1:sum(idx_acc)) / sum(idx_acc);
  yy_F = (1:sum(idx_fast)) / sum(idx_fast);
  
  figure(); hold on
  plot(Nsp_bline_F, yy_F, '-', 'Color',[0 .7 0])
  plot(Nsp_bline_A, yy_A, 'r-')
  title([ninfo(cc).unit,' - p=', num2str(pval)], 'FontSize',8)
  
%   pause(0.25)
  
end%for:cells(cc)

end%fxn:plot_cdf_baseline_fr_SAT()

