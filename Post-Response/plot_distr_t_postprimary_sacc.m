function [ ] = plot_distr_t_postprimary_sacc( moves , movesAll , binfo )
%plot_distr_t_postprimary_sacc Summary of this function goes here
%   Detailed explanation goes here

INDEX = 2; %index of saccade post-primary
% T_BIN_EDGES = (0 : 25 : 800);
NUM_SESSION = length(moves);

t_ppsacc_Acc = [];
t_ppsacc_Fast = [];

for kk = 1:NUM_SESSION
  
  %index trials by condition
  idx_Acc = (binfo(kk).condition == 1);
  idx_Fast = (binfo(kk).condition == 3);
  
  %index by trial outcome
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  trial_errdir_Acc = find(idx_Acc & idx_errdir);
  trial_errdir_Fast = find(idx_Fast & idx_errdir);
  
  %index saccades by number from primary saccade
  idxAll_ppsacc_Acc = (ismember(movesAll(kk).trial, trial_errdir_Acc) & (movesAll(kk).index == INDEX));
  idxAll_ppsacc_Fast = (ismember(movesAll(kk).trial, trial_errdir_Fast) & (movesAll(kk).index == INDEX));
  
  %only take trials for which we have a post-primary saccade
  trial_errdir_Acc = movesAll(kk).trial(idxAll_ppsacc_Acc);
  trial_errdir_Fast = movesAll(kk).trial(idxAll_ppsacc_Fast);
  
  %Fast condition
  t_ppsacc_kk_Fast = double(movesAll(kk).resptime(idxAll_ppsacc_Fast) - moves(kk).resptime(trial_errdir_Fast));
  t_ppsacc_Fast = cat(2, t_ppsacc_Fast, t_ppsacc_kk_Fast);
  
  %Accurate condition
  t_ppsacc_kk_Acc = double(movesAll(kk).resptime(idxAll_ppsacc_Acc) - moves(kk).resptime(trial_errdir_Acc));
  t_ppsacc_Acc = cat(2, t_ppsacc_Acc, t_ppsacc_kk_Acc);
  
end%for:session(kk)

%% Plotting

t_plot_F = sort(t_ppsacc_Fast);
y_plot_F = (1:length(t_plot_F)) / length(t_plot_F);
t_plot_A = sort(t_ppsacc_Acc);
y_plot_A = (1:length(t_plot_A)) / length(t_plot_A);

figure(); hold on
% histogram(t_ppsacc, T_BIN_EDGES, 'Normalization','probability', 'FaceColor',[.2 .2 .2])
plot(t_plot_F, y_plot_F, '-', 'LineWidth',1.25, 'Color',[0 .7 0])
plot(t_plot_A, y_plot_A, 'r-', 'LineWidth',1.25)
xlim([100 800])
ppretty()

end%fxn:plot_distr_t_postprimary_sacc()

