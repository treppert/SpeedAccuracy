function [ ] = Fig3B_EndptSS_Distr( behavData )
%Fig3B_EndptSS_Distr Summary of this function goes here
%   Detailed explanation goes here

MONKEY = {'D','E'};
sessKeep = (ismember(behavData.Monkey, MONKEY) & behavData.Task_RecordedSEF);
NUM_SESSION = sum(sessKeep);   behavData = behavData(sessKeep, :);

TGT_ECCEN = 8; %use a consistent eccentricity for plotting

xFinPP = [];
yFinPP = [];

for kk = 1:NUM_SESSION
  
  %use a consistent target eccentricity
  if (behavData.Task_TgtEccen{kk}(100) ~= TGT_ECCEN); continue; end
  
  %index by saccade clipping
  idxClipped = (behavData.Sacc2_Clipped{kk});
  %index by condition
  idxCond = (behavData.Task_SATCondition{kk} == 3 | behavData.Task_SATCondition{kk} == 1);
  %index by trial outcome
  idxErr = (behavData.Task_ErrChoice{kk} & ~behavData.Task_ErrTime{kk});
  %skip trials with no recorded post-primary saccade
  idxNoPP = (behavData.Sacc2_RT{kk} == 0);
  
  %isolate saccade endpoint data
  xfinPP_ = behavData.Sacc2_XFinal{kk}(idxCond & idxErr & ~idxNoPP & ~idxClipped);
  yfinPP_ = behavData.Sacc2_YFinal{kk}(idxCond & idxErr & ~idxNoPP & ~idxClipped);
  
  %determine location of singleton relative to absolute right
  th_tgt = convert_tgt_octant_to_angle(behavData.Task_TgtOctant{kk}(idxCond & idxErr & ~idxNoPP & ~idxClipped));
  %rotate post-primary saccade trajectory according to singleton loc.
  xtmp = cos(2*pi-th_tgt) .* xfinPP_ - sin(2*pi-th_tgt) .* yfinPP_;
  ytmp = sin(2*pi-th_tgt) .* xfinPP_ + cos(2*pi-th_tgt) .* yfinPP_;
  
  xFinPP = cat(2, xFinPP, xtmp);
  yFinPP = cat(2, yFinPP, ytmp);
  
end%for:session(kk)


%% Plotting

%polar distribution of endpoints
TH_PPSACC = atan2(yFinPP, xFinPP);
R_PPSACC = sqrt(xFinPP.*xFinPP + yFinPP.*yFinPP);

figure(); polaraxes()
polarscatter(TH_PPSACC, R_PPSACC, 40, [.3 .3 .3], 'filled', 'MarkerFaceAlpha',0.3)
rlim([0 10]); thetaticks([])
ppretty([5,5])

end%fxn:Fig3B_EndptSS_Distr()