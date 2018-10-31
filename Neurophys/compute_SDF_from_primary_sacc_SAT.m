function [ A_POSTSACC ] = compute_SDF_from_primary_sacc_SAT( binfo , moves , ninfo , spikes )
%compute_SDF_from_primary_sacc_SAT() Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = 8;%length(spikes);

TIME_POSTSACC  = 3500 + (-300 : 500);
A_POSTSACC = new_struct({'FastCorr','FastErrDir','FastErrTime',...
  'AccCorr','AccErrDir','AccErrTime'}, 'dim',[1,NUM_CELLS]);

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, moves(kk).resptime); 
  
  %index by isolation quality
  idx_iso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  
  %index by condition
  idx_fast = ((binfo(kk).condition == 3) & ~idx_iso);
  idx_acc = ((binfo(kk).condition == 1) & ~idx_iso);
  
  %index by saccade direction
%   idx_dir = ismember(moves(kk).octant, [8,1,2]);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  idx_errtime = (~binfo(kk).err_dir & binfo(kk).err_time);
  
  %control for choice error direction
%   [idx_errdir, idx_corr] = equate_respdir_err_vs_corr(idx_errdir, idx_corr, moves(kk).octant);
  
  %remove any activity related to corrective saccade initiation
%   trial_err = find(idx_cond & idx_err);
%   sdf_kk(idx_fast & idx_err,:) = rem_spikes_post_corrective_SAT(sdf_kk(idx_fast & idx_err,:), movesAll(kk), trial_err);
  
  %save activity post-primary saccade
  A_POSTSACC(cc).FastCorr = sdf_kk(idx_fast & idx_corr, TIME_POSTSACC);
  A_POSTSACC(cc).FastErrDir = sdf_kk(idx_fast & idx_errdir, TIME_POSTSACC);
  A_POSTSACC(cc).FastErrTime = sdf_kk(idx_fast & idx_errtime, TIME_POSTSACC);
  A_POSTSACC(cc).AccCorr = sdf_kk(idx_acc & idx_corr, TIME_POSTSACC);
  A_POSTSACC(cc).AccErrDir = sdf_kk(idx_acc & idx_errdir, TIME_POSTSACC);
  A_POSTSACC(cc).AccErrTime = sdf_kk(idx_acc & idx_errtime, TIME_POSTSACC);
  
end%for:cells(cc)

end%fxn:compute_SDF_from_primary_sacc_SAT()

