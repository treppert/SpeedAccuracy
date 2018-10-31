function [ A_REWARD ] = compute_SDF_from_reward_SAT( binfo , moves , ninfo , spikes )
%compute_SDF_from_primary_sacc_SAT() Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = 8;%length(spikes);

TIME_REWARD  = 3500 + (-300 : 500);
A_REWARD = new_struct({'FastCorr','FastErrTime','AccCorr','AccErrTime'}, 'dim',[1,NUM_CELLS]);

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, double(moves(kk).resptime) + binfo(kk).rewtime); 
  
  %index by isolation quality
  idx_iso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  
  %index by condition
  idx_fast = ((binfo(kk).condition == 3) & ~idx_iso);
  idx_acc = ((binfo(kk).condition == 1) & ~idx_iso);
  
  %index by saccade direction
%   idx_dir = ismember(moves(kk).octant, [8,1,2]);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_errtime = (~binfo(kk).err_dir & binfo(kk).err_time);
  
  %save activity post-primary saccade
  A_REWARD(cc).FastCorr = sdf_kk(idx_fast & idx_corr, TIME_REWARD);
  A_REWARD(cc).FastErrTime = sdf_kk(idx_fast & idx_errtime, TIME_REWARD);
  A_REWARD(cc).AccCorr = sdf_kk(idx_acc & idx_corr, TIME_REWARD);
  A_REWARD(cc).AccErrTime = sdf_kk(idx_acc & idx_errtime, TIME_REWARD);
  
end%for:cells(cc)

end%fxn:compute_SDF_from_primary_sacc_SAT()

