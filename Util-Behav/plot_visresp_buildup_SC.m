function [  ] = plot_visresp_buildup_SC( spikes , ninfo , moves , binfo )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

TIME_VISRESP = (0 : 500);
TIME_BUILDUP = (-400 : 100);

NUM_CELLS = length(spikes);
TIME_ARRAY = 3500;

moves = determine_errors_FEF(moves, binfo);

visresp_Rin = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
visresp_Rin = populate_struct(visresp_Rin, {'acc','fast'}, NaN(6001,1));

visresp_Rout = visresp_Rin;
buildup_Rin = visresp_Rin;
buildup_Rout = visresp_Rin;

%% Compute the SDF for each direction

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, {'V','VM','M'}); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).sesh);
  
  %index by response accuracy
  idx_corr = ~(moves(kk_moves).err_direction | moves(kk_moves).err_timing);
  
  %index by condition
  idx_fast = (binfo(kk_moves).condition == 3);
  idx_acc = (binfo(kk_moves).condition == 1);
  
  %index by direction of target/saccade re. movement field
  idx_Rin = ismember(moves(kk_moves).octant, [ninfo(kk).resp_field, ninfo(kk).move_field]);
  
  %% Compute spike density function
  
  sdf_kk = compute_spike_density_fxn(spikes(kk).SAT);
  
  visresp_Rin(kk).acc(:) = transpose(nanmean(sdf_kk(idx_Rin & idx_corr & idx_acc,:)));
  visresp_Rin(kk).fast(:) = transpose(nanmean(sdf_kk(idx_Rin & idx_corr & idx_fast,:)));
  
  visresp_Rout(kk).acc(:) = transpose(nanmean(sdf_kk(~idx_Rin & idx_corr & idx_acc,:)));
  visresp_Rout(kk).fast(:) = transpose(nanmean(sdf_kk(~idx_Rin & idx_corr & idx_fast,:)));
  
  sdf_kk = align_signal_on_response(sdf_kk, moves(kk_moves).resptime);
  
  buildup_Rin(kk).acc(:) = transpose(nanmean(sdf_kk(idx_Rin & idx_corr & idx_acc,:)));
  buildup_Rin(kk).fast(:) = transpose(nanmean(sdf_kk(idx_Rin & idx_corr & idx_fast,:)));
  
  buildup_Rout(kk).acc(:) = transpose(nanmean(sdf_kk(~idx_Rin & idx_corr & idx_acc,:)));
  buildup_Rout(kk).fast(:) = transpose(nanmean(sdf_kk(~idx_Rin & idx_corr & idx_fast,:)));
  
end%for:cells(kk)

%% Plotting - individual cells

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, {'V','VM','M'}); continue; end
  
  ymax = max([visresp_Rin(kk).acc; visresp_Rin(kk).fast; buildup_Rin(kk).acc; buildup_Rin(kk).fast]);
  
  figure()
  
  subplot(1,2,1); hold on % VISUAL RESPONSE
  
  plot(TIME_VISRESP, visresp_Rout(kk).acc(TIME_VISRESP+TIME_ARRAY), 'r--', 'LineWidth',1.0)
  plot(TIME_VISRESP, visresp_Rout(kk).fast(TIME_VISRESP+TIME_ARRAY), '--', 'Color',[0 .7 0], 'LineWidth',1.0)
  
  plot(TIME_VISRESP, visresp_Rin(kk).acc(TIME_VISRESP+TIME_ARRAY), 'r-', 'LineWidth',1.5)
  plot(TIME_VISRESP, visresp_Rin(kk).fast(TIME_VISRESP+TIME_ARRAY), '-', 'Color',[0 .7 0], 'LineWidth',1.5)
  
  print_session_unit(gca, ninfo(kk), 'type')
  
  xlim([TIME_VISRESP(1)-20, TIME_VISRESP(end)+20])
  ylim([0 50*ceil(ymax/50)])
  
  subplot(1,2,2); hold on % BUILDUP ACTIVITY
  
  plot(TIME_BUILDUP, buildup_Rout(kk).acc(TIME_BUILDUP+TIME_ARRAY), 'r--', 'LineWidth',1.0)
  plot(TIME_BUILDUP, buildup_Rout(kk).fast(TIME_BUILDUP+TIME_ARRAY), '--', 'Color',[0 .7 0], 'LineWidth',1.0)
  
  plot(TIME_BUILDUP, buildup_Rin(kk).acc(TIME_BUILDUP+TIME_ARRAY), 'r-', 'LineWidth',1.5)
  plot(TIME_BUILDUP, buildup_Rin(kk).fast(TIME_BUILDUP+TIME_ARRAY), '-', 'Color',[0 .7 0], 'LineWidth',1.5)
  
  xlim([TIME_BUILDUP(1)-20, TIME_BUILDUP(end)+20])
  ylim([0 50*ceil(ymax/50)]); yticks([])
  
  ppretty('image_size',[7.0,1.5]); pause(0.25)
  print(['~/Dropbox/tmp/', ninfo(kk).sesh,'-',ninfo(kk).unit,'-',ninfo(kk).type,'.eps'], '-depsc2')
  
end%for:cells(kk)

end%function:plot_sdf_buildup_activity()
