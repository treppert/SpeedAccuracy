function [ errRate ] = plot_Perr_vs_RT_vs_cond( moves , binfo )
%plot_errorrate_vs_RT_vs_cond Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

ER_A = NaN(1,NUM_SESSION);
ER_F = NaN(1,NUM_SESSION);
ER_N = NaN(1,NUM_SESSION);

RT_A = NaN(1,NUM_SESSION);
RT_F = NaN(1,NUM_SESSION);
RT_N = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  idx_err = (binfo(kk).err_dir);
  
  idx_acc = (binfo(kk).condition == 1);
  idx_fast = (binfo(kk).condition == 3);
%   idx_ntrl = (info(kk).condition == 4);
  
  RT_A(kk) = nanmean(moves(kk).resptime(idx_acc));
  RT_F(kk) = nanmean(moves(kk).resptime(idx_fast));
%   RT_N(kk) = nanmean(moves(kk).resptime(idx_ntrl));
  
  ER_A(kk) = sum(idx_err & idx_acc) / sum(idx_acc);
  ER_F(kk) = sum(idx_err & idx_fast) / sum(idx_fast);
%   ER_N(kk) = sum(idx_err & idx_ntrl) / sum(idx_ntrl);
  
end%for:session(kk)

if (nargout > 0)
  errRate = struct('acc',ER_A, 'fast',ER_F);
  return
end

% figure(); hold on
% errorbarxy(mean(RT_F), mean(ER_F), std(RT_F)/sqrt(NUM_SESSION), std(ER_F)/sqrt(NUM_SESSION), {'g-','g','g'})
% errorbarxy(mean(RT_A), mean(ER_A), std(RT_A)/sqrt(NUM_SESSION), std(ER_A)/sqrt(NUM_SESSION), {'r-','r','r'})
% ytickformat('%3.2f')
% xlim([300 600]); ppretty('image_size',[4.8,3])

figure(); hold on
plot([RT_F ; RT_A], [ER_F ; ER_A], 'k-')
ytickformat('%3.2f')
ppretty('image_size',[4.8,3])

end%fxn:plot_errorrate_vs_RT_vs_cond()

