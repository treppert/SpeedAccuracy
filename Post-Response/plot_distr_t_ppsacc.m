function [ ] = plot_distr_t_ppsacc( moves , movesPP , binfo )
%plot_distr_t_ppsacc Summary of this function goes here
%   Detailed explanation goes here

% T_BIN_EDGES = (0 : 25 : 800);
NUM_SESSION = length(moves);

tPP_Acc = [];
tPP_Fast = [];

for kk = 1:NUM_SESSION
  
  %skip trials with no recorded post-primary saccade
  idx_noPP = (movesPP(kk).resptime == 0);
  
  %index trials by condition
  idx_Acc = (binfo(kk).condition == 1);
  idx_Fast = (binfo(kk).condition == 3);
  
  %index by trial outcome
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %isolate RT data
  RTmoves = double(moves(kk).resptime);
  RTmovesPP = double(movesPP(kk).resptime);
  
  tPP_Acc = cat(2, tPP_Acc, RTmovesPP(idx_Acc & idx_errdir & ~idx_noPP) - RTmoves(idx_Acc & idx_errdir & ~idx_noPP));
  tPP_Fast = cat(2, tPP_Fast, RTmovesPP(idx_Fast & idx_errdir & ~idx_noPP) - RTmoves(idx_Fast & idx_errdir & ~idx_noPP));
  
end%for:session(kk)

%% Plotting

t_plot_F = sort(tPP_Fast);
y_plot_F = (1:length(t_plot_F)) / length(t_plot_F);
t_plot_A = sort(tPP_Acc);
y_plot_A = (1:length(t_plot_A)) / length(t_plot_A);

figure(); hold on
% histogram(t_ppsacc, T_BIN_EDGES, 'Normalization','probability', 'FaceColor',[.2 .2 .2])
plot(t_plot_F, y_plot_F, '-', 'LineWidth',1.25, 'Color',[0 .7 0])
plot(t_plot_A, y_plot_A, 'r-', 'LineWidth',1.25)
xlim([100 800])
ppretty()

end%fxn:plot_distr_t_ppsacc()

