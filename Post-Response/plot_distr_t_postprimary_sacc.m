function [ ] = plot_distr_t_postprimary_sacc( moves , movesAll , binfo )
%plot_distr_t_postprimary_sacc Summary of this function goes here
%   Detailed explanation goes here

INDEX = 2; %index of saccade post-primary
% T_BIN_EDGES = (0 : 25 : 800);
NUM_SESSION = length(moves);

t_ppsacc = [];

for kk = 1:NUM_SESSION
  
  %index trials by condition and trial outcome
  idx_fast = (binfo(kk).condition == 3);
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  trial_errdir = find(idx_fast & idx_errdir);
  
  %index saccades by number from primary saccade
  idxAll_ppsacc = (ismember(movesAll(kk).trial, trial_errdir) & (movesAll(kk).index == INDEX));
  
  %only take trials for which we have a post-primary saccade
  trial_errdir = movesAll(kk).trial(idxAll_ppsacc);
  
  t_ppsacc_kk = double(movesAll(kk).resptime(idxAll_ppsacc) - moves(kk).resptime(trial_errdir));
  t_ppsacc = cat(2, t_ppsacc, t_ppsacc_kk);
  
end%for:session(kk)

%% Plotting

t_plot = sort(t_ppsacc);
y_plot = (1:length(t_plot)) / length(t_plot);

figure()
% histogram(t_ppsacc, T_BIN_EDGES, 'Normalization','probability', 'FaceColor',[.2 .2 .2])
plot(t_plot, y_plot, 'g-', 'LineWidth',1.25)
ppretty()

end%fxn:plot_distr_t_postprimary_sacc()

