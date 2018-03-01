function [ varargout ] = plot_sdf_buildup_activity( spikes , ninfo , moves , binfo )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

TYPE_PLOT = {'V','VM','M'};

T_LIM = [-400,200];
TIME_PLOT = (T_LIM(1):T_LIM(2));

NUM_CELLS = length(spikes);
TIME_ARRAY = 3500;

moves = determine_errors_FEF(moves, binfo);

sdf_Rin = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
sdf_Rin = populate_struct(sdf_Rin, {'acc','fast'}, NaN(6001,1));
sdf_Rout = sdf_Rin;

onset_fr = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
onset_fr = populate_struct(onset_fr, {'acc','fast'}, NaN);

%% Compute the SDF for each direction

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).sesh);
  
  %index by response accuracy
  idx_corr = (~moves(kk_moves).err_direction & ~moves(kk_moves).err_timing);
  
  %index by condition
  idx_fast = (binfo(kk_moves).condition == 3);
  idx_acc = (binfo(kk_moves).condition == 1);
  
  %index by direction of saccade re. movement field
  idx_Rin = ismember(moves(kk_moves).octant, ninfo(kk).move_field);
  
  %% Compute spike density function
  
  sdf_kk = compute_spike_density_fxn(spikes(kk).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, moves(kk_moves).resptime);
  
  sdf_Rin(kk).acc(:) = transpose(nanmean(sdf_kk(idx_Rin & idx_corr & idx_acc,:)));
  sdf_Rin(kk).fast(:) = transpose(nanmean(sdf_kk(idx_Rin & idx_corr & idx_fast,:)));
  
  onset_fr(kk).acc = sdf_Rin(kk).acc(3500); %save FR at onset for comparison
  onset_fr(kk).fast = sdf_Rin(kk).fast(3500);
  
  sdf_Rout(kk).acc(:) = transpose(nanmean(sdf_kk(~idx_Rin & idx_corr & idx_acc,:)));
  sdf_Rout(kk).fast(:) = transpose(nanmean(sdf_kk(~idx_Rin & idx_corr & idx_fast,:)));
  
end%for:cells(kk)

if (nargout > 0)
  varargout{1} = onset_fr;
end

%% Plotting - individual cells

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
%   norm_factor = util_compute_normfactor_buildup(spikes, ninfo, moves, binfo);
  norm_factor = ones(1,NUM_CELLS);
  
  figure(); hold on
  
  plot(TIME_PLOT, sdf_Rout(kk).acc(TIME_PLOT+TIME_ARRAY)/norm_factor(kk), 'r--', 'LineWidth',1.0)
  plot(TIME_PLOT, sdf_Rout(kk).fast(TIME_PLOT+TIME_ARRAY)/norm_factor(kk), '--', 'Color',[0 .7 0], 'LineWidth',1.0)
  
  plot(TIME_PLOT, sdf_Rin(kk).acc(TIME_PLOT+TIME_ARRAY)/norm_factor(kk), 'r-', 'LineWidth',1.5)
  plot(TIME_PLOT, sdf_Rin(kk).fast(TIME_PLOT+TIME_ARRAY)/norm_factor(kk), '-', 'Color',[0 .7 0], 'LineWidth',1.5)
  
  print_session_unit(gca, ninfo(kk), 'type')
  xlim([T_LIM(1)-10, T_LIM(2)+10])
  
  ppretty(); pause(0.25)
  print(['~/Dropbox/tmp/MV-', ninfo(kk).sesh,'-',ninfo(kk).unit,'-',ninfo(kk).type,'.eps'], '-depsc2')
  
end%for:cells(kk)

%% Plotting - across-cell average
norm_factor = util_compute_normfactor_buildup(spikes, ninfo, moves, binfo);

idx_plot = ismember({ninfo.type}, TYPE_PLOT);
NUM_SEM = sum(idx_plot);

sdf_Rin_acc = [sdf_Rin.acc] ./ norm_factor;     sdf_Rin_acc = sdf_Rin_acc(TIME_PLOT+TIME_ARRAY,idx_plot);
sdf_Rout_acc = [sdf_Rout.acc] ./ norm_factor;    sdf_Rout_acc = sdf_Rout_acc(TIME_PLOT+TIME_ARRAY,idx_plot);

sdf_Rin_fast = [sdf_Rin.fast] ./ norm_factor;   sdf_Rin_fast = sdf_Rin_fast(TIME_PLOT+TIME_ARRAY,idx_plot);
sdf_Rout_fast = [sdf_Rout.fast] ./ norm_factor;  sdf_Rout_fast = sdf_Rout_fast(TIME_PLOT+TIME_ARRAY,idx_plot);

figure(); hold on
shaded_error_bar(TIME_PLOT, nanmean(sdf_Rout_acc,2), nanstd(sdf_Rout_acc,0,2)/sqrt(NUM_SEM), {'r--', 'LineWidth',1.25})
shaded_error_bar(TIME_PLOT, nanmean(sdf_Rout_fast,2), nanstd(sdf_Rout_fast,0,2)/sqrt(NUM_SEM), {'--', 'Color',[0 .7 0], 'LineWidth',1.25})
shaded_error_bar(TIME_PLOT, nanmean(sdf_Rin_acc,2), nanstd(sdf_Rin_acc,0,2)/sqrt(NUM_SEM), {'r-', 'LineWidth',1.25})
shaded_error_bar(TIME_PLOT, nanmean(sdf_Rin_fast,2), nanstd(sdf_Rin_fast,0,2)/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
xlim([T_LIM(1)-10, T_LIM(2)+10])

ppretty('image_size',[3.2,2])

%% Plotting - comparison of onset firing rate
[~,pval] = ttest([onset_fr.acc]', [onset_fr.fast]');

idx_move = ismember({ninfo.type}, 'M'); %differentiate M and V-M

figure(); hold on

plot([onset_fr(~idx_move).acc], [onset_fr(~idx_move).fast], 'ko', 'MarkerSize',6)
plot([onset_fr(idx_move).acc], [onset_fr(idx_move).fast], 'kd', 'MarkerSize',6)
% plot([90 440], [90 440], 'k--', 'LineWidth',1.0)

title(['p=',num2str(pval)], 'fontsize',8)
ppretty('image_size',[2.4,2])

end%function:plot_sdf_buildup_activity()
