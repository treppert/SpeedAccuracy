function [ ] = plotMUspCtXrtSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotMUspCtXrtSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}, {'interval=','baseline'}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Figs\0-SpkXRT\';
NUM_SESSION = length(binfo);

if ~ismember(args.interval, {'baseline','visresp','presacc'})
  error('Input "interval" not recognized')
end

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxErr = ([ninfo.errGrade] >= 2);   idxRew = (abs([ninfo.rewGrade]) >= 2);
idxEff = ([ninfo.taskType] == 2);

if strcmp(args.interval, 'baseline')
  idxKeep = (idxArea & idxMonkey & (idxRew) & idxEff);
%   idxKeep = (idxArea & idxMonkey & idxVis);
  saveDir = 'Baseline\';
elseif strcmp(args.interval, 'visresp')
  idxKeep = (idxArea & idxMonkey & idxVis & idxEff);
  saveDir = 'VisResp\';
else %pre-saccadic
  idxKeep = (idxArea & idxMonkey & idxMove & idxEff);
  saveDir = 'PreSacc\';
end

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

RTLIM_ACC = [390 800];
RTLIM_FAST = [150 450];

T_BLINE = 3500 + [-600 20]; %from array
T_PRESACC = [-150, 0]; %from primary saccade

%initializations
rhoAcc = NaN(1,NUM_SESSION);    pvalAcc = NaN(1,NUM_SESSION);
rhoFast = NaN(1,NUM_SESSION);   pvalFast = NaN(1,NUM_SESSION);

RTBIN_FAST = (200 : 25 : 350);  NBIN_FAST = length(RTBIN_FAST) - 1;   zSpkCtFast = NaN(NUM_SESSION,NBIN_FAST);
RTBIN_ACC = (450 : 50 : 700);   NBIN_ACC = length(RTBIN_ACC) - 1;     zSpkCtAcc = NaN(NUM_SESSION,NBIN_ACC);
MIN_PER_BIN = 10; %minimum number of trials per RT bin

