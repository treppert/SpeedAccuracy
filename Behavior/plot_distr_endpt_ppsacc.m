function [ ] = plot_distr_endpt_ppsacc( binfo , movesPP )
%plot_distr_endpt_ppsacc Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(binfo);

xFinPP = [];
yFinPP = [];

tmp = zeros(1,NUM_SESSION);
numPP = struct('T',tmp, 'D',tmp, 'F',tmp);

for kk = 1:NUM_SESSION
  
  %index by condition
  idxCond = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  %skip trials with no recorded post-primary saccade
  idxNoPP = (movesPP(kk).resptime == 0);
  
  %isolate saccade endpoint data
  xfinPP_ = movesPP(kk).x_fin(idxCond & idxErr & ~idxNoPP);
  yfinPP_ = movesPP(kk).y_fin(idxCond & idxErr & ~idxNoPP);
  
  %determine location of singleton relative to absolute right
  th_tgt = convert_tgt_octant_to_angle(binfo(kk).tgt_octant((idxCond & idxErr & ~idxNoPP)));
  %rotate post-primary saccade trajectory according to singleton loc.
  xtmp = cos(2*pi-th_tgt) .* xfinPP_ - sin(2*pi-th_tgt) .* yfinPP_;
  ytmp = sin(2*pi-th_tgt) .* xfinPP_ + cos(2*pi-th_tgt) .* yfinPP_;
  
  xFinPP = cat(2, xFinPP, xtmp);
  yFinPP = cat(2, yFinPP, ytmp);
  
  %save number of PP saccades to target, distractor, and fixation
  numPP.T(kk) = sum(movesPP(kk).endpt == 1);
  numPP.D(kk) = sum(movesPP(kk).endpt == 2);
  numPP.F(kk) = sum(movesPP(kk).endpt == 3);
  
  rfinPP_ = sqrt(xfinPP_.*xfinPP_ + yfinPP_.*yfinPP_);
  dOctPP_ = movesPP(kk).octant(idxCond & idxErr & ~idxNoPP) - uint16(binfo(kk).tgt_octant(idxCond & idxErr & ~idxNoPP));
  
end%for:session(kk)


%% Plotting

%polar distribution of endpoints
TH_PPSACC = atan2(yFinPP, xFinPP);
R_PPSACC = sqrt(xFinPP.*xFinPP + yFinPP.*yFinPP);

figure(); polaraxes()
polarscatter(TH_PPSACC, R_PPSACC, 40, [.3 .3 .3], 'filled', 'MarkerFaceAlpha',0.5)
rlim([0 10]); rticklabels([]); thetaticks([])
ppretty()

%barplot
figure(); hold on
bar(4:6, [sum([numPP.F]) sum([numPP.D]) sum([numPP.T])], 'FaceColor',[.4 .4 .4]); %xticks(1:3)
ppretty('image_size',[2,3])

end%fxn:plot_distr_endpt_ppsacc()
