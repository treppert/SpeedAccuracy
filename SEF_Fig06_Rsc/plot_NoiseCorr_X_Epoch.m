% function [ ] = plot_NoiseCorr_X_Epoch( rNoise )
%plot_NoiseCorr_X_Epoch Summary of this function goes here

%% Post-processing of noise correlations
rAccMat.SC = [];    rAccMat.FEF = [];
rFastMat.SC = [];   rFastMat.FEF = [];

nPairSC = 0;
nPairFEF = 0;

for kk = 1:16
  Area    = string(rNoise.Acc(kk).Area);
  FxnType = string(rNoise.Acc(kk).FxnType);
  RF      = rNoise.Acc(kk).RF;
  
  iSC = find(ismember(Area, "SC"));   nSC  = length(iSC);
  iFEF = find(ismember(Area, "FEF")); nFEF = length(iFEF);
  iSEF = find(ismember(Area, "SEF")); nSEF = length(iSEF);

  %Functional classification - FEF/SC
  iVis = find(ismember(FxnType, "V"));
  iVM = find(ismember(FxnType, "VM"));
  iMov = find(ismember(FxnType, "M"));
  iFxnVM = iMov; %FEF/SC fxn to include

  %Functional classification - SEF
  iErr = cell2mat( cellfun(@(x) sum(ismember(x,'CT')), FxnType, 'UniformOutput', false) );
  iErr = find(iErr);

  nPairSC_kk = nSC * nSEF;
  nPairFEF_kk = nFEF * nSEF;
  
  %% SEF - SC
  rAcc_kk = NaN(nSC*nSEF,4);
  rFast_kk = rAcc_kk;
  for ii = 1:nSC
    mm = iSC(ii);
    if ~ismember(mm, iFxnVM); nPairSC_kk = nPairSC_kk-nSEF; continue; end %check SC functional type
    rfSC = RF{mm}; %RF SC
    for jj = 1:nSEF
      nn = iSEF(jj);
      if ismember(nn, iErr); nPairSC_kk = nPairSC_kk-1; continue; end %check SEF functional type
      rfSEF = RF{nn}; %RF SEF
      % if isempty(intersect(rfSC,rfSEF)); nPairSC_kk = nPairSC_kk-1; continue; end %check for RF overlap
      rAcc_kk(nSEF*(ii-1)+jj,:) = [ rNoise.Acc(kk).BL(mm,nn) rNoise.Acc(kk).VR(mm,nn) ...
        rNoise.Acc(kk).PS(mm,nn) rNoise.Acc(kk).PR(mm,nn) ]; %Accurate
      rFast_kk(nSEF*(ii-1)+jj,:) = [ rNoise.Fast(kk).BL(mm,nn) rNoise.Fast(kk).VR(mm,nn) ...
        rNoise.Fast(kk).PS(mm,nn) rNoise.Fast(kk).PR(mm,nn) ]; %Fast
    end % for : iSEF (jj)
  end % for : iSC (ii)

  rAccMat.SC = cat(1, rAccMat.SC, rAcc_kk);
  rFastMat.SC = cat(1, rFastMat.SC, rFast_kk);
  nPairSC = nPairSC + nPairSC_kk;

  %% SEF - FEF
  rAcc_kk = NaN(nFEF*nSEF,4);
  rFast_kk = rAcc_kk;
  for ii = 1:nFEF
    mm = iFEF(ii);
    if ~ismember(mm, iFxnVM); nPairFEF_kk = nPairFEF_kk-nSEF; continue; end %check FEF functional type
    rfFEF = RF{mm}; %RF FEF
    for jj = 1:nSEF
      nn = iSEF(jj);
      if ismember(nn, iErr); nPairFEF_kk = nPairFEF_kk-1; continue; end %check SEF functional type
      rfSEF = RF{nn}; %RF SEF
      % if isempty(intersect(rfFEF,rfSEF)); nPairFEF_kk = nPairFEF_kk-1; continue; end %check for RF overlap
      rAcc_kk(nSEF*(ii-1)+jj,:) = [ rNoise.Acc(kk).BL(mm,nn) rNoise.Acc(kk).VR(mm,nn) ...
        rNoise.Acc(kk).PS(mm,nn) rNoise.Acc(kk).PR(mm,nn) ]; %Accurate
      rFast_kk(nSEF*(ii-1)+jj,:) = [ rNoise.Fast(kk).BL(mm,nn) rNoise.Fast(kk).VR(mm,nn) ...
        rNoise.Fast(kk).PS(mm,nn) rNoise.Fast(kk).PR(mm,nn) ]; %Fast
    end % for : iSEF (jj)
  end % for : iSC (ii)

  rAccMat.FEF = cat(1, rAccMat.FEF, rAcc_kk);
  rFastMat.FEF = cat(1, rFastMat.FEF, rFast_kk);
  nPairFEF = nPairFEF + nPairFEF_kk;

end % for : session (kk)

rAccSC.Mean = mean(rAccMat.SC,1, "omitnan");      rAccSC.SD = std(rAccMat.SC,0,1, "omitnan");
rFastSC.Mean = mean(rFastMat.SC,1, "omitnan");    rFastSC.SD = std(rFastMat.SC,0,1, "omitnan");

rAccFEF.Mean = mean(rAccMat.FEF,1, "omitnan");      rAccFEF.SD = std(rAccMat.FEF,0,1, "omitnan");
rFastFEF.Mean = mean(rFastMat.FEF,1, "omitnan");    rFastFEF.SD   = std(rFastMat.FEF,0,1, "omitnan");

%% Plotting
GREEN = [0 .7 0];
XLIM = [0.8 4.20001];
XTICKS = 1:4;

hFig = figure("Visible","on"); hold on
plot(rAccSC.Mean, 'Color','r', 'LineStyle','-', 'LineWidth',2)
plot(rFastSC.Mean, 'Color',GREEN, 'LineStyle','-', 'LineWidth',2)
plot(rAccFEF.Mean, 'Color','r', 'LineStyle','-', 'LineWidth',1)
plot(rFastFEF.Mean, 'Color',GREEN, 'LineStyle','-', 'LineWidth',1)
yline(0)
ytickformat('%3.2f'); ylabel('Noise correlation')
xlim(XLIM); xticks(XTICKS); xticklabels({'BL','VR','PS','PR'})

ppretty([3.2,1.4]); drawnow
text(4,rAccSC.Mean(4),  num2str(nPairSC));  text(4,rFastSC.Mean(4),  num2str(nPairSC))
text(4,rAccFEF.Mean(4), num2str(nPairFEF)); text(4,rFastFEF.Mean(4), num2str(nPairFEF))

% end % fxn : plot_NoiseCorr_X_Epoch()

clearvars -except behavData unitData pairData spkCorr ROOTDIR* rNoise r*Mat
