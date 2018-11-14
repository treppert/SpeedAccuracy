function [] = plot_polar_distr_ppsacc_endpt( binfo , movesAll )
%plot_polar_distr_ppsacc_endpt Summary of this function goes here
%   Detailed explanation goes here

ROTATE_TGT_LOCATION = true;
INDEX = 2; %index of saccade post-primary
NUM_SESSION = length(binfo);

xfin_ppsacc = [];
yfin_ppsacc = [];

for kk = 1:NUM_SESSION
  
  %index trials by condition and trial outcome
  idx_fast = (binfo(kk).condition == 1);
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  trial_errdir = find(idx_fast & idx_errdir);
  
  %index saccades by number from primary saccade
  idxAll_ppsacc = (ismember(movesAll(kk).trial, trial_errdir) & (movesAll(kk).index == INDEX));
  
  %only take trials for which we have a post-primary saccade
  trial_errdir = movesAll(kk).trial(idxAll_ppsacc);
  
  if (ROTATE_TGT_LOCATION)
    %determine location of singleton relative to absolute right
    th_tgt = convert_tgt_octant_to_angle(binfo(kk).tgt_octant(trial_errdir));
    %rotate post-primary saccade trajectory according to singleton loc.
    xtmp = cos(2*pi-th_tgt) .* movesAll(kk).x_fin(idxAll_ppsacc) - sin(2*pi-th_tgt) .* movesAll(kk).y_fin(idxAll_ppsacc);
    ytmp = sin(2*pi-th_tgt) .* movesAll(kk).x_fin(idxAll_ppsacc) + cos(2*pi-th_tgt) .* movesAll(kk).y_fin(idxAll_ppsacc);
    
    xfin_ppsacc = cat(2, xfin_ppsacc, xtmp);
    yfin_ppsacc = cat(2, yfin_ppsacc, ytmp);
  else %no rotation -- absolute endpoint location
    xfin_ppsacc = cat(2, xfin_ppsacc, movesAll(kk).x_fin(idxAll_ppsacc));
    yfin_ppsacc = cat(2, yfin_ppsacc, movesAll(kk).y_fin(idxAll_ppsacc));
  end
  
end%for:session(kk)

TH_PPSACC = atan2(yfin_ppsacc, xfin_ppsacc);
R_PPSACC = sqrt(xfin_ppsacc.*xfin_ppsacc + yfin_ppsacc.*yfin_ppsacc);

figure(); polaraxes()
polarscatter(TH_PPSACC, R_PPSACC, 10.0, [.2 .2 .2])
rlim([0 10]); rticklabels([]); thetaticks([])
ppretty()

end%fxn:plot_polar_distr_ppsacc_endpt()
