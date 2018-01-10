function [ ] = plot_sdf_visresp_correct( spikes , ninfo , binfo )
%[ ] = plot_sdf_visual_response( varargin )
%   Detailed explanation goes here

NUM_CELLS = length(spikes);
MIN_VIS = 3; %minimum grade for VIS cells

TIME_ARRAY = 3500;
TIME_STIM = linspace(-100, 300, 401);

binfo = determine_errors_SAT(binfo);

%% Compute the SDF for each direction
sdf_stim = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
sdf_stim = populate_struct(sdf_stim, {'acc','fast'}, NaN(length(TIME_STIM),1));

for kk = 1:NUM_CELLS
  if (ninfo(kk).vis < MIN_VIS); continue; end
  
  %get session number corresponding to behavioral data
  kk_binfo = ismember({binfo.session}, ninfo(kk).sesh);
  
  %% Compute SDF
  
  idx_corr = ~((binfo(kk_binfo).err_dir) | (binfo(kk_binfo).err_time));
  
  idx_fast = (binfo(kk_binfo).condition == 3) & idx_corr;
  idx_acc = (binfo(kk_binfo).condition == 1) & idx_corr;
  
  sdf_acc = compute_spike_density_fxn(spikes(kk).SAT(idx_acc));
  sdf_fast = compute_spike_density_fxn(spikes(kk).SAT(idx_fast));
  
  sdf_stim(kk).acc(:) = nanmean(sdf_acc(:,TIME_ARRAY+TIME_STIM))';
  sdf_stim(kk).fast(:) = nanmean(sdf_fast(:,TIME_ARRAY+TIME_STIM))';
  
  %% Plot
  
  figure(); hold on
  
  plot(TIME_STIM, sdf_stim(kk).fast, '-', 'color',[0 .7 0], 'linewidth',1.25);
  plot(TIME_STIM, sdf_stim(kk).acc, '-', 'color',[1 0 0], 'linewidth',1.25);
  
  xlim([-100 300]); xticks(-100:100:300); pause(.10)
  print_session_unit(gca, ninfo(kk))
  
  ppretty('image_size',[1.6,2])
  print(['~/Dropbox/tmp/',ninfo(kk).sesh,'-',ninfo(kk).unit,'.tif'], '-dtiff')
  pause(.05)
  
end%for:cells(kk)

end%function:plot_sdf_visresp_correct()
