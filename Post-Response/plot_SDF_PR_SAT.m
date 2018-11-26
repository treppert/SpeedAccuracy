function [  ] = plot_SDF_PR_SAT( binfo , moves , movesPP , ninfo , spikes )
%plot_SDF_PR_SAT() Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);
MIN_NUM_TRIALS = 10;

TIME_POSTSACC  = 3500 + (-300 : 500);
NSAMP_POSTSACC = length(TIME_POSTSACC);

ACorr = NaN(NUM_CELLS,NSAMP_POSTSACC);
AErrChc = new_struct({'PP2T','PP2D','PP2F'}, 'dim',[1,NUM_CELLS]);
AErrChc = populate_struct(AErrChc, {'PP2T','PP2D','PP2F'}, NaN(NSAMP_POSTSACC,1));

ccNoPlot = false(1,NUM_CELLS); %flag cells on sessions with too few trials

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, moves(kk).resptime); 
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  
  %index by condition
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
%   idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idxErrChc = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %save activity -- trials with correct response
  ACorr(cc,:) = nanmean(sdf_kk(idxFast & idxCorr, TIME_POSTSACC));
  
  %index by post-primary saccade endpoint
  idx_PP_T = (movesPP(kk).endpt == 1);
  idx_PP_D = (movesPP(kk).endpt == 2);
  idx_PP_F = (movesPP(kk).endpt == 3);
  idx_PP_DF = ((movesPP(kk).endpt == 2) | (movesPP(kk).endpt == 3));
  
  %save activity -- trials with choice error
  AErrChc(cc).PP2T(:) = nanmean(sdf_kk(idxFast & idxErrChc & idx_PP_T, TIME_POSTSACC));
  if (sum(idx_PP_DF) >= MIN_NUM_TRIALS)
    AErrChc(cc).PP2D(:) = nanmean(sdf_kk(idxFast & idxErrChc & idx_PP_DF, TIME_POSTSACC));
  else
    ccNoPlot(cc) = true;
  end
%   if (sum(idx_PP_F) >= MIN_NUM_TRIALS)
%     AErrChc(cc).PP2F(:) = nanmean(sdf_kk(idxFast & idxErrChc & idx_PP_F, TIME_POSTSACC));
%   end
  
end%for:cells(cc)


%% Plotting

for cc = 1:NUM_CELLS
  if (ccNoPlot(cc)); continue; end
  
  limLin = quantile(ACorr(cc,:), [0,1]);
  
  figure(); hold on
  plot([0 0], limLin, 'k--', 'LineWidth',1.0)
  
%   plot(TIME_POSTSACC-3500, AErrChc(cc).PP2F, '--', 'Color',[.4 .4 .4], 'LineWidth',1.25)
  plot(TIME_POSTSACC-3500, AErrChc(cc).PP2D, '--', 'Color','k', 'LineWidth',1.25)
  plot(TIME_POSTSACC-3500, AErrChc(cc).PP2T, '--', 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(TIME_POSTSACC-3500, ACorr(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',1.0)
  
  xlabel('Time from primary saccade (ms)')
  ylabel('Activity (sp/sec)')
  print_session_unit(gca, ninfo(cc), 'horizontal')
  ppretty()
  
  pause(0.25)
  print_fig_SAT(ninfo(cc), gcf, '-dtiff')
  pause(0.25)
  close()
  
end%for:cells(cc)



end%fxn:plot_SDF_PR_SAT()

  %index by saccade direction
%   idx_dir = ismember(moves(kk).octant, [8,1,2]);
  
  %control for choice error direction
%   [idx_errdir, idx_corr] = equate_respdir_err_vs_corr(idx_errdir, idx_corr, moves(kk).octant);
  
  %remove any activity related to corrective saccade initiation
%   trial_err = find(idx_cond & idx_err);
%   sdf_kk(idx_fast & idx_err,:) = rem_spikes_post_corrective_SAT(sdf_kk(idx_fast & idx_err,:), movesAll(kk), trial_err);
