function [ ninfo ] = compute_visresp_stats_SAT( binfo , ninfo , spikes )
%compute_visresp_mag_SAT Summary of this function goes here
%   Detailed explanation goes here

DEBUG = false;

NUM_CELLS = length(ninfo);
MIN_GRADE = 3; %minimum rating of visual response
TIME_VISRESP = (1:200) + 3500; %time re. array appearance

%NOTE -- NEED TO INCORPORATE TRUE ESTIMATE OF BASELINE ACTIVITY TO ESTIMATE
%VISUAL RESPONSE LATENCY
TIME_BLINE = (-700:-1) + 3500; %*****REMOVE--AD-HOC

%make sure we have baseline stats
if ~isfield(ninfo, 'bline_mean_A')
  ninfo = compute_baseline_stats_SAT(binfo, ninfo, spikes);
end

ninfo = populate_struct(ninfo, {'VR_lat_A','VR_lat_F','VR_mag_A','VR_mag_F'}, NaN);

for cc = 1:NUM_CELLS
  if (ninfo(cc).vis < MIN_GRADE); continue; end
  
  kk = find(ismember({binfo.session}, ninfo(cc).sesh));
  idx_nan = false(1,binfo(kk).num_trials); %initialize NaN indexing for this cell
  
  %identify neurons to be removed based on poor spike isolation
  if (ninfo(cc).iRem1 == 9999); continue; end
  
  idx_A = (binfo(kk).condition == 1);
  idx_F = (binfo(kk).condition == 3);
  
  %check for trials to be removed based on poor spike isolation
  if (ninfo(cc).iRem1)
    idx_nan(ninfo(cc).iRem1 : ninfo(cc).iRem2) = true;
  end
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold | idx_nan);
  
  sdf_A = compute_spike_density_fxn( spikes(cc).SAT(idx_corr & idx_A) );
  sdf_F = compute_spike_density_fxn( spikes(cc).SAT(idx_corr & idx_F) );
  
  VR_A = mean(sdf_A(:,TIME_VISRESP));
  VR_F = mean(sdf_F(:,TIME_VISRESP));
  
  if (DEBUG)
    figure(); hold on
    plot(VR_A, 'r-')
    plot(VR_F, 'g-')
  end
  
  ninfo(cc).VR_mag_A = max(VR_A);
  ninfo(cc).VR_mag_F = max(VR_F);
  
  %calculate threshold used to estimate response latency
%   thresh_lat_A = ninfo(cc).bline_mean_A + 2*ninfo(cc).bline_sd_A;
%   thresh_lat_F = ninfo(cc).bline_mean_F + 2*ninfo(cc).bline_sd_F;
  
  %calculate threshold used to estimate response latency
  sdf_BASE_A = mean(sdf_A(:,TIME_BLINE)); %*****REMOVE--AD-HOC
  sdf_BASE_F = mean(sdf_F(:,TIME_BLINE)); %*****REMOVE--AD-HOC
  thresh_lat_A = mean(sdf_BASE_A) + 5*std(sdf_BASE_A);
  thresh_lat_F = mean(sdf_BASE_F) + 5*std(sdf_BASE_F);
  
  ninfo(cc).VR_lat_A = find(VR_A > thresh_lat_A, 1, 'first');
  ninfo(cc).VR_lat_F = find(VR_F > thresh_lat_F, 1, 'first');
  
end%for:cells(cc)

end%util:compute_visresp_mag_SAT()

