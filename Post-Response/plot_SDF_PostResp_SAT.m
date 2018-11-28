function [  ] = plot_SDF_PostResp_SAT( binfo , moves , movesPP , ninfo , spikes )
%plot_SDF_PostResp_SAT() Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);
MIN_NUM_TRIALS_FAST = 10;
MIN_NUM_TRIALS_ACC = 5;

TIME_RESP = 3500 + (-300 : 150);
TIME_PP_RESP = 3500 + (-150 : 300);
NUM_SAMP = length(TIME_RESP);

AErr_PP2T_Resp_F = NaN(NUM_CELLS,NUM_SAMP); %activity from primary response
AErr_PP2D_Resp_F = NaN(NUM_CELLS,NUM_SAMP);
AErr_PP2T_Resp_A = NaN(NUM_CELLS,NUM_SAMP);
AErr_PP2D_Resp_A = NaN(NUM_CELLS,NUM_SAMP);
AErr_PP2T_PPResp_F = NaN(NUM_CELLS,NUM_SAMP); %activity from post-primary response
AErr_PP2D_PPResp_F = NaN(NUM_CELLS,NUM_SAMP);
AErr_PP2T_PPResp_A = NaN(NUM_CELLS,NUM_SAMP);
AErr_PP2D_PPResp_A = NaN(NUM_CELLS,NUM_SAMP);

ccNoPlot = false(1,NUM_CELLS); %flag cells on sessions with too few trials

for cc = 1:NUM_CELLS
  if ~ismember(cc, [24,45]); continue; end
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by isolation quality, task condition, and trial outcome
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  idxErrChc = (binfo(kk).err_dir & ~binfo(kk).err_time);
  idxFast = ((binfo(kk).condition == 3) & idxErrChc & ~idxIso);
  idxAcc = ((binfo(kk).condition == 1) & idxErrChc & ~idxIso);
  
  %index by post-primary saccade endpoint
  idx_PP2T = (movesPP(kk).endpt == 1);
  idx_PP2D = (movesPP(kk).endpt == 2);
  
  %make sure we have enough trials for the analysis
  if ((sum(idxAcc & idx_PP2D) < MIN_NUM_TRIALS_ACC) || (sum(idxFast & idx_PP2D) < MIN_NUM_TRIALS_FAST))
    ccNoPlot(cc) = true;
    continue
  end
  
  %compute SDFs from primary response and post-primary response
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_Resp = align_signal_on_response(sdf_kk, moves(kk).resptime);
  sdf_PPResp = align_signal_on_response(sdf_kk, movesPP(kk).resptime);
  
  %save activity from primary response
  AErr_PP2T_Resp_F(cc,:) = nanmean(sdf_Resp(idxFast & idx_PP2T, TIME_RESP));
  AErr_PP2D_Resp_F(cc,:) = nanmean(sdf_Resp(idxFast & idx_PP2D, TIME_RESP));
  AErr_PP2T_Resp_A(cc,:) = nanmean(sdf_Resp(idxAcc & idx_PP2T, TIME_RESP));
  AErr_PP2D_Resp_A(cc,:) = nanmean(sdf_Resp(idxAcc & idx_PP2D, TIME_RESP));
  
  %save activity from post-primary response
  AErr_PP2T_PPResp_F(cc,:) = nanmean(sdf_PPResp(idxFast & idx_PP2T, TIME_PP_RESP));
  AErr_PP2D_PPResp_F(cc,:) = nanmean(sdf_PPResp(idxFast & idx_PP2D, TIME_PP_RESP));
  AErr_PP2T_PPResp_A(cc,:) = nanmean(sdf_PPResp(idxAcc & idx_PP2T, TIME_PP_RESP));
  AErr_PP2D_PPResp_A(cc,:) = nanmean(sdf_PPResp(idxAcc & idx_PP2D, TIME_PP_RESP));
  
end%for:cells(cc)


%% Plotting

for cc = 1:NUM_CELLS
  if (ccNoPlot(cc)); continue; end
  if ~ismember(cc, [24,45]); continue; end
  
  tmpF = [AErr_PP2T_Resp_F(cc,:) AErr_PP2D_Resp_F(cc,:) AErr_PP2T_PPResp_F(cc,:) AErr_PP2D_PPResp_F(cc,:)];
  tmpA = [AErr_PP2T_Resp_A(cc,:) AErr_PP2D_Resp_A(cc,:) AErr_PP2T_PPResp_A(cc,:) AErr_PP2D_PPResp_A(cc,:)];
  limLin = quantile([tmpA tmpF], [0,1]);
  
  figure()
  
  subplot(2,2,1); hold on %FAST -- PRIMARY
  plot([0 0], limLin, 'k--', 'LineWidth',1.0)
  
  plot(TIME_RESP-3500, AErr_PP2T_Resp_F(cc,:), '--', 'Color',[0 .7 0], 'LineWidth',2.0)
  plot(TIME_RESP-3500, AErr_PP2D_Resp_F(cc,:), '--', 'Color',[0 0 0], 'LineWidth',1.0)
  
  print_session_unit(gca, ninfo(cc), 'horizontal')
  ylabel('Activity (sp/sec)')
  xlim([-300 150]); xticklabels([])
  
  subplot(2,2,2); hold on %FAST -- POST-PRIMARY
  plot([0 0], limLin, 'k--', 'LineWidth',1.0)
  
  plot(TIME_PP_RESP-3500, AErr_PP2T_PPResp_F(cc,:), '--', 'Color',[0 .7 0], 'LineWidth',2.0)
  plot(TIME_PP_RESP-3500, AErr_PP2D_PPResp_F(cc,:), '--', 'Color',[0 0 0], 'LineWidth',1.0)
  
  yticklabels([])
  xlim([-150 300]); xticklabels([])
  
  subplot(2,2,3); hold on %ACC -- PRIMARY
  plot([0 0], limLin, 'k--', 'LineWidth',1.0)
  
  plot(TIME_RESP-3500, AErr_PP2T_Resp_A(cc,:), '--', 'Color','r', 'LineWidth',2.0)
  plot(TIME_RESP-3500, AErr_PP2D_Resp_A(cc,:), '--', 'Color',[0 0 0], 'LineWidth',1.0)
  
  xlim([-300 150]); xlabel('Time from primary saccade (ms)')
  ylabel('Activity (sp/sec)')
  
  subplot(2,2,4); hold on %ACC -- POST-PRIMARY
  plot([0 0], limLin, 'k--', 'LineWidth',1.0)
  
  plot(TIME_PP_RESP-3500, AErr_PP2T_PPResp_A(cc,:), '--', 'Color','r', 'LineWidth',2.0)
  plot(TIME_PP_RESP-3500, AErr_PP2D_PPResp_A(cc,:), '--', 'Color',[0 0 0], 'LineWidth',1.0)
  
  xlim([-150 300]); xlabel('Time from post-primary saccade (ms)')
  yticklabels([])
  
  ppretty('image_size',[9,7])
%   pause()
  pause(0.10)
  print_fig_SAT(ninfo(cc), gcf, '-depsc2')
  pause(0.10)
  close()
  
end%for:cells(cc)

end%fxn:plot_SDF_PostResp_SAT()
