function [ ] = Fig3B_EndptSS_Distr( behavData )
%Fig3B_EndptSS_Distr Summary of this function goes here
%   Detailed explanation goes here

sessKeep = (ismember(behavData.Monkey, {'D','E'}) & behavData.Task_RecordedSEF);
behavData = behavData(sessKeep, :);
NUM_SESS = sum(sessKeep);

TGT_ECCEN = 8; %use a constant eccentricity for plotting

%initializations
XFinPP_Fast = cell(2,NUM_SESS); %distribution
XFinPP_Acc  = cell(2,NUM_SESS);
Ptgt_Acc = NaN(1,NUM_SESS); %average (barplot)
Ptgt_Fast = NaN(1,NUM_SESS);

for kk = 1:NUM_SESS
  
  Tgt_Eccen_kk = unique(behavData.Task_TgtEccen{kk});
  
  %index by saccade clipping
  idxClipped = (behavData.Sacc2_Endpoint{kk} == 0);
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  %index by trial outcome
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  %skip trials with no recorded post-primary saccade
  idxNoPP = (behavData.Sacc2_RT{kk} == 0);
  
  %compute proportion of corrective saccades (i.e., saccade to target)
  idxTgt = (behavData.Sacc2_Endpoint{kk} == 1);
  idxAll = ismember(behavData.Sacc2_Endpoint{kk}, [1,2,3]); %tgt, distr or fixation
  Ptgt_Acc(kk) = sum(idxAcc & idxErr & idxTgt) / sum(idxAcc & idxErr & idxAll);
  Ptgt_Fast(kk) = sum(idxFast & idxErr & idxTgt) / sum(idxFast & idxErr & idxAll);
  
  %isolate saccade endpoint data
  Xfin_Fast = transpose(behavData.Sacc2_X_fin{kk}(idxFast & idxErr & ~idxNoPP & ~idxClipped, :));
  Xfin_Acc  = transpose(behavData.Sacc2_X_fin{kk}(idxAcc  & idxErr & ~idxNoPP & ~idxClipped, :));
  
  %determine location of singleton relative to absolute right
  th_tgt_Fast = convert_tgt_octant_to_angle(behavData.Task_TgtOctant{kk}(idxFast & idxErr & ~idxNoPP & ~idxClipped));
  th_tgt_Acc  = convert_tgt_octant_to_angle(behavData.Task_TgtOctant{kk}(idxAcc  & idxErr & ~idxNoPP & ~idxClipped));
  
  %convert to polar to scale radial position to TGT_ECCEN
  [thFin_Fast,rFin_Fast] = cart2pol(Xfin_Fast(1,:), Xfin_Fast(2,:));
  rFin_Fast = rFin_Fast * (TGT_ECCEN / Tgt_Eccen_kk);
  [thFin_Acc,rFin_Acc] = cart2pol(Xfin_Acc(1,:), Xfin_Acc(2,:));
  rFin_Acc = rFin_Acc * (TGT_ECCEN / Tgt_Eccen_kk);
  
  %convert back to Cartesian coordinates
  [xfin_Fast,yfin_Fast] = pol2cart(thFin_Fast, rFin_Fast);
  Xfin_Fast(1,:) = xfin_Fast;  Xfin_Fast(2,:) = yfin_Fast;
  [xfin_Acc,yfin_Acc] = pol2cart(thFin_Acc, rFin_Acc);
  Xfin_Acc(1,:) = xfin_Acc;    Xfin_Acc(2,:) = yfin_Acc;
  
  %rotate post-primary saccade trajectory according to singleton loc.
  XFinPP_Fast{1,kk} = cos(2*pi-th_tgt_Fast) .* Xfin_Fast(1,:) - sin(2*pi-th_tgt_Fast) .* Xfin_Fast(2,:); %Fast
  XFinPP_Fast{2,kk} = sin(2*pi-th_tgt_Fast) .* Xfin_Fast(1,:) + cos(2*pi-th_tgt_Fast) .* Xfin_Fast(2,:);
  XFinPP_Acc{1,kk}  = cos(2*pi-th_tgt_Acc) .* Xfin_Acc(1,:) - sin(2*pi-th_tgt_Acc) .* Xfin_Acc(2,:); %Accurate
  XFinPP_Acc{2,kk}  = sin(2*pi-th_tgt_Acc) .* Xfin_Acc(1,:) + cos(2*pi-th_tgt_Acc) .* Xfin_Acc(2,:);
  
end%for:session(kk)

%combine data across recording sessions
XFinPP_Fast = [ transpose([XFinPP_Fast{1,1:end}]) , transpose([XFinPP_Fast{2,1:end}]) ];
XFinPP_Acc  = [ transpose([XFinPP_Acc{1,1:end}])  , transpose([XFinPP_Acc{2,1:end}]) ];

%% Plotting - Distribution
TH_PPSACC_Fast = atan2(XFinPP_Fast(:,2), XFinPP_Fast(:,1));
TH_PPSACC_Acc  = atan2(XFinPP_Acc(:,2), XFinPP_Acc(:,1));
R_PPSACC_Fast = sqrt(XFinPP_Fast(:,1).*XFinPP_Fast(:,1) + XFinPP_Fast(:,2).*XFinPP_Fast(:,2));
R_PPSACC_Acc  = sqrt(XFinPP_Acc(:,1).*XFinPP_Acc(:,1) + XFinPP_Acc(:,2).*XFinPP_Acc(:,2));

figure()
subplot(1,2,1,polaraxes)
polarscatter(TH_PPSACC_Fast, R_PPSACC_Fast, 30, [0 .7 0], 'filled', 'MarkerFaceAlpha',0.1)
rlim([0 10]); thetaticks([])
title('Fast', 'FontSize',10)

subplot(1,2,2,polaraxes)
polarscatter(TH_PPSACC_Acc, R_PPSACC_Acc, 30, 'r', 'filled', 'MarkerFaceAlpha',0.1)
rlim([0 10]); thetaticks([])
title('Accurate', 'FontSize',10)

ppretty([5,3])

%% Plotting - Barplot
muTgt_Acc = mean(Ptgt_Acc);         seTgt_Acc = std(Ptgt_Acc) / sqrt(NUM_SESS);
muTgt_Fast = mean(Ptgt_Fast);       seTgt_Fast = std(Ptgt_Fast) / sqrt(NUM_SESS);

figure(); hold on
bar([1 2], [muTgt_Acc muTgt_Fast], 0.4, 'FaceColor','none', 'LineWidth',0.5)
errorbar([1 2], [muTgt_Acc muTgt_Fast], [seTgt_Acc seTgt_Fast], 'Color','k', 'CapSize',0)
xticks([1 2]); xticklabels({'A','F'}); ytickformat('%2.1f')
ylabel('Pr. (Sacc. to target)')
ppretty([2,2])

%stats -- paired t-test
ttestFull(Ptgt_Acc, Ptgt_Fast)

end%fxn:Fig3B_EndptSS_Distr()