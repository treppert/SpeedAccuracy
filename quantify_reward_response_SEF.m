function [  ] = quantify_reward_response_SEF( ninfo , spikes , binfo , moves )
%quantify_reward_response_SEF Summary of this function goes here
%   Detailed explanation goes here

TIME_ZERO = 3500;
T_WIN = TIME_ZERO + [100, 500];

NUM_CELLS = length(spikes);

A_Acc_Corr = cell(1,NUM_CELLS); %activity on each trial
A_Acc_ErrTime = cell(1,NUM_CELLS);
A_Fast_Corr = cell(1,NUM_CELLS);

Aavg_AC = NaN(1,NUM_CELLS); %average activity across trials
Aavg_AE = NaN(1,NUM_CELLS);
Aavg_FC = NaN(1,NUM_CELLS);

cc_inc = false(1,NUM_CELLS); %significant (rank-sum) increase?
cc_dec = false(1,NUM_CELLS); %decrease

time_rew = determine_time_reward_SAT(binfo, moves);

for cc = 1:NUM_CELLS
%   if (ninfo(cc).rewAcc <= 0); continue; end
  
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, moves(kk).resptime + time_rew(kk));
  
  idx_fast = (binfo(kk).condition == 3);
  idx_acc = (binfo(kk).condition == 1);
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time);
  idx_errtime = (~binfo(kk).err_dir & binfo(kk).err_time);
  
  A_Acc_Corr{cc} = nanmean(sdf_kk(idx_acc & idx_corr, T_WIN(1):T_WIN(2)),2);
  A_Acc_ErrTime{cc} = nanmean(sdf_kk(idx_acc & idx_errtime, T_WIN(1):T_WIN(2)),2);
  A_Fast_Corr{cc} = nanmean(sdf_kk(idx_fast & idx_corr, T_WIN(1):T_WIN(2)),2);
%   
%   figure(); hold on
%   histogram(A_Acc_Corr{cc}, 'FaceColor','r')
%   histogram(A_Acc_ErrTime{cc}, 'FaceColor','k')
%   print_session_unit(gca, ninfo(cc))
%   ppretty()
  
  flag = wilcoxon_ranksum(A_Acc_Corr{cc}, A_Acc_ErrTime{cc});
  if (flag == 2)
    cc_inc(cc) = true;
  elseif (flag == 1)
    cc_dec(cc) = true;
  end
  
  Aavg_AC(cc) = nanmean(A_Acc_Corr{cc});
  Aavg_AE(cc) = nanmean(A_Acc_ErrTime{cc});
  Aavg_FC(cc) = nanmean(A_Fast_Corr{cc});
  
end%for:cells(cc)

figure(); hold on
histogram(Aavg_AE-Aavg_AC, 'BinWidth',4, 'FaceColor',[.4 .4 .4])
histogram(Aavg_AE(cc_dec|cc_inc)-Aavg_AC(cc_dec|cc_inc), 'BinWidth',4, 'FaceColor','k')
ppretty('image_size',[2,3.2])

pause(0.25)

figure(); hold on
histogram(Aavg_FC-Aavg_AC, 'BinWidth',4, 'FaceColor',[.4 .4 .4])
ppretty('image_size',[2,3.2])

end%function:quantify_reward_response_SEF()

function [ flag ] = wilcoxon_ranksum(samp1, samp2)

flag = 0;

ALPHA = 0.01;
TAIL = 'both';

[~,h] = ranksum(samp1', samp2', 'alpha',ALPHA, 'tail',TAIL);

if (h) %significant difference
  if (nanmedian(samp2) > nanmedian(samp1))
    flag = 2;
  else
    flag = 1;
  end
end

end%util:wilcoxon_ranksum()