for kk = 1:NUM_SESSION
  fprintf('Session %s\n', binfo(kk).session)
  ccKK = find(ismember({ninfo.sess}, binfo(kk).session));  numCells = length(ccKK);
  RTkk = double(moves(kk).resptime);
  
  %make sure we have neurons from this session
  if (numCells == 0); continue; end
  %print units
  for cc = 1:numCells; fprintf('Unit %s - %s\n', ninfo(ccKK(cc)).sess, ninfo(ccKK(cc)).unit); end
  
  %session-specific initializations
  spkCount = NaN(numCells,binfo(kk).num_trials);
  idxPoorIso = false(numCells,binfo(kk).num_trials);
  
  %loop over all neurons from this session to compute spike counts
  for cc = 1:numCells
    spikesCC = spikes(ccKK(cc)).SAT;
    
    if strcmp(args.interval, 'baseline')
      %ref spikes to time of array
      spkCount(cc,:) = cellfun(@(x) sum((x > T_BLINE(1)) & (x < T_BLINE(2))), spikesCC);
    elseif strcmp(args.interval, 'visresp')
      %ref spikes to time of visual response
      ccNS = ninfo(ccKK(cc)).unitNum;
      visRespLatency = nstats(ccNS).VRlatAcc; %note: VRlatAcc = VRlatFast
      T_VISRESP = 3500 + visRespLatency + [0 150];

      spkCount(cc,:)  = cellfun(@(x) sum((x > T_VISRESP(1)) & (x < T_VISRESP(2))), spikesCC);
    else %pre-saccadic
      %ref spikes to time of primary saccade
      for jj = 1:binfo(kk).num_trials
        spikesCC{jj} = spikesCC{jj} - (3500 + RTkk(jj));
      end

      spkCount(cc,:) = cellfun(@(x) sum((x > T_PRESACC(1)) & (x < T_PRESACC(2))), spikesCC);
    end%if:interval==baseline, etc.
    
    %account for trials with poor isolation
    idxPoorIso(cc,:) = identify_trials_poor_isolation_SAT(ninfo(ccKK(cc)), binfo(kk).num_trials);
    
  end%for:cells(cc)
  
  %remove trials with poor unit isolation
  idxPoorIso = logical(sum(idxPoorIso,1));
  
  %index by trial outcome
  idxTimeErr = (binfo(kk).err_time);
  %index by task condition
  idxAcc = ((binfo(kk).condition == 1) & ~(idxPoorIso | idxTimeErr | RTkk < RTLIM_ACC(1) | RTkk > RTLIM_ACC(2) | isnan(RTkk)));
  idxFast = ((binfo(kk).condition == 3) & ~(idxPoorIso | idxTimeErr | RTkk < RTLIM_FAST(1) | RTkk > RTLIM_FAST(2) | isnan(RTkk)));
  
  %sum discharge rate across all units from this session
  spkCountAcc = sum(spkCount(:,idxAcc), 1);
  spkCountFast = sum(spkCount(:,idxFast), 1);
  
  %cut outlier values for spike count
  idxCutAcc = estimate_spread(spkCountAcc, 3.5);    spkCountAcc(idxCutAcc) = [];
  idxCutFast = estimate_spread(spkCountFast, 3.5);  spkCountFast(idxCutFast) = [];
  
  %split RT by task condition
  RTacc = RTkk(idxAcc);   RTacc(idxCutAcc) = [];
  RTfast = RTkk(idxFast); RTfast(idxCutFast) = [];
  
  %z-score spike counts
  muSpkCt = mean([spkCountAcc spkCountFast]);
  sdSpkCt = std([spkCountAcc spkCountFast]);
  spkCountAcc = (spkCountAcc - muSpkCt) / sdSpkCt;
  spkCountFast = (spkCountFast - muSpkCt) / sdSpkCt;
  
  %save for across-session average
  for ii = 1:NBIN_ACC
    idxII = ((RTacc > RTBIN_ACC(ii)) & (RTacc < RTBIN_ACC(ii+1)));
    if (sum(idxII) >= MIN_PER_BIN)
      zSpkCtAcc(kk,ii) = mean(spkCountAcc(idxII));
    end
  end%for:bin-Accurate
  for ii = 1:NBIN_FAST
    idxII = ((RTfast > RTBIN_FAST(ii)) & (RTfast < RTBIN_FAST(ii+1)));
    if (sum(idxII) >= MIN_PER_BIN)
      zSpkCtFast(kk,ii) = mean(spkCountFast(idxII));
    end
  end%for:bin-Fast
  
  %compute correlation coefficient
  [tnpAcc,tmpAcc] = corr([spkCountAcc ; RTacc]', 'Type','Pearson');
  pvalAcc(kk) = tmpAcc(1,2);    rhoAcc(kk) = tnpAcc(1,2);
  [tnpFast,tmpFast] = corr([spkCountFast ; RTfast]', 'Type','Pearson');
  pvalFast(kk) = tmpFast(1,2);  rhoFast(kk) = tnpFast(1,2);
  
  %plot spike count vs. RT for this session
%   figure(); hold on
%   scatter(RTfast, spkCountFast, 40, [0 .7 0], 'filled', 'MarkerFaceAlpha',0.7)
%   scatter(RTacc, spkCountAcc, 40, 'r', 'filled', 'MarkerFaceAlpha',0.7)
%   title(['Session ', binfo(kk).session,'  n = ', num2str(numCells)])
%   xlabel('Response time (ms)')
%   ylabel('z-score of spike count')
%   title(['R_A=',num2str(rhoAcc(1,2)), '   p_A=',num2str(pvalAcc), ...
%     '   R_F=',num2str(rhoFast(1,2)), '   p_F=',num2str(pvalFast)])
%   ppretty([12,6])
%   print([ROOTDIR, saveDir, binfo(kk).session, '.tif'], '-dtiff'); pause(0.1); close
  
end%for:session(kk)

%% Plotting - Across sessions
RTPLOT_ACC = RTBIN_ACC(1:end-1) + diff(RTBIN_ACC)/2;    NSEM_ACC = sum(~isnan(zSpkCtAcc), 1);
RTPLOT_FAST = RTBIN_FAST(1:end-1) + diff(RTBIN_FAST)/2; NSEM_FAST = sum(~isnan(zSpkCtFast), 1);

figure(); hold on
errorbar(RTPLOT_ACC, nanmean(zSpkCtAcc), nanstd(zSpkCtAcc)./NSEM_ACC, 'capsize',0, 'Color','r')
errorbar(RTPLOT_FAST, nanmean(zSpkCtFast), nanstd(zSpkCtFast)./NSEM_FAST, 'capsize',0, 'Color',[0 .7 0])
xlabel('Response time (ms)')
ylabel('Spike count (z)'); ytickformat('%3.2f')
ppretty([6.4,4])

%% Compute stats on session averages
zSpkCtAcc = reshape(zSpkCtAcc', 1,NUM_SESSION*NBIN_ACC)';     rtAcc = repmat(RTPLOT_ACC, 1,NUM_SESSION)';
zSpkCtFast = reshape(zSpkCtFast', 1,NUM_SESSION*NBIN_FAST)';  rtFast = repmat(RTPLOT_FAST, 1,NUM_SESSION)';

%remove all NaNs
inanAcc = isnan(zSpkCtAcc);     zSpkCtAcc(inanAcc) = [];   rtAcc(inanAcc) = [];
inanFast = isnan(zSpkCtFast);   zSpkCtFast(inanFast) = [];  rtFast(inanFast) = [];

[rhoAcc,pvalAcc] = corr(rtAcc, zSpkCtAcc, 'Type','Pearson');      tvalAcc = convertPearsonR_to_tStat(rhoAcc, length(rtAcc));
[rhoFast,pvalFast] = corr(rtFast, zSpkCtFast, 'Type','Pearson');  tvalFast = convertPearsonR_to_tStat(rhoFast, length(rtFast));
fprintf('Accurate: R = %g  p = %g  n = %d  t = %g\n', rhoAcc, pvalAcc, length(rtAcc), tvalAcc)
fprintf('Fast: R = %g  p = %g  n = %d  t = %g\n', rhoFast, pvalFast, length(rtFast), tvalFast)

end%fxn:plotMUspCtXrtSAT()
