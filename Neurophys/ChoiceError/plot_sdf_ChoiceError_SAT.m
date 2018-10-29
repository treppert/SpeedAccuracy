function [  ] = plot_sdf_ChoiceError_SAT( spikes , ninfo , moves , movesAll , binfo , Adiff )
%plot_sdf_ChoiceError_SAT Summary of this function goes here
%   Detailed explanation goes here

binfo = index_timing_errors_SAT(binfo, moves);

PLOT_INDIVIDUAL_CELLS = false;

TIME_POSTSACC  = 3500 + (-400 : 400);
NSAMP_POSTSACC = length(TIME_POSTSACC);
TIME_PLOT = TIME_POSTSACC - 3500;

NUM_CELLS = length(spikes);

%activity re. saccade initiation
A_corr = NaN(NUM_CELLS,NSAMP_POSTSACC);
A_err  = NaN(NUM_CELLS,NSAMP_POSTSACC);

%median RT for each condition X trial outcome
RT_corr = NaN(1,NUM_CELLS);
RT_err = NaN(1,NUM_CELLS);

maxA = NaN(NUM_CELLS,1); %divisor for normalization

% CC_PLOT = find(Adiff.sacc > .05 & Adiff.rew > .05);
CC_PLOT = find(Adiff.sacc > .05 & abs(Adiff.rew) < .05);
% CC_PLOT = find(abs(Adiff.sacc) < .05 & Adiff.rew > .05);
NUM_CC_PLOT = length(CC_PLOT);

%% Compute the SDFs split by condition and correct/error

for cc = 1:NUM_CELLS
  if ~ismember(cc, CC_PLOT); continue; end
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  TRIAL_POOR_ISOLATION = false(1,binfo(kk).num_trials);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, moves(kk).resptime); 
  
  %remove trials with poor unit isolation
  if (ninfo(cc).iRem1)
    TRIAL_POOR_ISOLATION(ninfo(cc).iRem1 : ninfo(cc).iRem2) = true;
  end
  
  %index by condition
  idx_cond = ((binfo(kk).condition == 3) & ~TRIAL_POOR_ISOLATION);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_err = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %control for choice error direction
  [idx_err, idx_corr] = equate_respdir_err_vs_corr(idx_err, idx_corr, moves(kk).octant);
  
  %remove any activity related to corrective saccade initiation
  trial_err = find(idx_cond & idx_err);
  sdf_kk(idx_cond & idx_err,:) = rem_spikes_post_corrective_SAT(sdf_kk(idx_cond & idx_err,:), movesAll(kk), trial_err);
  
  A_corr(cc,:) = nanmean(sdf_kk(idx_cond & idx_corr,TIME_POSTSACC));
  A_err(cc,:) = nanmean(sdf_kk(idx_cond & idx_err,TIME_POSTSACC));
  
  %save median RTs
  RT_corr(cc) = nanmedian(moves(kk).resptime(idx_cond & idx_corr));
  RT_err(cc) = nanmedian(moves(kk).resptime(idx_cond & idx_err));
  
  %compute normalization factor
  maxA(cc) = max(nanmean(sdf_kk(idx_cond,TIME_POSTSACC)));
  
end%for:cells(cc)



%% Plotting - individual cells
if (PLOT_INDIVIDUAL_CELLS)
for cc = 1:NUM_CELLS
%   if ~strcmp(dir_sep_err{cc}, 'C'); continue; end
  lim_lin = [min([A_corr(cc,:), A_err(cc,:)]), max([A_corr(cc,:), A_err(cc,:)])];
  
  figure(); hold on
  
  plot([0 0], lim_lin, 'k--', 'LineWidth',1.0)
  plot(-RT_corr(cc)*ones(1,2), lim_lin, '-', 'Color',[0 .5 0])
  plot(-RT_err(cc)*ones(1,2), lim_lin, ':', 'Color',[0 .5 0])
%   plot(t_sep_err(cc)*ones(1,2), lim_lin, 'k:')
  
  plot(TIME_PLOT, A_corr(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',1.5)
  plot(TIME_PLOT, A_err(cc,:), ':', 'Color',[0 .7 0], 'LineWidth',1.5)
  
  xlim([TIME_PLOT(1), TIME_PLOT(end)])
  xlabel('Time re. saccade (ms)')
  ylabel('Activity (sp/sec)')
  print_session_unit(gca, ninfo(cc))
  
  ppretty('image_size',[5,3])
%   print(['C:\Users\TDT\Dropbox/tmp/',ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff')
%   print_fig_SAT(ninfo(cc), gcf, '-dtiff')
  
  pause(0.5)
  
end%for:cells(cc)
end%if(PLOT_INDIVIDUAL_CELLS)


%% Plotting - across-cell average
A_Diff = (A_err - A_corr) ./ maxA;

figure(); hold on
shaded_error_bar(TIME_PLOT, nanmean(A_Diff), nanstd(A_Diff)/sqrt(NUM_CC_PLOT), ...
  {'LineWidth',1.5, 'Color',[0 .5 0]})
xlim([TIME_PLOT(1), TIME_PLOT(end)])
xlabel('Time re. saccade (ms)')
ylabel('Difference in normalized activity')

ppretty('image_size',[5,4])

end%function:plot_sdf_error_SEF()
