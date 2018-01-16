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

binfo = determine_errors_SAT(binfo);

%% Compute the SDF for each direction
sdf_stim = new_struct({'acc','fast'}, 'dim',[NUM_DIR,NUM_CELLS]);
sdf_stim = populate_struct(sdf_stim, {'acc','fast'}, NaN(NUM_SAMP,1));
sdf_resp = sdf_stim;
sdf_rew = sdf_stim;

for kk = 1:NUM_CELLS
  if (ninfo(kk).vis < MIN_VIS); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).sesh);
  
  %index by accuracy
  idx_corr = ~((binfo(kk_moves).err_dir) | (binfo(kk_moves).err_time));
  
  %index by condition
  idx_fast = (binfo(kk_moves).condition == 3) & idx_corr;
  idx_acc = (binfo(kk_moves).condition == 1) & idx_corr;
  
  for jj = 1:NUM_DIR
    idx_jj = ismember(binfo(kk_moves).tgt_octant, jj);
    
    %RE. STIMULUS
    sdf_acc = compute_spike_density_fxn(spikes(kk).SAT(idx_acc & idx_jj));
    sdf_fast = compute_spike_density_fxn(spikes(kk).SAT(idx_fast & idx_jj));
    
    sdf_stim(jj,kk).acc(:) = nanmean(sdf_acc(:,TIME_ARRAY+TIME_STIM))';
    sdf_stim(jj,kk).fast(:) = nanmean(sdf_fast(:,TIME_ARRAY+TIME_STIM))';
    
    %RE. RESPONSE
    sdf_resp_acc = align_signal_on_response(sdf_acc, moves(kk_moves).resptime(idx_acc & idx_jj));
    sdf_resp_fast = align_signal_on_response(sdf_fast, moves(kk_moves).resptime(idx_fast & idx_jj));
    
    sdf_resp(jj,kk).acc(:) = nanmean(sdf_resp_acc(:,TIME_ARRAY+TIME_RESP))';
    sdf_resp(jj,kk).fast(:) = nanmean(sdf_resp_fast(:,TIME_ARRAY+TIME_RESP))';
    
    %RE. REWARD
    sdf_rew_acc = align_signal_on_response(sdf_acc, binfo(kk_moves).rewtime(idx_acc & idx_jj));
    sdf_rew_fast = align_signal_on_response(sdf_fast, binfo(kk_moves).rewtime(idx_fast & idx_jj));
    
    sdf_rew(jj,kk).acc(:) = nanmean(sdf_rew_acc(:,TIME_ARRAY+TIME_REW))';
    sdf_rew(jj,kk).fast(:) = nanmean(sdf_rew_fast(:,TIME_ARRAY+TIME_REW))';
    
  end%for:directions(kk,dd)
  
end%for:cells(kk)

%% Plotting

for kk = 1:NUM_CELLS
  if (ninfo(kk).vis < MIN_VIS); continue; end
  
  %get y-limit
  y_max = 5 + max(max([[sdf_stim(:,kk).fast]; [sdf_resp(:,kk).fast]; [sdf_stim(:,kk).acc]; [sdf_resp(:,kk).acc]; ...
    [sdf_rew(:,kk).acc]; [sdf_rew(:,kk).fast]]));
  
  figure()
  
  %% Sync to stimulus appearance
  subplot(2,3,1); hold on %FAST
  for jj = 1:NUM_DIR
    plot(TIME_STIM, sdf_stim(jj,kk).fast, '-', 'color',[0 .8 0], 'linewidth',1.0);
  end
  ylim([0, y_max]); xlim([-300 300]); xticks(-300:100:300); pause(.10)
  print_session_unit(gca, ninfo(kk))
  
  subplot(2,3,4); hold on %ACCURATE
  for jj = 1:NUM_DIR
    plot(TIME_STIM, sdf_stim(jj,kk).acc, '-', 'color',[1 0 0], 'linewidth',1.0);
  end
  ylim([0, y_max]); xlim([-300 300]); xticks(-300:100:300); pause(.10)
  print_session_unit(gca, ninfo(kk))
  
  %% Sync to response
  subplot(2,3,2); hold on %FAST
  for jj = 1:NUM_DIR
    plot(TIME_RESP, sdf_resp(jj,kk).fast, '-', 'color',[0 .8 0], 'linewidth',1.0);
  end
  ylim([0, y_max]); xlim([-300 300]); xticks(-300:100:300); pause(.10)
  
  subplot(2,3,5); hold on %ACCURATE
  for jj = 1:NUM_DIR
    plot(TIME_RESP, sdf_resp(jj,kk).acc, '-', 'color',[1 0 0], 'linewidth',1.0);
  end
  ylim([0, y_max]); xlim([-300 300]); xticks(-300:100:300); pause(.10)
  
  %% Sync to reward
  subplot(2,3,3); hold on %FAST
  for jj = 1:NUM_DIR
    plot(TIME_RESP, sdf_rew(jj,kk).fast, '-', 'color',[0 .8 0], 'linewidth',1.0);
  end
  ylim([0, y_max]); xlim([-300 300]); xticks(-300:100:300); pause(.10)
  
  subplot(2,3,6); hold on %ACCURATE
  for jj = 1:NUM_DIR
    plot(TIME_RESP, sdf_rew(jj,kk).acc, '-', 'color',[1 0 0], 'linewidth',1.0);
  end
  ylim([0, y_max]); xlim([-300 300]); xticks(-300:100:300); pause(.10)
  
  ppretty('image_size',[10,6.4])
%   print(['~/Dropbox/tmp/',ninfo(kk).sesh,'-',ninfo(kk).unit,'.tif'], '-dtiff')
  pause(1.0); %close
  
end%for:cells(kk)

end%function:plot_sdf_vs_dir_SAT()
