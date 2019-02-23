function [ ] = plotPPsaccISI( binfo , moves , movesPP )
%plotPPsaccISI Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(movesPP);

QUANT = (0.1 : 0.1 : 0.9); %quantiles of inter-saccade interval
NUM_QUANT = length(QUANT);

tppAcc = NaN(NUM_SESSION,NUM_QUANT);
tppFast = NaN(NUM_SESSION,NUM_QUANT);

for kk = 1:NUM_SESSION
  
  %skip trials with no recorded post-primary saccade
  idxNoPP = (movesPP(kk).resptime == 0);
  
  %index trials by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %isolate RT data
  RTmoves = double(moves(kk).resptime);
  RTmovesPP = double(movesPP(kk).resptime);
  
  tPP_Acc = cat(2, tPP_Acc, RTmovesPP(idxAcc & idxErr & ~idxNoPP) - RTmoves(idxAcc & idxErr & ~idxNoPP));
  tPP_Fast = cat(2, tPP_Fast, RTmovesPP(idxFast & idxErr & ~idxNoPP) - RTmoves(idxFast & idxErr & ~idxNoPP));
  
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

end%fxn:plotPPsaccISI()

