function [ ] = plot_sdf_vs_direction_SAT( spikes , ninfo , moves , binfo )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

MIN_VIS = 3; %minimum grade for VIS cells

TIME_ARRAY = 3500;
TIME_STIM = linspace(-300, 300, 601);
TIME_RESP = linspace(-300, 300, 601);
TIME_REW = linspace(-300, 300, 601);
NUM_SAMP = length(TIME_RESP);

NUM_DIR = 8;
NUM_CELLS = length(spikes);

% binfo = determine_errors_SAT(binfo);

%% Compute the SDF for each direction
sdf_stim = new_struct({'acc','fast'}, 'dim',[NUM_DIR,NUM_CELLS]);
sdf_stim = populate_struct(sdf_stim, {'acc','fast'}, NaN(NUM_SAMP,1));
sdf_resp = sdf_stim;
sdf_rew = sdf_stim;

for cc = 30:30%1:NUM_CELLS
%   if (ninfo(kk).vis < MIN_VIS); continue; end
  
  %get session number corresponding to behavioral data
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by trial number
  idx_trial = true(1,binfo(kk).num_trials);
%   idx_trial(701:end) = false;
  idx_trial(1:350) = false;
%   idx_trial(1776:end) = false;
  
  %index by accuracy
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  
  %index by condition
%   idx_fast = (binfo(kk).condition == 3) & idx_corr;
%   idx_acc = (binfo(kk).condition == 1) & idx_corr;
  idx_fast = (binfo(kk).condition == 3) & idx_corr & idx_trial;
  idx_acc = (binfo(kk).condition == 1) & idx_corr & idx_trial;
  
  for jj = 1:NUM_DIR
    idx_jj = ismember(binfo(kk).tgt_octant, jj);
    
    %RE. STIMULUS
    sdf_acc = compute_spike_density_fxn(spikes(cc).SAT(idx_acc & idx_jj));
    sdf_fast = compute_spike_density_fxn(spikes(cc).SAT(idx_fast & idx_jj));
    
    sdf_stim(jj,cc).acc(:) = nanmean(sdf_acc(:,TIME_ARRAY+TIME_STIM))';
    sdf_stim(jj,cc).fast(:) = nanmean(sdf_fast(:,TIME_ARRAY+TIME_STIM))';
    
    %RE. RESPONSE
    sdf_resp_acc = align_signal_on_response(sdf_acc, moves(kk).resptime(idx_acc & idx_jj));
    sdf_resp_fast = align_signal_on_response(sdf_fast, moves(kk).resptime(idx_fast & idx_jj));
    
    sdf_resp(jj,cc).acc(:) = nanmean(sdf_resp_acc(:,TIME_ARRAY+TIME_RESP))';
    sdf_resp(jj,cc).fast(:) = nanmean(sdf_resp_fast(:,TIME_ARRAY+TIME_RESP))';
    
    %RE. REWARD
    sdf_rew_acc = align_signal_on_response(sdf_acc, binfo(kk).rewtime(idx_acc & idx_jj));
    sdf_rew_fast = align_signal_on_response(sdf_fast, binfo(kk).rewtime(idx_fast & idx_jj));
    
    sdf_rew(jj,cc).acc(:) = nanmean(sdf_rew_acc(:,TIME_ARRAY+TIME_REW))';
    sdf_rew(jj,cc).fast(:) = nanmean(sdf_rew_fast(:,TIME_ARRAY+TIME_REW))';
    
  end%for:directions(kk,dd)
  
end%for:cells(cc)

%% Plotting

for cc = 30:30%1:NUM_CELLS
%   if (ninfo(kk).vis < MIN_VIS); continue; end
  
  %get y-limit
  y_max = 5 + max(max([[sdf_stim(:,cc).fast]; [sdf_resp(:,cc).fast]; [sdf_stim(:,cc).acc]; [sdf_resp(:,cc).acc]; ...
    [sdf_rew(:,cc).acc]; [sdf_rew(:,cc).fast]]));
  
  figure()
  
  %% Sync to stimulus appearance
  subplot(2,3,1); hold on %FAST
  for jj = 1:NUM_DIR
    plot(TIME_STIM, sdf_stim(jj,cc).fast, '-', 'color',[0 .8 0], 'linewidth',1.0);
  end
  ylim([0, y_max]); xlim([-300 300]); xticks(-300:100:300); pause(.10)
  ylabel('Activity (sp/sec)')
  print_session_unit(gca, ninfo(cc))
  
  subplot(2,3,4); hold on %ACCURATE
  for jj = 1:NUM_DIR
    plot(TIME_STIM, sdf_stim(jj,cc).acc, '-', 'color',[1 0 0], 'linewidth',1.0);
  end
  ylim([0, y_max]); xlim([-300 300]); xticks(-300:100:300); pause(.10)
  xlabel('Time re. stimulus (ms)')
  ylabel('Activity (sp/sec)')
  print_session_unit(gca, ninfo(cc))
  
  %% Sync to response
  subplot(2,3,2); hold on %FAST
  for jj = 1:NUM_DIR
    plot(TIME_RESP, sdf_resp(jj,cc).fast, '-', 'color',[0 .8 0], 'linewidth',1.0);
  end
  ylim([0, y_max]); xlim([-300 300]); xticks(-300:100:300); pause(.10)
  
  subplot(2,3,5); hold on %ACCURATE
  for jj = 1:NUM_DIR
    plot(TIME_RESP, sdf_resp(jj,cc).acc, '-', 'color',[1 0 0], 'linewidth',1.0);
  end
  ylim([0, y_max]); xlim([-300 300]); xticks(-300:100:300); pause(.10)
  xlabel('Time re. saccade (ms)')
  
  %% Sync to reward
  subplot(2,3,3); hold on %FAST
  for jj = 1:NUM_DIR
    plot(TIME_RESP, sdf_rew(jj,cc).fast, '-', 'color',[0 .8 0], 'linewidth',1.0);
  end
  ylim([0, y_max]); xlim([-300 300]); xticks(-300:100:300); pause(.10)
  
  subplot(2,3,6); hold on %ACCURATE
  for jj = 1:NUM_DIR
    plot(TIME_RESP, sdf_rew(jj,cc).acc, '-', 'color',[1 0 0], 'linewidth',1.0);
  end
  ylim([0, y_max]); xlim([-300 300]); xticks(-300:100:300); pause(.10)
  xlabel('Time re. reward (ms)')
  
  ppretty('image_size',[10,6.4])
%   print(['~/Dropbox/tmp/',ninfo(kk).sess,'-',ninfo(kk).unit,'.tif'], '-dtiff')
  pause(1.0); %close
  
end%for:cells(cc)

end%function:plot_sdf_vs_dir_SAT()
