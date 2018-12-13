function [ A_POSTSACC ] = compute_SDF_from_primary_sacc_SAT( binfo , moves , ninfo , spikes )
%compute_SDF_from_primary_sacc_SAT() Summary of this function goes here
%   Detailed explanation goes here

MIN_NUM_TRIAL = 5;
NUM_CELLS = 1;%length(spikes);

T_POSTSACC  = 3500 + (-600 : 600);
A_POSTSACC = new_struct({'t','FastCorr','FastErrDir','FastErrTime',...
  'AccCorr','AccErrDir','AccErrTime'}, 'dim',[1,NUM_CELLS]);
A_POSTSACC = populate_struct(A_POSTSACC, {'FastCorr','FastErrDir','FastErrTime',...
  'AccCorr','AccErrDir','AccErrTime'}, NaN(8,length(T_POSTSACC)));

RT_AccCorr = NaN(NUM_CELLS,8);
RT_AccErrTime = NaN(NUM_CELLS,8);

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, moves(kk).resptime); 
  
  %index by isolation quality
  idx_iso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  
  %index by condition
  idx_fast = ((binfo(kk).condition == 3) & ~idx_iso);
  idx_acc = ((binfo(kk).condition == 1) & ~idx_iso);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  idx_errtime = (~binfo(kk).err_dir & binfo(kk).err_time);
  
  for dd = 1:8
    
    idx_dd = (moves(kk).octant == dd);
    
    if (sum(idx_fast & idx_corr & idx_dd) >= MIN_NUM_TRIAL)
      A_POSTSACC(cc).FastCorr(dd,:) = nanmean(sdf_kk(idx_fast & idx_corr & idx_dd, T_POSTSACC));
    end
    if (sum(idx_fast & idx_errdir & idx_dd) >= MIN_NUM_TRIAL)
      A_POSTSACC(cc).FastErrDir(dd,:) = nanmean(sdf_kk(idx_fast & idx_errdir & idx_dd, T_POSTSACC));
    end
    if (sum(idx_fast & idx_errtime & idx_dd) >= MIN_NUM_TRIAL)
      A_POSTSACC(cc).FastErrTime(dd,:) = nanmean(sdf_kk(idx_fast & idx_errtime & idx_dd, T_POSTSACC));
    end
    if (sum(idx_acc & idx_corr & idx_dd) >= MIN_NUM_TRIAL)
      RT_AccCorr(cc,dd) = median(moves(kk).resptime(idx_acc & idx_corr & idx_dd));
      A_POSTSACC(cc).AccCorr(dd,:) = nanmean(sdf_kk(idx_acc & idx_corr & idx_dd, T_POSTSACC));
    end
    if (sum(idx_acc & idx_errdir & idx_dd) >= MIN_NUM_TRIAL)
      A_POSTSACC(cc).AccErrDir(dd,:) = nanmean(sdf_kk(idx_acc & idx_errdir & idx_dd, T_POSTSACC));
    end
    if (sum(idx_acc & idx_errtime & idx_dd) >= MIN_NUM_TRIAL)
      RT_AccErrTime(cc,dd) = median(moves(kk).resptime(idx_acc & idx_errtime & idx_dd));
      A_POSTSACC(cc).AccErrTime(dd,:) = nanmean(sdf_kk(idx_acc & idx_errtime & idx_dd, T_POSTSACC));
    end
    
  end
  
  %save time from primary saccade
  A_POSTSACC(cc).t = T_POSTSACC - 3500;
  
end%for:cells(cc)


%% Plotting
LOC_DD_PLOT = [6, 3, 2, 1, 4, 7, 8, 9];

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %equate y-axis limits across all plots for this neuron
  tmp = [A_POSTSACC(cc).AccCorr A_POSTSACC(cc).AccErrTime];
  ylim_cc = [min(min(tmp)) , max(max(tmp))];
  
  figure()
  
  for dd = 1:8
    subplot(3,3,LOC_DD_PLOT(dd)); hold on
    
    plot([0 0], ylim_cc, 'k--')
    plot(-RT_AccErrTime(cc)*ones(1,2), ylim_cc, 'r:', 'LineWidth',0.75)
    plot(-RT_AccCorr(cc)*ones(1,2), ylim_cc, 'r-', 'LineWidth',0.75)
    plot(T_POSTSACC-3500, A_POSTSACC(cc).AccErrTime(dd,:), 'r:', 'LineWidth',1.25);
    plot(T_POSTSACC-3500, A_POSTSACC(cc).AccCorr(dd,:), 'r-', 'LineWidth',0.75);
    
    if (LOC_DD_PLOT(dd) == 4)
      ylabel('Activity (sp/sec)')
    elseif (LOC_DD_PLOT(dd) == 8)
      xlabel('Time from primary response (ms)')
    end
    
    pause(.05)
  end%for:direction(dd)
  
  %plot tuning curve
  subplot(3,3,5); hold on
%   plot([-10 -10], [-5 5], 'k-', 'LineWidth',0.1)
%   plot([0 360], [0 0], 'k--')
%   plot((0 : 45 : 360), Abar_stim(cc,:), 'ko-', 'MarkerSize',3)
%   xlim([-10 370]); xticks(0 : 90 : 360)
  print_session_unit(gca , ninfo(cc), binfo(kk), 'eccen','horizontal')
  
  ppretty('image_size',[9,7])
%   print_fig_SAT(ninfo(cc), gcf, '-dtiff')
%   pause()
  
end%for:cells(cc)

end%fxn:compute_SDF_from_primary_sacc_SAT()

