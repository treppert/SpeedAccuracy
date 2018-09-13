function [ ] = plot_sdf_visual_response_graded( spikes , ninfo , moves , binfo )
%[ ] = plot_sdf_visual_response( varargin )
%   Detailed explanation goes here

TYPE_PLOT = {'V','VM'};

T_LIM = [0,250];
TIME_PLOT = (T_LIM(1):T_LIM(2));

NUM_DIR = 8;
NUM_CELLS = length(spikes);
TIME_ARRAY = 3500;

moves = determine_errors_SAT(moves, binfo);
norm_factor = util_compute_normfactor_visresp(spikes, ninfo, binfo);

sdf_x_dir = new_struct({'acc','fast','all'}, 'dim',[NUM_DIR,NUM_CELLS]);

%% Compute the SDF for each direction

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).session);
  
  %index by task-relevant movement and by accuracy
  idx_tr = moves(kk_moves).taskrel & ~moves(kk_moves).err_direction;
  
  %index by condition
  idx_fast = (binfo(kk_moves).condition == 3);
  idx_acc = (binfo(kk_moves).condition == 1);
  
  %get lead time for removing movement-related activity (via cell type)
  if strcmp(ninfo(kk).type, 'V')
    lead_time = -50;
  elseif strcmp(ninfo(kk).type, 'VM')
    lead_time = -50;
  end
  
  for jj = 1:NUM_DIR
    
    idx_dd = ismember(binfo(kk_moves).tgt_octant, jj);
    
    sdf_acc = compute_spike_density_fxn(spikes(kk).SAT(idx_acc & idx_dd & idx_tr));
    sdf_fast = compute_spike_density_fxn(spikes(kk).SAT(idx_fast & idx_dd & idx_tr));
    sdf_all = compute_spike_density_fxn(spikes(kk).SAT((idx_acc|idx_fast) & idx_dd & idx_tr));
    
    sdf_acc = remove_spikes_post_response(sdf_acc, moves(kk_moves).resptime(idx_acc & idx_dd & idx_tr), lead_time);
    sdf_fast = remove_spikes_post_response(sdf_fast, moves(kk_moves).resptime(idx_fast & idx_dd & idx_tr), lead_time);
    sdf_all = remove_spikes_post_response(sdf_all, moves(kk_moves).resptime((idx_acc|idx_fast) & idx_dd & idx_tr), lead_time);
    
    sdf_x_dir(jj,kk).acc = nanmean(sdf_acc)';
    sdf_x_dir(jj,kk).fast = nanmean(sdf_fast)';
    sdf_x_dir(jj,kk).all = nanmean(sdf_all)';
    
  end%for:directions(jj)
  
end%for:cells(kk)

%% Normalize the visual response activity

sdf_in = new_struct({'acc','fast','all'}, 'dim',[1,NUM_CELLS]);
sdf_out = new_struct({'acc','fast','all'}, 'dim',[4,NUM_CELLS]); %4 degrees of separation from RF

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
  
  jj_RF = ninfo(kk).resp_field;
  
  %compute single SDF for inMF
  sdf_in(kk).acc = mean([sdf_x_dir(jj_RF,kk).acc], 2) / norm_factor(kk);
  sdf_in(kk).fast = mean([sdf_x_dir(jj_RF,kk).fast], 2) / norm_factor(kk);
  sdf_in(kk).all = mean([sdf_x_dir(jj_RF,kk).all], 2) / norm_factor(kk);

  %compute multiple SDFs for outMF
  for jj = 1:4
    if ( (length(jj_RF) ~= 1) && (jj==4) ); continue; end
      
    jj_flank = unique([util_circshift_dir(max(jj_RF),jj) , util_circshift_dir(min(jj_RF),-jj)]);
    sdf_out(jj,kk).acc = mean([sdf_x_dir(jj_flank,kk).acc], 2) / norm_factor(kk);
    sdf_out(jj,kk).fast = mean([sdf_x_dir(jj_flank,kk).fast], 2) / norm_factor(kk);
    sdf_out(jj,kk).all = mean([sdf_x_dir(jj_flank,kk).all], 2) / norm_factor(kk);
    
  end%for:directions(jj)
  
end%for:cells(kk)

%% Plotting
COLOR_GRAD = [.2 .4 .6 .8]; %color gradient for SDF outside RF

sdf_in_acc = [sdf_in.acc]';
sdf_in_fast = [sdf_in.fast]';
sdf_in_all = [sdf_in.all]';

sdf_out_acc = cell(1,4); %4 degrees of separation from RF
sdf_out_fast = cell(1,4);
sdf_out_all = cell(1,4);

for jj = 1:4
  sdf_out_acc{jj} = [sdf_out(jj,:).acc]';
  sdf_out_fast{jj} = [sdf_out(jj,:).fast]';
  sdf_out_all{jj} = [sdf_out(jj,:).all]';
end

figure(); hold on %Accurate
for jj = 1:4
  color_jj = [1 COLOR_GRAD(jj) COLOR_GRAD(jj)];
  plot(TIME_PLOT, mean(sdf_out_acc{jj}(:,TIME_PLOT+TIME_ARRAY)), 'LineWidth',1.25, 'Color',color_jj)
end
plot(TIME_PLOT, mean(sdf_in_acc(:,TIME_PLOT+TIME_ARRAY)), 'LineWidth',1.5, 'Color','r')
xlim([T_LIM(1)-5, T_LIM(2)+5]); ppretty()
y_tick = get(gca, 'ytick')'; set(gca, 'yticklabel',num2str(y_tick,'%.1f'))

pause(.25)

figure(); hold on %Fast
for jj = 1:4
  color_jj = [COLOR_GRAD(jj) .9 COLOR_GRAD(jj)];
  plot(TIME_PLOT, mean(sdf_out_fast{jj}(:,TIME_PLOT+TIME_ARRAY)), 'LineWidth',1.25, 'Color',color_jj)
end
plot(TIME_PLOT, mean(sdf_in_fast(:,TIME_PLOT+TIME_ARRAY)), 'LineWidth',1.5, 'Color',[0 .7 0])
xlim([T_LIM(1)-5, T_LIM(2)+5]); ppretty()
y_tick = get(gca, 'ytick')'; set(gca, 'yticklabel',num2str(y_tick,'%.1f'))

pause(.25)

figure(); hold on %Combined
for jj = 1:4
  color_jj = [COLOR_GRAD(jj) COLOR_GRAD(jj) COLOR_GRAD(jj)];
  plot(TIME_PLOT, mean(sdf_out_all{jj}(:,TIME_PLOT+TIME_ARRAY)), 'LineWidth',1.25, 'Color',color_jj)
end
plot(TIME_PLOT, mean(sdf_in_all(:,TIME_PLOT+TIME_ARRAY)), 'LineWidth',1.5, 'Color','k')
xlim([T_LIM(1)-5, T_LIM(2)+5]); ppretty()
y_tick = get(gca, 'ytick')'; set(gca, 'yticklabel',num2str(y_tick,'%.1f'))

end%function:plot_sdf_visual_response()


function [ dir_out ] = util_circshift_dir( dir_in , num_shift )

dir_out = dir_in + num_shift;

if (dir_out < 1)
  dir_out = dir_out + 8;
elseif (dir_out > 8)
  dir_out = dir_out - 8;
end

end%utility:util_circshift_dir()
