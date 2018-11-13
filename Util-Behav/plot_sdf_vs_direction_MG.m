function [ ] = plot_sdf_vs_direction_MG( spikes , ninfo , moves , binfo )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

TIME_ARRAY = 3500;
TIME_STIM = linspace(-300, 450, 751);
TIME_RESP = linspace(-450, 300, 751);
NUM_SAMP = length(TIME_RESP);

NUM_DIR = 8;
NUM_CELLS = length(spikes);

LIM_RT = 500;

%% Compute activity for each time period for each direction

sdf_stim = cell(1,NUM_CELLS);
sdf_resp = cell(1,NUM_CELLS);
for kk = 1:NUM_CELLS
  sdf_stim{kk} = NaN(NUM_DIR,NUM_SAMP);
  sdf_resp{kk} = NaN(NUM_DIR,NUM_SAMP);
end

resptime = cell(1,NUM_CELLS);

for kk = 1:NUM_CELLS
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).sesh);
  
  %index by accuracy
  idx_corr = ~((binfo(kk_moves).err_dir) | (binfo(kk_moves).err_time) | (moves(kk_moves).resptime < LIM_RT));
  
  for jj = 1:NUM_DIR
    
    idx_jj = ismember(binfo(kk_moves).tgt_octant, jj);
    
    %RE. STIMULUS
    sdf_jj = compute_spike_density_fxn(spikes(kk).MG(idx_corr & idx_jj));
    sdf_stim{kk}(jj,:) = nanmean(sdf_jj(:,TIME_ARRAY+TIME_STIM));
    
    %RE. RESPONSE
    sdf_resp_jj = align_signal_on_response(sdf_jj, moves(kk_moves).resptime(idx_corr & idx_jj));
    sdf_resp{kk}(jj,:) = nanmean(sdf_resp_jj(:,TIME_ARRAY+TIME_RESP));
    
  end%for:directions(jj)
  
  resptime{kk} = moves(kk_moves).resptime(idx_corr);
  
end%for:cells(kk)

%% Plotting

for kk = 1:NUM_CELLS
  
  figure()
  y_max = 5 + max(max([sdf_stim{kk} ; sdf_resp{kk}]));
  
  %% Sync to stimulus
  subplot(1,3,1); hold on
  plot(TIME_STIM, sdf_stim{kk}, 'k-', 'LineWidth',1.0)
  ylim([0, y_max]); xlim([-300 450]); xticks(-300:100:400); pause(.10)
  print_session_unit(gca, ninfo(kk))
  
  %% Sync to response
  subplot(1,3,2); hold on
  plot(TIME_RESP, sdf_resp{kk}, 'k-', 'LineWidth',1.0)
  ylim([0, y_max]); xlim([-450 300]); xticks(-400:100:300); pause(.10)
  
  %% Show RT distribution across all directions
  subplot(1,3,3); hold on
  histogram(resptime{kk}, 'BinWidth',50, 'FaceColor',[.4 .4 .4])
  
  ppretty('image_size',[12,3])
  print(['~/Dropbox/tmp/',ninfo(kk).sesh,'-',ninfo(kk).unit,'.tif'], '-dtiff')
  pause(0.5); close
  
end%for:cells(kk)

end%function:plot_sdf_vs_dir_SAT()
