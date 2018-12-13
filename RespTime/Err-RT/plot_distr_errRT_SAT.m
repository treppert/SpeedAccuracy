function [  ] = plot_distr_errRT_SAT( moves , binfo )

NUM_SESSION = length(moves);

for kk = 1:NUM_SESSION
  
  idxFast = (binfo(kk).condition == 3);
  idxAcc  = (binfo(kk).condition == 1);
  
  idxErrTime = (~binfo(kk).err_dir & binfo(kk).err_time);
  idxErrHold = (binfo(kk).err_hold);
  
  errRT_Acc_Break = double(moves(kk).resptime(idxAcc & idxErrTime)) - double(binfo(kk).tgt_dline(idxAcc & idxErrTime));
%   errRT_Fast = double(moves(kk).resptime(idxFast & idxErrTime)) - double(binfo(kk).tgt_dline(idxFast & idxErrTime));
  
  %% Plotting
  figure(); hold on

  histogram(errRT_Acc_Break, 'BinWidth',50, 'EdgeColor','none', 'FaceColor','r', 'Normalization','count')
  plot(median(errRT_Acc_Break)*ones(1,2), [0 20], 'k--')
%   histogram(errRT_Fast, 'BinWidth',50, 'EdgeColor','none', 'FaceColor',[0 .7 0], 'Normalization','count')
%   line([0 0], [0 .25], 'color','k', 'linewidth',1.5)
%   xlim([-400 800]); xticks(-400:200:800)

  ppretty()
  pause()
  
end%for:session(kk)

end%function:plot_distr_errRT_SAT()

