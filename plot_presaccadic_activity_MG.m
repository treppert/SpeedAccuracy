function [ ] = plot_presaccadic_activity_MG( spikes , ninfo , binfo , moves )
%plot_presaccadic_activity_MG Summary of this function goes here
%   Detailed explanation goes here

T_BASE = (-700 : 0);
T_STIM = (-200 : 400);  T_STAT_STIM = (50 : 150);  IDX_STAT_STIM = ismember(T_STIM, T_STAT_STIM);
T_RESP = (-300 : 300);  T_STAT_RESP = (-100 : 0);  IDX_STAT_RESP = ismember(T_RESP, T_STAT_RESP);
N_SAMP = length(T_RESP);

NUM_CELLS = length(spikes);

%initialize output
A_base = NaN(1,NUM_CELLS);
A_stim = cell(1,NUM_CELLS);
A_resp = cell(1,NUM_CELLS);
for cc = 1:NUM_CELLS
  A_stim{cc} = NaN(8,N_SAMP);
  A_resp{cc} = NaN(8,N_SAMP);
end

Abar_stim = NaN(NUM_CELLS,8); %mean statistic for visual response to stimulus
Abar_resp = NaN(NUM_CELLS,8); %mean statistic for saccade

%% Compute SDF re. stimulus appearance and re. saccade initiation

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %only assess trials with correct responses
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_hold | binfo(kk).err_nosacc);
  
  %compute mean baseline activity
  a_base = compute_spike_density_fxn(spikes(cc).MG(idx_corr));
  A_base(cc) = mean(nanmean(a_base(:,3500+T_BASE)));
  
  for dd = 1:8
    
    idx_dd = (binfo(kk).tgt_octant == dd);
    
    %compute activity re. stimulus
    a_stim_dd = compute_spike_density_fxn(spikes(cc).MG(idx_dd & idx_corr));
    A_stim{cc}(dd,:) = nanmean(a_stim_dd(:,3500+T_STIM));
    
    %compute mean stat re. stimulus
    Abar_stim(cc,dd) = mean(A_stim{cc}(dd,IDX_STAT_STIM));
    
    %compute activity re. response
    a_resp_dd = align_signal_on_response(a_stim_dd, moves(kk).resptime(idx_dd & idx_corr)); 
    A_resp{cc}(dd,:) = nanmean(a_resp_dd(:,3500+T_RESP));
    
    %compute mean stat re. response
    Abar_resp(cc,dd) = mean(A_resp{cc}(dd,IDX_STAT_RESP));
    
  end%for:directions(dd)
  
end%for:cells(cc)

Abar_stim = Abar_stim - repmat(A_base', 1,8); %subtract baseline activity from stats
Abar_resp = Abar_resp - repmat(A_base', 1,8);
Abar_stim = [Abar_stim, Abar_stim(:,1)]; %complete the circle
Abar_resp = [Abar_resp, Abar_resp(:,1)];

%% Plotting

LOC_DD_PLOT = [6, 3, 2, 1, 4, 7, 8, 9];

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %equate y-axis limits across all plots for this neuron
  ylim_cc = [min(min([A_stim{cc} A_resp{cc}])) , max(max([A_stim{cc} A_resp{cc}]))];
  
  figure() %plot re. stimulus appearance
  
  for dd = 1:8
    subplot(3,3,LOC_DD_PLOT(dd)); hold on
    
    plot([0 0], ylim_cc, 'k--')
    plot([T_STIM(1) T_STIM(end)], [A_base(cc) A_base(cc)], 'k--')
    plot(T_STAT_STIM(1)*ones(1,2), ylim_cc, 'k:')
    plot(T_STAT_STIM(end)*ones(1,2), ylim_cc, 'k:')
    plot(T_STIM, A_stim{cc}(dd,:), 'k-', 'LineWidth',1.25);
    
    if (LOC_DD_PLOT(dd) == 4)
      ylabel('Activity (sp/sec)')
    elseif (LOC_DD_PLOT(dd) == 8)
      xlabel('Time from stimulus (ms)')
    end
    
    pause(.05)
  end%for:direction(dd)
  
  %plot tuning curve of visual response magnitude
  subplot(3,3,5); hold on
  plot([-10 -10], [-5 5], 'k-', 'LineWidth',0.1)
  plot([0 360], [0 0], 'k--')
  plot((0 : 45 : 360), Abar_stim(cc,:), 'ko-', 'MarkerSize',3)
  xlim([-10 370]); xticks(0 : 90 : 360)
  print_session_unit(gca , ninfo(cc), binfo(kk), 'eccen','horizontal')
  
  ppretty('image_size',[9,7])
  print_fig_SAT(ninfo(cc), gcf, '-dtiff')
  pause(0.25)
  
  figure() %plot re. response initiation
  
  for dd = 1:8
    subplot(3,3,LOC_DD_PLOT(dd)); hold on
    
    plot([0 0], ylim_cc, 'k--')
    plot([T_RESP(1) T_RESP(end)], [A_base(cc) A_base(cc)], 'k--')
    plot(T_STAT_RESP(1)*ones(1,2), ylim_cc, 'k:')
    plot(T_STAT_RESP(end)*ones(1,2), ylim_cc, 'k:')
    plot(T_RESP, A_resp{cc}(dd,:), 'k-', 'LineWidth',1.25);
    xlim([T_RESP(1) T_RESP(end)])
    
    if (LOC_DD_PLOT(dd) == 4)
      ylabel('Activity (sp/sec)')
    elseif (LOC_DD_PLOT(dd) == 8)
      xlabel('Time from response (ms)')
    end
    
    pause(.05)
  end%for:direction(dd)
  
  %plot tuning curve of visual response magnitude
  subplot(3,3,5); hold on
  plot([-10 -10], [-5 5], 'k-', 'LineWidth',0.1)
  plot([0 360], [0 0], 'k--')
  plot((0 : 45 : 360), Abar_resp(cc,:), 'ko-', 'MarkerSize',3)
  xlim([-10 370]); xticks(0 : 90 : 360)
  print_session_unit(gca , ninfo(cc), binfo(kk), 'eccen','horizontal')
  
  ppretty('image_size',[9,7])
  print_fig_SAT(ninfo(cc), gcf, '-dtiff')
  pause(0.25)
  
end%for:cells(cc)

end%function:plot_presaccadic_activity_MG()
