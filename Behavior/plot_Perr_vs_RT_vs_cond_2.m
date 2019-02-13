function [ ] = plot_Perr_vs_RT_vs_cond_2( moves , binfo )
%plot_Perr_vs_RT_vs_cond_2 Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

BIN_LIM_RT_FAST = (200 : 40 : 400); NUM_BIN_FAST = length(BIN_LIM_RT_FAST) - 1;
BIN_LIM_RT_ACC = (300 : 100 : 800); NUM_BIN_ACC = length(BIN_LIM_RT_ACC) - 1;

RT_PLOT_FAST = BIN_LIM_RT_FAST(1:end-1) + diff(BIN_LIM_RT_FAST)/2;
RT_PLOT_ACC = BIN_LIM_RT_ACC(1:end-1) + diff(BIN_LIM_RT_ACC)/2;

binER_A = NaN(NUM_SESSION,NUM_BIN_ACC);
binER_F = NaN(NUM_SESSION,NUM_BIN_FAST);

meanER_A = NaN(1,NUM_SESSION);
meanER_F = NaN(1,NUM_SESSION);

meanRT_A = NaN(1,NUM_SESSION);
meanRT_F = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  idx_err = (binfo(kk).err_dir);
  
  idx_acc = (binfo(kk).condition == 1);
  idx_fast = (binfo(kk).condition == 3);
  
  respTime = double(moves(kk).resptime);
  
  %% Compute mean ER and RT vs. condition
  
  meanRT_A(kk) = nanmean(respTime(idx_acc));
  meanRT_F(kk) = nanmean(respTime(idx_fast));
  
  meanER_A(kk) = sum(idx_err & idx_acc) / sum(idx_acc);
  meanER_F(kk) = sum(idx_err & idx_fast) / sum(idx_fast);
  
  %% Compute ER binned by RT in each condition
  
  for jj = 1:NUM_BIN_FAST
    
    idx_jj = ((respTime > BIN_LIM_RT_FAST(jj)) & (respTime <= BIN_LIM_RT_FAST(jj+1)));
    binER_F(kk,jj) = sum(idx_err & idx_fast & idx_jj) / sum(idx_fast & idx_jj);
    
  end%for:binFAST(jj)
  
  for jj = 1:NUM_BIN_ACC
    
    idx_jj = ((respTime > BIN_LIM_RT_ACC(jj)) & (respTime <= BIN_LIM_RT_ACC(jj+1)));
    binER_A(kk,jj) = sum(idx_err & idx_acc & idx_jj) / sum(idx_acc & idx_jj);
    
  end%for:binACC(jj)
  
end%for:session(kk)


%% Plotting

figure(); hold on
errorbar_no_caps(RT_PLOT_FAST, mean(binER_F), 'err',std(binER_F)/sqrt(NUM_SESSION), 'color',[0 .7 0])
errorbar_no_caps(RT_PLOT_ACC, mean(binER_A), 'err',std(binER_A)/sqrt(NUM_SESSION), 'color','r')
errorbarxy(mean(meanRT_F), mean(meanER_F), std(meanRT_F)/sqrt(NUM_SESSION), std(meanER_F)/sqrt(NUM_SESSION), {'g-','g','g'})
errorbarxy(mean(meanRT_A), mean(meanER_A), std(meanRT_A)/sqrt(NUM_SESSION), std(meanER_A)/sqrt(NUM_SESSION), {'r-','r','r'})
ytickformat('%3.2f')
ppretty('image_size',[4.8,3])

end%fxn:plot_Perr_vs_RT_vs_cond_2()

