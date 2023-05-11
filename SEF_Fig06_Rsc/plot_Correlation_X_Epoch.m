%plot_Correlation_X_Epoch.m

ABSOLUTE = false; %compute |r| instead of r

%% Post-processing of correlations
rNoiseMat.Acc.SC = [];    rNoiseMat.Acc.FEF = [];
rNoiseMat.Fast.SC = [];   rNoiseMat.Fast.FEF = [];

rSignalMat.Acc.SC = [];    rSignalMat.Acc.FEF = [];
rSignalMat.Fast.SC = [];   rSignalMat.Fast.FEF = [];

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
  rNoise_kk.Acc = NaN(nSC*nSEF,4); % {BL,VR,PS,PR}
  rNoise_kk.Fast = rNoise_kk.Acc;
  rSignal_kk.Acc  = NaN(nSC*nSEF,2); % {VR,PS}
  rSignal_kk.Fast = rSignal_kk.Acc;

  for ii = 1:nSC
    mm = iSC(ii);
    if ~ismember(mm, iFxnVM); nPairSC_kk = nPairSC_kk-nSEF; continue; end %check SC functional type
    rfSC = RF{mm}; %RF SC
    for jj = 1:nSEF
      nn = iSEF(jj);
      % if ismember(nn, iErr); nPairSC_kk = nPairSC_kk-1; continue; end %check SEF functional type
      rfSEF = RF{nn}; %RF SEF
      % if isempty(intersect(rfSC,rfSEF)); nPairSC_kk = nPairSC_kk-1; continue; end %check for RF overlap

      rNoise_kk.Acc(nSEF*(ii-1)+jj,:) = [ rNoise.Acc(kk).BL(mm,nn) rNoise.Acc(kk).VR(mm,nn) ...
        rNoise.Acc(kk).PS(mm,nn) rNoise.Acc(kk).PR(mm,nn) ]; %Accurate
      rNoise_kk.Fast(nSEF*(ii-1)+jj,:) = [ rNoise.Fast(kk).BL(mm,nn) rNoise.Fast(kk).VR(mm,nn) ...
        rNoise.Fast(kk).PS(mm,nn) rNoise.Fast(kk).PR(mm,nn) ]; %Fast

      rSignal_kk.Acc(nSEF*(ii-1)+jj,:)  = [ rSignal(kk).Acc.VR(mm,nn) rSignal(kk).Acc.PS(mm,nn) ]; %Accurate
      rSignal_kk.Fast(nSEF*(ii-1)+jj,:) = [ rSignal(kk).Fast.VR(mm,nn) rSignal(kk).Fast.PS(mm,nn) ]; %Fast

    end % for : iSEF (jj)

  end % for : iSC (ii)

  rNoiseMat.Acc.SC = cat(1, rNoiseMat.Acc.SC, rNoise_kk.Acc);
  rNoiseMat.Fast.SC = cat(1, rNoiseMat.Fast.SC, rNoise_kk.Fast);
  rSignalMat.Acc.SC = cat(1, rSignalMat.Acc.SC, rSignal_kk.Acc);
  rSignalMat.Fast.SC = cat(1, rSignalMat.Fast.SC, rSignal_kk.Fast);
  nPairSC = nPairSC + nPairSC_kk;

  %% SEF - FEF
  rNoise_kk.Acc = NaN(nFEF*nSEF,4);
  rNoise_kk.Fast = rNoise_kk.Acc;
  rSignal_kk.Acc  = NaN(nFEF*nSEF,2); % {VR,PS}
  rSignal_kk.Fast = rSignal_kk.Acc;
  
  for ii = 1:nFEF
    mm = iFEF(ii);
    if ~ismember(mm, iFxnVM); nPairFEF_kk = nPairFEF_kk-nSEF; continue; end %check FEF functional type
    rfFEF = RF{mm}; %RF FEF
    for jj = 1:nSEF
      nn = iSEF(jj);
      % if ismember(nn, iErr); nPairFEF_kk = nPairFEF_kk-1; continue; end %check SEF functional type
      rfSEF = RF{nn}; %RF SEF
      % if isempty(intersect(rfFEF,rfSEF)); nPairFEF_kk = nPairFEF_kk-1; continue; end %check for RF overlap

      rNoise_kk.Acc(nSEF*(ii-1)+jj,:) = [ rNoise.Acc(kk).BL(mm,nn) rNoise.Acc(kk).VR(mm,nn) ...
        rNoise.Acc(kk).PS(mm,nn) rNoise.Acc(kk).PR(mm,nn) ]; %Accurate
      rNoise_kk.Fast(nSEF*(ii-1)+jj,:) = [ rNoise.Fast(kk).BL(mm,nn) rNoise.Fast(kk).VR(mm,nn) ...
        rNoise.Fast(kk).PS(mm,nn) rNoise.Fast(kk).PR(mm,nn) ]; %Fast

      rSignal_kk.Acc(nSEF*(ii-1)+jj,:)  = [ rSignal(kk).Acc.VR(mm,nn) rSignal(kk).Acc.PS(mm,nn) ]; %Accurate
      rSignal_kk.Fast(nSEF*(ii-1)+jj,:) = [ rSignal(kk).Fast.VR(mm,nn) rSignal(kk).Fast.PS(mm,nn) ]; %Fast

    end % for : iSEF (jj)
  end % for : iSC (ii)

  rNoiseMat.Acc.FEF = cat(1, rNoiseMat.Acc.FEF, rNoise_kk.Acc);
  rNoiseMat.Fast.FEF = cat(1, rNoiseMat.Fast.FEF, rNoise_kk.Fast);
  rSignalMat.Acc.FEF = cat(1, rSignalMat.Acc.FEF, rSignal_kk.Acc);
  rSignalMat.Fast.FEF = cat(1, rSignalMat.Fast.FEF, rSignal_kk.Fast);
  nPairFEF = nPairFEF + nPairFEF_kk;

