function [ movesPP ] = plot_distr_endpt_ppsacc( binfo , movesPP )
%plot_distr_endpt_ppsacc Summary of this function goes here
%   Detailed explanation goes here

ROTATE_TGT_LOCATION = true;
NUM_SESSION = length(binfo);

xfin_ppsacc = [];
yfin_ppsacc = [];

count_ppsacc_endpt = struct('T',0, 'D',0, 'F',0); %for barplot

for kk = 1:NUM_SESSION
  
  %skip trials with no recorded post-primary saccade
  idx_noPP = (movesPP(kk).resptime == 0);
  
  %index by condition
  idx_cond = (binfo(kk).condition == 3);
  
  %index by trial outcome
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %isolate saccade endpoint data
  xfinPP_ = movesPP(kk).x_fin(idx_cond & idx_errdir & ~idx_noPP);
  yfinPP_ = movesPP(kk).y_fin(idx_cond & idx_errdir & ~idx_noPP);
  
  if (ROTATE_TGT_LOCATION)
    %determine location of singleton relative to absolute right
    th_tgt = convert_tgt_octant_to_angle(binfo(kk).tgt_octant((idx_cond & idx_errdir & ~idx_noPP)));
    %rotate post-primary saccade trajectory according to singleton loc.
    xtmp = cos(2*pi-th_tgt) .* xfinPP_ - sin(2*pi-th_tgt) .* yfinPP_;
    ytmp = sin(2*pi-th_tgt) .* xfinPP_ + cos(2*pi-th_tgt) .* yfinPP_;
    
    xfin_ppsacc = cat(2, xfin_ppsacc, xtmp);
    yfin_ppsacc = cat(2, yfin_ppsacc, ytmp);
  else %no rotation -- absolute endpoint location
    xfin_ppsacc = cat(2, xfin_ppsacc, xfinPP_);
    yfin_ppsacc = cat(2, yfin_ppsacc, yfinPP_);
  end
  
  %% Characterize post-primary saccade as to T, to D, or to F
  rfinPP_ = sqrt(xfinPP_.*xfinPP_ + yfinPP_.*yfinPP_);
  dOctPP_ = movesPP(kk).octant(idx_cond & idx_errdir & ~idx_noPP) - uint16(binfo(kk).tgt_octant(idx_cond & idx_errdir & ~idx_noPP));
  
  idxFix = (rfinPP_ < 3.0);
  idxTgt = (~idxFix & (dOctPP_ == 0));
  idxDistr = (~idxFix & (dOctPP_ ~= 0));
  fprintf('%d\n', sum(idxDistr))
  count_ppsacc_endpt.F = count_ppsacc_endpt.F + sum(idxFix);
  count_ppsacc_endpt.T = count_ppsacc_endpt.T + sum(idxTgt);
  count_ppsacc_endpt.D = count_ppsacc_endpt.D + sum(idxDistr);
  
  %save for future trial indexing
  trialPP_ = find(idx_cond & idx_errdir & ~idx_noPP);
  movesPP(kk).endpt = zeros(1,binfo(kk).num_trials);
  movesPP(kk).endpt(trialPP_(idxTgt)) = 1;
  movesPP(kk).endpt(trialPP_(idxDistr)) = 2;
  movesPP(kk).endpt(trialPP_(idxFix)) = 3;
  
end%for:session(kk)

%% Plotting

%polar distribution of endpoints
TH_PPSACC = atan2(yfin_ppsacc, xfin_ppsacc);
R_PPSACC = sqrt(xfin_ppsacc.*xfin_ppsacc + yfin_ppsacc.*yfin_ppsacc);

% figure(); polaraxes()
% polarscatter(TH_PPSACC, R_PPSACC, 10.0, [.2 .2 .2])
% rlim([0 10]); rticklabels([]); thetaticks([])
% ppretty()

%barplot
yy_bar = [count_ppsacc_endpt.F count_ppsacc_endpt.D count_ppsacc_endpt.T];

figure(); hold on
bar(4:6, yy_bar, 'FaceColor',[.4 .4 .4]); %xticks(1:3)
ppretty('image_size',[2,3])

end%fxn:plot_distr_endpt_ppsacc()
