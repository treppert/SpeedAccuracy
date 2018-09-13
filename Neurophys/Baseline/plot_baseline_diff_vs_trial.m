function [  ] = plot_baseline_diff_vs_trial( spikes , ninfo , binfo )
%plot_hist_diff_baseline Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);

TRIALS_PLOT = [-2, -1, 0, 1, 2, 3];
NUM_TRIALS = length(TRIALS_PLOT);

TYPE_PLOT = {'V','VM'};

IDX_ARRAY = 3500;
TIME_STIM = (-500:-100);

binfo = identify_condition_switch(binfo);

avg_base = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
avg_base = populate_struct(avg_base, {'acc','fast'}, NaN(NUM_TRIALS,1));

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).session);
  
  %index by condition
%   idx_acc = (binfo(kk_moves).condition == 1);
%   idx_fast = (binfo(kk_moves).condition == 3);
  
  sdf_kk = compute_spike_density_fxn(spikes(kk).SAT);
  
  trials_norm = [ binfo(kk_moves).acc_to_fast , binfo(kk_moves).fast_to_acc ];
  trials_norm = trials_norm + TRIALS_PLOT';
  trials_norm = reshape(trials_norm, 1,numel(trials_norm));
  norm_factor = mean(mean(sdf_kk(trials_norm, TIME_STIM+IDX_ARRAY)));
  
  %get normalized baseline activity by condition
  for jj = 1:NUM_TRIALS
    
    trials_A2F = binfo(kk_moves).acc_to_fast + TRIALS_PLOT(jj);
    trials_F2A  = binfo(kk_moves).fast_to_acc + TRIALS_PLOT(jj);

    sdf_A2F = sdf_kk(trials_A2F,:);
    sdf_F2A = sdf_kk(trials_F2A,:);

    avg_A2F = mean(sdf_A2F(:,TIME_STIM+IDX_ARRAY));
    avg_F2A  = mean(sdf_F2A(:,TIME_STIM+IDX_ARRAY));

    avg_base(kk).fast(jj) = mean(avg_A2F) / norm_factor;
    avg_base(kk).acc(jj) = mean(avg_F2A) / norm_factor;
    
  end%for:trials(jj)
  
end%for:neurons(kk)

avg_A2F = [avg_base.fast];
avg_F2A = [avg_base.acc];

idx_rem = ~ismember({ninfo.type}, TYPE_PLOT);
avg_A2F(:,idx_rem) = [];
avg_F2A(:,idx_rem) = [];

NUM_SEM = size(avg_A2F,2); %update number of cells for plotting

%% Plotting - baseline activity

figure(); hold on
plot([TRIALS_PLOT(1),TRIALS_PLOT(end)], [1,1], 'k--', 'LineWidth',1.25)
% plot(TRIALS_PLOT, avg_F2A)
errorbar_no_caps(TRIALS_PLOT(1:3), mean(avg_F2A(1:3,:),2), 'err',std(avg_F2A(1:3,:),0,2)/sqrt(NUM_SEM), 'color',[0 .7 0])
errorbar_no_caps(TRIALS_PLOT(4:6), mean(avg_F2A(4:6,:),2), 'err',std(avg_F2A(4:6,:),0,2)/sqrt(NUM_SEM), 'color','r')
errorbar_no_caps(TRIALS_PLOT(1:3), mean(avg_A2F(1:3,:),2), 'err',std(avg_A2F(1:3,:),0,2)/sqrt(NUM_SEM), 'color','r')
errorbar_no_caps(TRIALS_PLOT(4:6), mean(avg_A2F(4:6,:),2), 'err',std(avg_A2F(4:6,:),0,2)/sqrt(NUM_SEM), 'color',[0 .7 0])
xlim([TRIALS_PLOT(1)-.25, TRIALS_PLOT(end)+.25])
xticklabels({'-3','-2','-1','+1','+2','+3'})
ppretty(); %set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'))

end%function:plot_baseline_diff_vs_trial()

