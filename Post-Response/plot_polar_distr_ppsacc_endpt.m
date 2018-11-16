function [] = plot_polar_distr_ppsacc_endpt( binfo , movesAll )
%plot_polar_distr_ppsacc_endpt Summary of this function goes here
%   Detailed explanation goes here

INDEX = 2; %index of saccade post-primary

ROTATE_TGT_LOCATION = true;
NUM_SESSION = length(binfo);

xfin_ppsacc = [];
yfin_ppsacc = [];

count_ppsacc_endpt = struct('T',0, 'D',0, 'F',0); %for barplot

for kk = 1:NUM_SESSION
  
  %index trials by condition and trial outcome
  idx_cond = (binfo(kk).condition == 3);
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  trial_errdir = find(idx_cond & idx_errdir);
  
  %index saccades by number from primary saccade
  idxAll_ppsacc = (ismember(movesAll(kk).trial, trial_errdir) & (movesAll(kk).index == INDEX));
  
  %only take trials for which we have a post-primary saccade
  trial_errdir = movesAll(kk).trial(idxAll_ppsacc);
  
  xfinAll_kk = movesAll(kk).x_fin(idxAll_ppsacc);
  yfinAll_kk = movesAll(kk).y_fin(idxAll_ppsacc);
  rfinAll_kk = sqrt(xfinAll_kk.*xfinAll_kk + yfinAll_kk.*yfinAll_kk);
  diffOctAll_kk = movesAll(kk).octant(idxAll_ppsacc) - uint16(binfo(kk).tgt_octant(trial_errdir));
  
  if (ROTATE_TGT_LOCATION)
    %determine location of singleton relative to absolute right
    th_tgt = convert_tgt_octant_to_angle(binfo(kk).tgt_octant(trial_errdir));
    %rotate post-primary saccade trajectory according to singleton loc.
    xtmp = cos(2*pi-th_tgt) .* xfinAll_kk - sin(2*pi-th_tgt) .* yfinAll_kk;
    ytmp = sin(2*pi-th_tgt) .* xfinAll_kk + cos(2*pi-th_tgt) .* yfinAll_kk;
    
    xfin_ppsacc = cat(2, xfin_ppsacc, xtmp);
    yfin_ppsacc = cat(2, yfin_ppsacc, ytmp);
  else %no rotation -- absolute endpoint location
    xfin_ppsacc = cat(2, xfin_ppsacc, xfinAll_kk);
    yfin_ppsacc = cat(2, yfin_ppsacc, yfinAll_kk);
  end
  
  %characterize post-primary saccade as to T, to D, or to F
  idx_Fix = (rfinAll_kk < 3.0);
  idx_Tgt = (~idx_Fix & (diffOctAll_kk == 0));
  idx_Distr = (~idx_Fix & (diffOctAll_kk ~= 0));
  
  count_ppsacc_endpt.F = count_ppsacc_endpt.F + sum(idx_Fix);
  count_ppsacc_endpt.T = count_ppsacc_endpt.T + sum(idx_Tgt);
  count_ppsacc_endpt.D = count_ppsacc_endpt.D + sum(idx_Distr);
  
end%for:session(kk)

%% Plotting

%polar distribution of endpoints
TH_PPSACC = atan2(yfin_ppsacc, xfin_ppsacc);
R_PPSACC = sqrt(xfin_ppsacc.*xfin_ppsacc + yfin_ppsacc.*yfin_ppsacc);

figure(); polaraxes()
polarscatter(TH_PPSACC, R_PPSACC, 10.0, [.2 .2 .2])
rlim([0 10]); rticklabels([]); thetaticks([])
ppretty()

%barplot
yy_bar = [count_ppsacc_endpt.F count_ppsacc_endpt.D count_ppsacc_endpt.T];

figure(); hold on
bar(4:6, yy_bar, 'FaceColor',[.4 .4 .4]); %xticks(1:3)
ppretty('image_size',[2,3])

end%fxn:plot_polar_distr_ppsacc_endpt()
