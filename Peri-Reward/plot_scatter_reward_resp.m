function [  ] = plot_scatter_reward_resp( ninfo , spikes , binfo , moves )
%plot_scatter_reward_resp Summary of this function goes here
%   Detailed explanation goes here

TIME_ZERO = 3500;
T_WIN = TIME_ZERO + [100, 500];

NUM_CELLS = length(spikes);
MAX_T_REW = 1000;

A_Acc_Corr = cell(1,NUM_CELLS); %activity on each trial
A_Acc_ErrTime = cell(1,NUM_CELLS);
A_Fast_Corr = cell(1,NUM_CELLS);

Aavg_AC = NaN(1,NUM_CELLS); %average activity across trials
Aavg_AE = NaN(1,NUM_CELLS);
Aavg_FC = NaN(1,NUM_CELLS);

[~,time_rew] = determine_time_reward_SAT(binfo, moves);

for cc = 1:NUM_CELLS
%   if (ninfo(cc).rewAcc <= 0); continue; end
  
  sdf = compute_spike_density_fxn(spikes(cc).SAT);
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time);
  idx_errtime = (~binfo(kk).err_dir & binfo(kk).err_time);
  
  sdf = align_signal_on_response(sdf, moves(kk).resptime + time_rew{kk});
  
  idx_fast = (binfo(kk).condition == 3);
  idx_acc = (binfo(kk).condition == 1);
  
  A_Acc_Corr{cc} = nanmean(sdf(idx_acc & idx_corr, T_WIN(1):T_WIN(2)),2);
  A_Acc_ErrTime{cc} = nanmean(sdf(idx_acc & idx_errtime, T_WIN(1):T_WIN(2)),2);
  A_Fast_Corr{cc} = nanmean(sdf(idx_fast & idx_corr, T_WIN(1):T_WIN(2)),2);
  
  Aavg_AC(cc) = nanmean(A_Acc_Corr{cc});
  Aavg_AE(cc) = nanmean(A_Acc_ErrTime{cc});
  Aavg_FC(cc) = nanmean(A_Fast_Corr{cc});
  
end%for:cells(cc)

figure(); hold on
plot(Aavg_AC, Aavg_AE, 'ko', 'MarkerSize',6)
% histogram(Aavg_AE-Aavg_AC, 'BinWidth',2, 'FaceColor',[.4 .4 .4])
% histogram(Aavg_AE(cc_dec|cc_inc)-Aavg_AC(cc_dec|cc_inc), 'BinWidth',2, 'FaceColor','k')
ppretty('image_size',[4,4])

% pause(0.5)
% 
% figure(); hold on
% plot(Aavg_AC, Aavg_FC, 'ko', 'MarkerSize',8)
% ppretty('image_size',[4,4])


end%fxn:plot_scatter_reward_resp()

