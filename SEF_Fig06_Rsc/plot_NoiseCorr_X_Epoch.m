% function [ ] = plot_NoiseCorr_X_Epoch( rNoise )
%plot_NoiseCorr_X_Epoch Summary of this function goes here

%% Post-processing of noise correlations
rAccMat = [];
rFastMat = [];

for kk = 1:16
  Area    = string(rNoise.Acc(kk).Area);
  FxnType = string(rNoise.Acc(kk).FxnType);
  RF      = rNoise.Acc(kk).RF;
  
  iVM = find(ismember(Area, "SC"));   nVM  = length(iVM);
  iSEF = find(ismember(Area, "SEF")); nSEF = length(iSEF);
  
  rAcc_kk = NaN(nVM*nSEF,4);
  rFast_kk = rAcc_kk;
  for ii = 1:nVM
    rfVM = RF{iVM(ii)}; %response field FEF/SC
    for jj = 1:nSEF
      rfSEF = RF{iSEF(jj)}; %response field SEF
      % if isempty(intersect(rfVM,rfSEF)); continue; end %check for RF overlap
      rAcc_kk(nSEF*(ii-1)+jj,:) = [ rNoise.Acc(kk).BL(iVM(ii),iSEF(jj)) rNoise.Acc(kk).VR(iVM(ii),iSEF(jj)) ...
        rNoise.Acc(kk).PS(iVM(ii),iSEF(jj)) rNoise.Acc(kk).PR(iVM(ii),iSEF(jj)) ]; %Accurate
      rFast_kk(nSEF*(ii-1)+jj,:) = [ rNoise.Fast(kk).BL(iVM(ii),iSEF(jj)) rNoise.Fast(kk).VR(iVM(ii),iSEF(jj)) ...
        rNoise.Fast(kk).PS(iVM(ii),iSEF(jj)) rNoise.Fast(kk).PR(iVM(ii),iSEF(jj)) ]; %Fast
    end % for : iSEF (jj)
  end % for : iSC (ii)

  rAccMat = cat(1, rAccMat, rAcc_kk);
  rFastMat = cat(1, rFastMat, rFast_kk);

end % for : session (kk)

rAcc.Mean = mean(rAccMat,1, "omitnan");      rAcc.SD   = std(rAccMat,0,1, "omitnan");
rFast.Mean = mean(rFastMat,1, "omitnan");    rFast.SD   = std(rFastMat,0,1, "omitnan");

%% Plotting
GREEN = [0 .7 0];
XLIM = [0.8 4.20001];
XTICKS = 1:4;

hFig = figure("Visible","on"); hold on
plot(rAcc.Mean, 'Color','r', 'LineStyle','-')
plot(rFast.Mean, 'Color',GREEN, 'LineStyle','-')
ytickformat('%3.2f'); ylabel('Noise correlation')
xlim(XLIM); xticks(XTICKS); xticklabels({'BL','VR','PS','PR'})

ppretty([3.2,1.4]); drawnow


% end % fxn : plot_NoiseCorr_X_Epoch()

clearvars -except behavData unitData pairData spkCorr ROOTDIR* rNoise r*Mat
