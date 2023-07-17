%plot_NoiseCorr_X_Condition.m
% 

nSess = length(rNoise);
EPOCH = 'VR';

%initializations
rLL = struct('Acc',[], 'Fast',[]); %left-left hemi
rRR = rLL; %right-right hemi
rLR = rLL; %left-right hemi

for kk = 1:nSess
  if isempty(rNoise(kk).Unit); continue; end
  nUnit = numel(rNoise(kk).Unit);
  nPair = nUnit*(nUnit-1) / 2;
  
  iPair = 0;
  for xx = 1:nUnit-1
    for yy = xx+1:nUnit
      iPair = iPair + 1;
  
      uX = rNoise(kk).Unit(xx);
      uY = rNoise(kk).Unit(yy);
  
      hemiX = unitData.Hemi(uX);
      hemiY = unitData.Hemi(uY);
  
      rAcc_xy  = squeeze( rNoise(kk).Acc.(EPOCH)(xx,yy,:) );
      rFast_xy = squeeze( rNoise(kk).Fast.(EPOCH)(xx,yy,:) );
  
      %compute mean correlation across directions
      rAcc_xy  = mean(rAcc_xy,  "omitnan");
      rFast_xy = mean(rFast_xy, "omitnan");
  
      if ((hemiX == 'L') && (hemiY == 'L'))
        rLL.Acc  = cat(1, rLL.Acc,  rAcc_xy);
        rLL.Fast = cat(1, rLL.Fast, rFast_xy);
      elseif ((hemiX == 'R') && (hemiY == 'R'))
        rRR.Acc = cat(1,  rRR.Acc,  rAcc_xy);
        rRR.Fast = cat(1, rRR.Fast, rFast_xy);
      else % L/R R/L
        rLR.Acc = cat(1,  rLR.Acc,  rAcc_xy);
        rLR.Fast = cat(1, rLR.Fast, rFast_xy);
      end
  
    end % for : yy
  end % for : xx

end % for : session (kk)

nLL = numel(rLL.Acc);
nRR = numel(rRR.Acc);
nLR = numel(rLR.Acc);

rLLmu.Acc  = mean(rLL.Acc);   rLLse.Acc  = std(rLL.Acc)  / sqrt(nLL); %left-left
rLLmu.Fast = mean(rLL.Fast);  rLLse.Fast = std(rLL.Fast) / sqrt(nLL);
rRRmu.Acc  = mean(rRR.Acc);   rRRse.Acc  = std(rRR.Acc)  / sqrt(nRR); %right-right
rRRmu.Fast = mean(rRR.Fast);  rRRse.Fast = std(rRR.Fast) / sqrt(nRR);
rLRmu.Acc  = mean(rLR.Acc);   rLRse.Acc  = std(rLR.Acc)  / sqrt(nLR); %left-right
rLRmu.Fast = mean(rLR.Fast);  rLRse.Fast = std(rLR.Fast) / sqrt(nLR);

%% Plotting
XTICKS = 1:6;
yPlot  = [rLLmu.Acc rLLmu.Fast rRRmu.Acc rRRmu.Fast rLRmu.Acc rLRmu.Fast];
sePlot = [rLLse.Acc rLLse.Fast rRRse.Acc rRRse.Fast rLRse.Acc rLRse.Fast];

figure(); hold on

bar(XTICKS, yPlot, 0.7, 'k')
errorbar(XTICKS, yPlot, sePlot, 'k', 'CapSize',0)
xticks(XTICKS); xticklabels({'Acc','Fast','Acc','Fast','Acc','Fast'})
ytickformat('%3.2f')

ppretty([3,2])

clearvars -except ROOTDIR* behavData unitData pairData *Noise* *Signal* rLL rRR rLR trialRemove
