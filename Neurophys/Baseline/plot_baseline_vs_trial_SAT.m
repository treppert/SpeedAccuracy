function [  ] = plot_baseline_vs_trial_SAT( binfo , ninfo , spikes )
%plot_baseline_vs_trial Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);

TIME_STIM = 3500;
TIME_BASE = ( -700 : -1 );
IDX_BASE = TIME_BASE([1,end]) + TIME_STIM;

%% Compute baseline activity vs. trial

for cc = 1:NUM_CELLS
  
  kk = find(ismember({binfo.session}, ninfo(cc).sesh));
  
  %count spikes in the appropriate baseline interval
  num_sp_bline = NaN(1,binfo(kk).num_trials);
  for jj = 1:binfo(kk).num_trials
    num_sp_bline(jj) = sum((spikes(cc).SAT{jj} > IDX_BASE(1)) & (spikes(cc).SAT{jj} > IDX_BASE(2)));
  end
  
  idx_acc = (binfo(kk).condition == 1);
  idx_fast = (binfo(kk).condition == 3);
  idx_ntrl = (binfo(kk).condition == 4);
  
  figure(); hold on
  plot(find(idx_ntrl), num_sp_bline(idx_ntrl), 'k.')
  plot(find(idx_acc), num_sp_bline(idx_acc), 'r.')
  plot(find(idx_fast), num_sp_bline(idx_fast), '.', 'Color',[0 .7 0])
  title([ninfo(cc).sesh, '-', ninfo(cc).unit], 'FontSize',8)
  
%   pause(0.1); print(['~/Dropbox/Speed Accuracy/SEF_SAT/Figs/Baseline-X-Trial/Eu/',ninfo(cc).sesh,'-',ninfo(cc).unit,'.tif'], '-dtiff'); pause(0.1)
  
end%for:cells(cc)


end%function:plot_baseline_vs_trial()

