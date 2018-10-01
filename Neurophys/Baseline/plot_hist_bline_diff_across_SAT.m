function [  ] = plot_hist_bline_diff_across_SAT( ninfo , spikes , binfo , moves , varargin )
%plot_hist_bline_diff_across_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'BinWidth=',[]}});

NUM_CELLS = length(spikes);

TIME_STIM = 3500;
TIME_BASE = ( -700 : -1 );
IDX_BASE = TIME_BASE([1,end]) + TIME_STIM;

binfo = index_timing_errors_SAT(binfo, moves);

Nsp_bline_A = NaN(1,NUM_CELLS);
Nsp_bline_F = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  kk = find(ismember({binfo.session}, ninfo(cc).sess));
  TRIAL_POOR_ISOLATION = false(1,binfo(kk).num_trials); %initialize NaN indexing for this cell
  
  %count spikes in the appropriate baseline interval
  num_sp_bline = NaN(1,binfo(kk).num_trials);
  for jj = 1:binfo(kk).num_trials
    num_sp_bline(jj) = sum((spikes(cc).SAT{jj} > IDX_BASE(1)) & (spikes(cc).SAT{jj} > IDX_BASE(2)));
  end
  
  %remove trials if the unit was poorly isolated
  if (ninfo(cc).iRem1)
    TRIAL_POOR_ISOLATION(ninfo(cc).iRem1 : ninfo(cc).iRem2) = true;
    num_sp_bline(TRIAL_POOR_ISOLATION) = NaN;
  end
  
  %index by condition
  idx_acc = ((binfo(kk).condition == 1) & ~TRIAL_POOR_ISOLATION);
  idx_fast = ((binfo(kk).condition == 3) & ~TRIAL_POOR_ISOLATION);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  
%   Nsp_bline_A(cc) = mean(num_sp_bline(idx_acc));
%   Nsp_bline_F(cc) = mean(num_sp_bline(idx_fast));
  Nsp_bline_A(cc) = mean(num_sp_bline(idx_acc & idx_corr));
  Nsp_bline_F(cc) = mean(num_sp_bline(idx_fast & idx_corr));
  
end%for:cells(cc)

diff_bline = Nsp_bline_A - Nsp_bline_F;

%% Plotting
%color-code cells with significant difference
idx_pref_A = strcmp({ninfo.bline}, 'A');
idx_pref_F = strcmp({ninfo.bline}, 'F');

figure(); hold on

if isempty(args.BinWidth)
  histogram(diff_bline, 'FaceColor',[.5 .5 .5])
  histogram(diff_bline(idx_pref_A), 'FaceColor','k')
  histogram(diff_bline(idx_pref_F), 'FaceColor','k')
else
  histogram(diff_bline, 'FaceColor',[.5 .5 .5], 'BinWidth',args.BinWidth)
  histogram(diff_bline(idx_pref_A), 'FaceColor',[.2 .2 .2], 'BinWidth',args.BinWidth)
  histogram(diff_bline(idx_pref_F), 'FaceColor',[.2 .2 .2], 'BinWidth',args.BinWidth)
end


ppretty('image_size',[4.8,4])

end%fxn:plot_hist_bline_diff_across_SAT()

