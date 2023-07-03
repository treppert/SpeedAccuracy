%plot_NoiseCorr_X_Direction.m
% 

kk = 1; %index struct rNoise
nUnit = numel(rNoise(kk).Unit);
nPair = nUnit*(nUnit-1) / 2;

VECDIR = [0 45 90 135 180 225 270 315]';
hFig = figure('Visible','on');
iPair = 0;

EPOCH = 'VR';

for xx = 1:nUnit-1
  for yy = xx+1:nUnit

    uX = rNoise(kk).Unit(xx);
    uY = rNoise(kk).Unit(yy);
    iPair = iPair + 1;

    sess = rNoise(kk).Session;
    idX = unitData.UnitID{uX};
    idY = unitData.UnitID{uY};
    strPair = "Units " + idX + " & " + idY;

    rAcc  = squeeze( rNoise(kk).Acc.(EPOCH)(xx,yy,:) );
    rFast = squeeze( rNoise(kk).Fast.(EPOCH)(xx,yy,:) );

    subplot(nPair,1,iPair); hold on
    if (iPair == 1); title(behavData.Session{sess}); end
    text(90,.45, strPair, "FontSize",9)

    yline(0)
    plot(VECDIR,rAcc, 'r.-', 'MarkerSize',12)
    plot(VECDIR,rFast, '.-', 'Color',[0 .7 0], 'MarkerSize',12)
    xlim([-5 320]); ylim([-.5 +.5]);
    xticks(VECDIR);

    if (iPair == nPair)
      xlabel('Target direction')
      ylabel('Noise correlation')
      ytickformat('%2.1f')
    else
      xticklabels([])
      yticklabels([])
    end

    scAcc  = scNoise(kk).Acc.(EPOCH);
    scFast = scNoise(kk).Fast.(EPOCH);

  end
end

ppretty([2.4,2*nPair])

clearvars -except ROOTDIR* behavData unitData pairData rNoise rSignal scNoise