end % for : session (kk)

if (ABSOLUTE)
  rNoiseMat.Acc.SC  = abs(rNoiseMat.Acc.SC);      rNoiseMat.Acc.FEF  = abs(rNoiseMat.Acc.FEF);
  rNoiseMat.Fast.SC = abs(rNoiseMat.Fast.SC);     rNoiseMat.Fast.FEF = abs(rNoiseMat.Fast.FEF);
  rSignalMat.Acc.SC  = abs(rSignalMat.Acc.SC);    rSignalMat.Acc.FEF  = abs(rSignalMat.Acc.FEF);
  rSignalMat.Fast.SC = abs(rSignalMat.Fast.SC);   rSignalMat.Fast.FEF = abs(rSignalMat.Fast.FEF);
end

%% Compute mean correlations across pairs
rAccSC.Noise.Mean = mean(rNoiseMat.Acc.SC,1, "omitnan");      rAccSC.Noise.SD = std(rNoiseMat.Acc.SC,0,1, "omitnan");
rFastSC.Noise.Mean = mean(rNoiseMat.Fast.SC,1, "omitnan");    rFastSC.Noise.SD = std(rNoiseMat.Fast.SC,0,1, "omitnan");
rAccFEF.Noise.Mean = mean(rNoiseMat.Acc.FEF,1, "omitnan");      rAccFEF.Noise.SD = std(rNoiseMat.Acc.FEF,0,1, "omitnan");
rFastFEF.Noise.Mean = mean(rNoiseMat.Fast.FEF,1, "omitnan");    rFastFEF.Noise.SD = std(rNoiseMat.Fast.FEF,0,1, "omitnan");

