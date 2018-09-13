function [  ] = plot_peakvel_vs_avgFR( spikes , ninfo , moves , binfo )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

TIME_SURVEY = (0:30); %time re. movement initiation
TIME_ARRAY = 3500;

NUM_CELLS = length(ninfo);

moves = determine_errors_FEF(moves, binfo);

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, {'M','VM'}); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).sesh);

  %index by response accuracy
%   idx_err = moves(kk_moves).err_direction;
  
  %index by direction of response re. RF
  idx_mf = ismember(moves(kk_moves).octant, ninfo(kk).move_field);

  %index by condition
  idx_acc = (binfo(kk_moves).condition == 1);
  idx_fast = (binfo(kk_moves).condition == 3);
  
  %index by clipping
  idx_tr = ~isnan(moves(kk_moves).peakvel);
  
  %combine indexes
  idx_acc = (idx_mf & idx_tr & idx_acc);
  idx_fast = (idx_mf & idx_tr & idx_fast);
  
  %check trial counts
  if (sum(idx_acc) < 10) || (sum(idx_fast) < 10)
    continue
  end
  
  %% Compute velocity / vigor
  
  pv_acc = moves(kk_moves).peakvel(idx_acc);
  pv_fast = moves(kk_moves).peakvel(idx_fast);
  
  %% Compute spike density function
  sdf_kk = compute_spike_density_fxn(spikes(kk).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, moves(kk_moves).resptime);
  
  sdf_acc = sdf_kk(idx_acc,:);
  sdf_fast = sdf_kk(idx_fast,:);
  
  fr_acc = mean(sdf_acc(:,TIME_ARRAY+TIME_SURVEY),2);
  fr_fast = mean(sdf_fast(:,TIME_ARRAY+TIME_SURVEY),2);
  
  %% Statistics
  
  [R_acc,p_acc] = corrcoef(fr_acc, pv_acc);
  [R_fast,p_fast] = corrcoef(fr_fast, pv_fast);
  
  R_acc = num2str(round(R_acc(1,2)*100)/100);
  R_fast = num2str(round(R_fast(1,2)*100)/100);
  
  p_acc = num2str(round(p_acc(1,2)*1000)/1000);
  p_fast = num2str(round(p_fast(1,2)*1000)/1000);
  
  fit_acc = fit(fr_acc, pv_acc', 'poly1');
  fit_fast = fit(fr_fast, pv_fast', 'poly1');
  
  %% Plotting
  
  figure; hold on
  
  plot(fr_acc, pv_acc, 'ro', 'MarkerSize',5)
  plot(fr_fast, pv_fast, 'o', 'Color',[0 .7 0], 'MarkerSize',5)
  
  xL = min(fr_acc);
  xH = max(fr_fast);
  
  plot([xL xH], fit_acc([xL xH]), 'r-', 'LineWidth',1.25)
  plot([xL xH], fit_fast([xL xH]), '-', 'Color',[0 .7 0], 'LineWidth',1.25)
  
  title({['\color{red}R=',R_acc,' p=',p_acc] ; ['\color{green}R=',R_fast,' p=',p_fast]}, 'fontsize',8)
  print_session_unit(gca, ninfo(kk), 'type')
  
  ppretty(); %print(['~/Dropbox/tmp/', ninfo(kk).session,'-',ninfo(kk).unit,'.tif'], '-dtiff')
%   pause(1.5)
  
end%for:cells(kk)

end%function:plot_peakvel_vs_maxfr
