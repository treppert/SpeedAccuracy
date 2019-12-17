%plot_RT_X_Direction_SAT.m
% load('C:\Users\Thomas Reppert\Dropbox\SAT\Data\dataBehavior_SAT.mat', 'binfoSAT')

QUANTILE = [0.2 0.5 0.8];
numQuant = length(QUANTILE);

ANGLE = deg2rad(0 : 45 : 360);
numDir = 8;

MONKEY = {'S'};
idxMonkey = ismember(binfoSAT.monkey, MONKEY);
binfoMonkey = binfoSAT(idxMonkey,:);

numSess = size(binfoMonkey,1);

figure()

for kk = 1:numSess
  
  RT_Fast_Corr  = NaN(numDir, numQuant);
  RT_Fast_Err   = NaN(numDir, numQuant);
  RT_Acc_Corr   = NaN(numDir, numQuant);
  RT_Acc_Err    = NaN(numDir, numQuant);
  
  %index by condition
  idxAcc = (binfoMonkey.condition{kk} == 1);
  idxFast = (binfoMonkey.condition{kk} == 3);
  
  %get response deadline
  RT_Deadline_Acc  = nanmedian(binfoMonkey.deadline{kk}(idxAcc));
  RT_Deadline_Fast = nanmedian(binfoMonkey.deadline{kk}(idxFast));
  
  %index by trial outcome
  idxErr = (binfoMonkey.err_dir{kk});
  idxCorr = ~(binfoMonkey.err_dir{kk} | binfoMonkey.err_hold{kk} | binfoMonkey.err_nosacc{kk});
  
  %index by response octant
  for jj = 1:numDir
    
    idxJJ = (binfoMonkey.octant{kk} == jj);
    
    idx_FastCorr = (idxFast & idxCorr & idxJJ);
    idx_FastErr  = (idxFast & idxErr & idxJJ);
    idx_AccCorr = (idxAcc & idxCorr & idxJJ);
    idx_AccErr  = (idxAcc & idxErr & idxJJ);
    
    RT_Fast_Corr(jj,:) = quantile(binfoMonkey.resptime{kk}(idx_FastCorr), QUANTILE);
    RT_Fast_Err(jj,:)  = quantile(binfoMonkey.resptime{kk}(idx_FastErr), QUANTILE);
    RT_Acc_Corr(jj,:)  = quantile(binfoMonkey.resptime{kk}(idx_AccCorr), QUANTILE);
    RT_Acc_Err(jj,:)   = quantile(binfoMonkey.resptime{kk}(idx_AccErr), QUANTILE);
    
  end % for : octant (jj)
  
  %complete the circle
  RT_Fast_Corr = [RT_Fast_Corr; RT_Fast_Corr(1,:)];
  RT_Fast_Err  = [RT_Fast_Err;  RT_Fast_Err(1,:)];
  RT_Acc_Corr  = [RT_Acc_Corr; RT_Acc_Corr(1,:)];
  RT_Acc_Err   = [RT_Acc_Err;  RT_Acc_Err(1,:)];
  
  %plotting
%   subplot(3,3,kk, polaraxes); hold on %Da/Eu
  subplot(3,6,kk, polaraxes); hold on %Q/S
  title(binfoMonkey.session(kk))
%   polarplot(linspace(0,2*pi,50), RT_Deadline_Acc*ones(1,50), '-', 'Color',[.4 0 0]) %plot deadline
  polarplot(linspace(0,2*pi,50), RT_Deadline_Fast*ones(1,50), '-', 'Color',[0 .3 0])
%   polarplot(ANGLE, RT_Acc_Corr, '.-', 'Color','r', 'MarkerSize',15) %plot RT
%   polarplot(ANGLE, RT_Fast_Corr, '.-', 'Color',[0 .7 0], 'MarkerSize',15)
  polarplot(ANGLE-.1, RT_Fast_Corr, '.', 'Color',[0 .7 0], 'MarkerSize',15)
  polarplot(ANGLE+.1, RT_Fast_Err, 'o', 'Color',[0 .7 0], 'MarkerSize',5)
%   rlim([0 800]); rticks(0:200:800); rticklabels([]) %Correct
  rlim([0 600]); rticks(0:200:600); rticklabels([]) %Error
  thetaticks([])
  
  pause(0.1)
  
end % for : session (kk)

% ppretty([7,9]) %Da/Eu
ppretty([16,9]) %Q/S

clearvars -except binfoSAT
