function [  ] = plot_hist_bline_diff_across_SAT( ninfo , spikes , binfo , moves )
%plot_hist_bline_diff_across_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);

TIME_STIM = 3500;
TIME_BASE = ( -700 : -1 );
IDX_BASE = TIME_BASE([1,end]) + TIME_STIM;

binfo = index_timing_errors_SAT(binfo, moves);

Nsp_bline_A = NaN(1,NUM_CELLS);
Nsp_bline_F = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  
  kk = find(ismember({binfo.session}, ninfo(cc).sesh));
  
  %count spikes in the appropriate baseline interval
  num_sp_bline = NaN(1,binfo(kk).num_trials);
  for jj = 1:binfo(kk).num_trials
    num_sp_bline(jj) = sum((spikes(cc).SAT{jj} > IDX_BASE(1)) & (spikes(cc).SAT{jj} > IDX_BASE(2)));
  end
  
  idx_acc = (binfo(kk).condition == 1);
  idx_fast = (binfo(kk).condition == 3);
  
  Nsp_bline_A(cc) = mean(num_sp_bline(idx_acc));
  Nsp_bline_F(cc) = mean(num_sp_bline(idx_fast));
  
end%for:cells(cc)

diff_bline = Nsp_bline_A - Nsp_bline_F;

%% Plotting

figure(); hold on

histogram(diff_bline, 'BinWidth',2, 'FaceColor',[.5 .5 .5])

%color-code cells with significant difference
idx_acc = strcmp({ninfo.baseline}, 'acc');
idx_fast = strcmp({ninfo.baseline}, 'fast');

histogram(diff_bline(idx_acc), 'BinWidth',2, 'FaceColor','k')
histogram(diff_bline(idx_fast), 'BinWidth',2, 'FaceColor','k')

xlim([-15 15])
ppretty('image_size',[4.8,3])

end%fxn:plot_hist_bline_diff_across_SAT()