rAccSC.Signal.Mean = mean(rSignalMat.Acc.SC,1, "omitnan");      rAccSC.Signal.SD = std(rSignalMat.Acc.SC,0,1, "omitnan");
rFastSC.Signal.Mean = mean(rSignalMat.Fast.SC,1, "omitnan");    rFastSC.Signal.SD = std(rSignalMat.Fast.SC,0,1, "omitnan");
rAccFEF.Signal.Mean = mean(rSignalMat.Acc.FEF,1, "omitnan");      rAccFEF.Signal.SD = std(rSignalMat.Acc.FEF,0,1, "omitnan");
rFastFEF.Signal.Mean = mean(rSignalMat.Fast.FEF,1, "omitnan");    rFastFEF.Signal.SD = std(rSignalMat.Fast.FEF,0,1, "omitnan");

%% Plotting
GREEN = [0 .7 0];
LINESTYLE = ':';
OFFSET = 0.04;
xTicksNoise = 1:4;
xTicksSignal = [1 2];

hFig = figure("Visible","on");
subplot(2,3,[1 2]); title("SEF-SC"); hold on %SC - Noise correlation
errorbar(xTicksNoise-OFFSET, rAccSC.Noise.Mean,rAccSC.Noise.SD, 'Linestyle',LINESTYLE, 'Color','r', 'CapSize',0)
errorbar(xTicksNoise+OFFSET, rFastSC.Noise.Mean,rFastSC.Noise.SD, 'Linestyle',LINESTYLE, 'Color',GREEN, 'CapSize',0)
text(4.1,rAccSC.Noise.Mean(4),  num2str(nPairSC));
ytickformat('%3.2f'); ylabel('Noise correlation')
xlim([0.8 4.20001]); xticks(xTicksNoise); xticklabels({'BL','VR','PS','PR'})

subplot(2,3,3); title("SEF-SC"); hold on %SC - Signal correlation
errorbar(xTicksSignal-OFFSET, rAccSC.Signal.Mean,rAccSC.Signal.SD, 'Linestyle',LINESTYLE, 'Color','r', 'CapSize',0)
errorbar(xTicksSignal+OFFSET, rFastSC.Signal.Mean,rFastSC.Signal.SD, 'Linestyle',LINESTYLE, 'Color',GREEN, 'CapSize',0)
yline(0); ytickformat('%3.2f'); ylabel('Signal correlation')
xlim([0.8 2.20001]); xticks(xTicksSignal); xticklabels({'VR','PS'})

subplot(2,3,[4 5]); title("SEF-FEF"); hold on %FEF - Noise correlation
errorbar(xTicksNoise-OFFSET, rAccFEF.Noise.Mean,rAccFEF.Noise.SD, 'Linestyle',LINESTYLE, 'Color','r', 'CapSize',0)
errorbar(xTicksNoise+OFFSET, rFastFEF.Noise.Mean,rFastFEF.Noise.SD, 'Linestyle',LINESTYLE, 'Color',GREEN, 'CapSize',0)
text(4.1,rAccFEF.Noise.Mean(4), num2str(nPairFEF));
ytickformat('%3.2f'); ylabel('Noise correlation')
xlim([0.8 4.20001]); xticks(xTicksNoise); xticklabels({'BL','VR','PS','PR'})

subplot(2,3,6); title("SEF-FEF"); hold on %FEF - Signal correlation
errorbar(xTicksSignal-OFFSET, rAccFEF.Signal.Mean,rAccFEF.Signal.SD, 'Linestyle',LINESTYLE, 'Color','r', 'CapSize',0)
errorbar(xTicksSignal+OFFSET, rFastFEF.Signal.Mean,rFastFEF.Signal.SD, 'Linestyle',LINESTYLE, 'Color',GREEN, 'CapSize',0)
yline(0); ytickformat('%3.2f'); ylabel('Signal correlation')
xlim([0.8 2.20001]); xticks(xTicksSignal); xticklabels({'VR','PS'})
ppretty([5.2,3]); drawnow

% end % fxn : plot_NoiseCorr_X_Epoch()

clearvars -except behavData unitData pairData spkCorr ROOTDIR* rNoise* r*Mat* rSignal*
