function [ norm_factor ] = util_compute_normfactor_visresp( spikes , ninfo , binfo )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

TIME_NORM = (50:1000); %time post-array appearance -- FEF

NUM_CELLS = length(spikes);
norm_factor = NaN(1,NUM_CELLS);

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, {'V','VM'}); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).session);
  
  %get all trials from SAT task
  idx_SAT = ismember(binfo(kk_moves).condition, [1,3]);
  
  %index by trials with target in RF
  idx_Tin = ismember(binfo(kk_moves).tgt_octant, ninfo(kk).resp_field);
  
  %compute SDF
  sdf_Tin = compute_spike_density_fxn(spikes(kk).SAT(idx_SAT & idx_Tin));
  sdf_Tin = mean(sdf_Tin);
  
  norm_factor(kk) = max(sdf_Tin(3500+TIME_NORM));
  
end%for:cells(kk)

end%utility:util_compute_normfactor_visresp()
