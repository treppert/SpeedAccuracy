function [ norm_factor ] = util_compute_normfactor_buildup( spikes , ninfo , moves , binfo )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

TIME_NORM = (-100:100); %time re. response

NUM_CELLS = length(spikes);
norm_factor = NaN(1,NUM_CELLS);

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, {'M','VM'}); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).session);
  
  %get all trials from SAT task
  idx_SAT = ismember(binfo(kk_moves).condition, [1,3]);
  
  %index by trials with response inside movement field
  idx_Rin = ismember(moves(kk_moves).octant, ninfo(kk).move_field);
  
  %compute SDF
  sdf_Rin = compute_spike_density_fxn(spikes(kk).SAT(idx_SAT & idx_Rin));
  sdf_Rin = align_signal_on_response(sdf_Rin, moves(kk_moves).resptime(idx_SAT & idx_Rin));
  sdf_Rin = mean(sdf_Rin);
  
  norm_factor(kk) = max(sdf_Rin(3500+TIME_NORM));
  
end%for:cells(kk)

end%utility:util_compute_normfactor_visresp()
