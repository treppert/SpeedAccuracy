function [ ninfo ] = compute_baseline_stats_SAT( binfo , ninfo , spikes )
%compute_visresp_mag_SAT Summary of this function goes here
%   Detailed explanation goes here

ALPHA_MANN_WHITNEY_U = 0.05;

NUM_CELLS = length(ninfo);
TIME_BLINE = (-700:-1) + 3500; %time re. array appearance

ninfo = populate_struct(ninfo, {'bline_mu_A','bline_mu_F','bline_sd_A','bline_sd_F'}, NaN);

for cc = 1:NUM_CELLS
  kk = find(ismember({binfo.session}, ninfo(cc).sess));
  idx_nan = false(1,binfo(kk).num_trials); %initialize NaN indexing for this cell
  
  %identify neurons to be removed based on poor spike isolation
  if (ninfo(cc).iRem1 == 9999); continue; end
  
  idx_A = (binfo(kk).condition == 1);
  idx_F = (binfo(kk).condition == 3);
  
  %count spikes during baseline interval
  num_sp_bline = NaN(1,binfo(kk).num_trials);
  for jj = 1:binfo(kk).num_trials
    num_sp_bline(jj) = sum((spikes(cc).SAT{jj} > TIME_BLINE(1)) & (spikes(cc).SAT{jj} > TIME_BLINE(end)));
  end
  
  %check for trials to be removed based on poor spike isolation
  if (ninfo(cc).iRem1)
    idx_nan(ninfo(cc).iRem1 : ninfo(cc).iRem2) = true;
  end
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold | idx_nan);
  
  num_sp_A = num_sp_bline(idx_corr & idx_A);
  num_sp_F = num_sp_bline(idx_corr & idx_F);
  
  ninfo(cc).bline_mean_A =  mean(num_sp_A);
  ninfo(cc).bline_mean_F =  mean(num_sp_F);
  ninfo(cc).bline_sd_A =  std(num_sp_A);
  ninfo(cc).bline_sd_F =  std(num_sp_F);
  
  %compare activity on ACC and FAST trials with a Mann-Whitney U test
  pval_cc = ranksum(num_sp_A,num_sp_F, 'tail','both');
  
  if (pval_cc < ALPHA_MANN_WHITNEY_U)
    if (mean(num_sp_A) > mean(num_sp_F))
      ninfo(cc).bline_SAT_pref = 'A';
    else
      ninfo(cc).bline_SAT_pref = 'F';
    end
  else
    ninfo(cc).bline_SAT_pref = 'N';
  end
  
end%for:cells(cc)

end%util:compute_visresp_mag_SAT()


