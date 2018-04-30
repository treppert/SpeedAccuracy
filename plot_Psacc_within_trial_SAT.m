function [  ] = plot_Psacc_within_trial_SAT( moves , info )
%plot_Psacc_within_trial_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

BIN_LIM = (-500 : 100 : 1000); %relative to time of reward
NUM_BIN = length(BIN_LIM) - 1;
T_PLOT = BIN_LIM(1:end-1) + DIFF(BIN_LIM)/2;

time_rew = determine_time_reward_SAT(info, moves);

Psacc_Acc_Corr = NaN(NUM_SESSION, NUM_BIN);
Psacc_Fast_Corr = NaN(NUM_SESSION, NUM_BIN);
Psacc_Acc_Err = NaN(NUM_SESSION, NUM_BIN);
Psacc_Fast_Err = NaN(NUM_SESSION, NUM_BIN);

for kk = 1:NUM_SESSION
  
  idx_Fast = (info(kk).condition == 3);
  idx_Acc = (info(kk).condition == 1);
  
  idx_Corr = ~(info(kk).err_dir | info(kk).err_time);
  idx_Err = (~info(kk).err_dir & info(kk).err_time); %timing errors
  
  for jj = 1:NUM_BIN
    
    idx_jj = (); %need time of all saccades here
    
  end%for:time-bins(jj)
  
end%for:sessions(kk)

end%function:plot_Psacc_within_trial_SAT()

