function [ SDF_vs_dir ] = util_compute_SDF_vs_dir( spikes , ninfo , moves , binfo , type_plot )
%util_compute_SDF_vs_dir Summary of this function goes here
%   Detailed explanation goes here

NUM_DIR = 8;
NUM_CELLS = length(spikes);

SDF_vs_dir = new_struct({'acc','fast'}, 'dim',[NUM_DIR,NUM_CELLS]);

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, type_plot); continue; end
  
  %get lead time for removing movement-related activity (via cell type)
  if strcmp(ninfo(kk).type, 'V')
    lead_time = 0;
  elseif strcmp(ninfo(kk).type, 'VM')
    lead_time = 0;
  else
    error('Cell type should be one of: "V" or "VM"')
  end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).session);
  
  %index by task-relevant movement
  idx_tr = moves(kk_moves).taskrel;
  
  %index by condition
  idx_fast = (binfo(kk_moves).condition == 3);
  idx_acc = (binfo(kk_moves).condition == 1);
  
  for jj = 1:NUM_DIR
    
    idx_dd = ismember(binfo(kk_moves).tgt_octant, jj);
    
    sdf_acc = compute_spike_density_fxn(spikes(kk).SAT(idx_acc & idx_dd & idx_tr));
    sdf_fast = compute_spike_density_fxn(spikes(kk).SAT(idx_fast & idx_dd & idx_tr));
    sdf_all = compute_spike_density_fxn(spikes(kk).SAT((idx_acc|idx_fast) & idx_dd & idx_tr));
    
    sdf_acc = remove_spikes_post_response(sdf_acc, moves(kk_moves).resptime(idx_acc & idx_dd & idx_tr), lead_time);
    sdf_fast = remove_spikes_post_response(sdf_fast, moves(kk_moves).resptime(idx_fast & idx_dd & idx_tr), lead_time);
    sdf_all = remove_spikes_post_response(sdf_all, moves(kk_moves).resptime((idx_acc|idx_fast) & idx_dd & idx_tr), lead_time);
    
    SDF_vs_dir(jj,kk).acc = nanmean(sdf_acc)';
    SDF_vs_dir(jj,kk).fast = nanmean(sdf_fast)';
    SDF_vs_dir(jj,kk).all = nanmean(sdf_all)';
    
  end%for:directions(jj)
  
end%for:cells(kk)

end%utility:util_compute_SDF_vs_dir()

