function [  ] = barplot_RT_SAT( binfo , moves )
%compute_avg_RT_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSIONS = length(moves);

RT = new_struct({'acc','fast','ntrl'}, 'dim',[1,NUM_SESSIONS]);

RTacc = new_struct({'corr','errdir'}, 'dim',[1,NUM_SESSIONS]); %save RT X condition X choice error
RTfast = new_struct({'corr','errdir'}, 'dim',[1,NUM_SESSIONS]);
RTntrl = new_struct({'corr','errdir'}, 'dim',[1,NUM_SESSIONS]);

for kk = 1:NUM_SESSIONS
  
  %index by condition
  idx_acc = (binfo(kk).condition == 1);
  idx_fast = (binfo(kk).condition == 3);
  idx_ntrl = (binfo(kk).condition == 4);
  
  RT_kk = double(moves(kk).resptime);
  
  RT(kk).acc = nanmean(RT_kk(idx_acc));
  RT(kk).fast = nanmean(RT_kk(idx_fast));
  RT(kk).ntrl = nanmean(RT_kk(idx_ntrl));
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %control for choice error direction
  [idx_errdir, idx_corr] = equate_respdir_err_vs_corr(idx_errdir, idx_corr, moves(kk).octant);
  
  RTacc(kk).corr = nanmean(RT_kk(idx_acc & idx_corr));
  RTacc(kk).errdir = nanmean(RT_kk(idx_acc & idx_errdir));
  RTfast(kk).corr = nanmean(RT_kk(idx_fast & idx_corr));
  RTfast(kk).errdir = nanmean(RT_kk(idx_fast & idx_errdir));
  RTntrl(kk).corr = nanmean(RT_kk(idx_ntrl & idx_corr));
  RTntrl(kk).errdir = nanmean(RT_kk(idx_ntrl & idx_errdir));
  
end%for:sessions(kk)

fprintf('RT Acc: %g +/- %g ms\n', mean([RT.acc]), std([RT.acc])/sqrt(NUM_SESSIONS))
fprintf('RT Fast: %g +/- %g ms\n', mean([RT.fast]), std([RT.fast])/sqrt(NUM_SESSIONS))
fprintf('RT Neutral: %g +/- %g ms\n', mean([RT.ntrl]), std([RT.ntrl])/sqrt(NUM_SESSIONS))

%% Stats
[~,pval,~,tstat] = ttest([RT.acc], [RT.fast], 'tail','both');
fprintf('ACC vs FAST: pval = %g || t(%d) = %g\n', pval, tstat.df, tstat.tstat)

%% Plotting -- RT X condition
if (false)
figure(); hold on

mu = [ mean([RT.acc]) , mean([RT.fast]) ];
err = [ std([RT.acc]) , std([RT.fast]) ] / sqrt(NUM_SESSIONS);

errorbar_no_caps([.95 1.95], mu, 'err',err)

xticks([]); xlim([.90 2.10])
ppretty('image_size',[1.2,3])
end

%% Plotting -- RT X condition X error
if (true)
figure(); hold on

mu_A = [ mean([RTacc.corr]) , mean([RTacc.errdir]) ];
err_A = [ std([RTacc.corr]) , std([RTacc.errdir]) ] / sqrt(NUM_SESSIONS);
mu_F = [ mean([RTfast.corr]) , mean([RTfast.errdir]) ];
err_F = [ std([RTfast.corr]) , std([RTfast.errdir]) ] / sqrt(NUM_SESSIONS);
mu_N = [ mean([RTntrl.corr]) , mean([RTntrl.errdir]) ];
err_N = [ std([RTntrl.corr]) , std([RTntrl.errdir]) ] / sqrt(NUM_SESSIONS);

bar([.95 1.95], mu_A, 0.5, 'FaceColor','r')
bar([2.95 3.95], mu_N, 0.5, 'FaceColor',[.5 .5 .5])
bar([4.95 5.95], mu_F, 0.5, 'FaceColor',[0 .7 0])
errorbar_no_caps([.95 1.95], mu_A, 'err',err_A)
errorbar_no_caps([2.95 3.95], mu_N, 'err',err_N)
errorbar_no_caps([4.95 5.95], mu_F, 'err',err_F)

xticks([]); xlim([.5 6.5])
ylim([200 700])
ppretty('image_size',[2.2,4])
end

end%function:compute_avg_RT_SAT()

