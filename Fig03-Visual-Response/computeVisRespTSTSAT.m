function [ TSTAcc , TSTFast , varargout ] = computeVisRespTSTSAT(sdfVRAcc, sdfVRFast, nstats, offset)
%computeVisRespTSTSAT Summary of this function goes here
%   Detailed explanation goes here
%   sdfVRAcc - Single-trial visual response SDFs in the Accurate condition
%   sdfVRFast - Single-trial visual response SDFs in the Fast condition
%   varargout - Struct with fields Acc and Fast containing vectors of
%   timestamps of significant diff. from the U-test
% 

MIN_TST = min([nstats.VRlatAcc, nstats.VRlatFast]) + 10; %min acceptable TST (re. VR latency)

sdfVRAcc.Tin = sdfVRAcc.Tin(:,offset+MIN_TST+1:end); %only consider time points beyond VR initiation
sdfVRAcc.Din = sdfVRAcc.Din(:,offset+MIN_TST+1:end);
sdfVRFast.Tin = sdfVRFast.Tin(:,offset+MIN_TST+1:end);
sdfVRFast.Din = sdfVRFast.Din(:,offset+MIN_TST+1:end);

if (nargout > 2) %output additional info, including timestamps of sig. diff. (Mann-Whitney)
  [TSTAcc,tVecAcc] = computeTST(sdfVRAcc);
  [TSTFast,tVecFast] = computeTST(sdfVRFast);
  TSTAcc = TSTAcc + MIN_TST;
  TSTFast = TSTFast + MIN_TST;
  varargout{1} = struct('Acc',tVecAcc+MIN_TST, 'Fast',tVecFast+MIN_TST);
else
  TSTAcc = computeTST(sdfVRAcc) + MIN_TST;
  TSTFast = computeTST(sdfVRFast) + MIN_TST;
end

end%computeVisRespTSTSAT()


function [ TST , varargout ] = computeTST( sdfVR )
DEBUG = false;
MIN_NUM_TRIAL = 5; %min # of trials for each Tin and Din (otherwise do not test)

%initializations
MIN_DUR = 50; %minimum duration (ms) of target selection
ALLOWANCE_TST = 5; %number of missed timepoints allowed within MIN_DUR 
ALPHA = 0.01; %significance cutoff for Mann-Whitney U-test
FILT_HALFWIN = 2; %half-width of averaging window to smooth SDF

sdfTin = sdfVR.Tin;  [NUM_Tin,NUM_SAMP] = size(sdfTin);
sdfDin = sdfVR.Din;   NUM_Din = size(sdfDin,1);

if ((NUM_Tin < MIN_NUM_TRIAL) || (NUM_Din < MIN_NUM_TRIAL))
  fprintf('*** Not enough trials to compute TST\n')
  TST = NaN; return
end


%% Mann-Whitney U-test
%perform a Mann-Whitney U-test at each timepoint to accept or reject the
%null hypothesis that the Tin and Din means are equivalent
H1_TS = false(1,NUM_SAMP);
pval_TS = NaN(1,NUM_SAMP); %p-value associated with each test
for ii = FILT_HALFWIN+1:NUM_SAMP-FILT_HALFWIN
  
  idxII = ((ii - FILT_HALFWIN) : (ii + FILT_HALFWIN)); %small averaging window
  
  sdfTinII = mean(sdfTin(:,idxII)); %compute avg values over small window
  sdfDinII = mean(sdfDin(:,idxII));
  
  %Mann-Whitney U-test
  [pval_TS(ii),H1_TS(ii)] = ranksum(sdfTinII, sdfDinII, 'alpha',ALPHA, 'tail','right');
  
end%for:sample(ii)

%% Search for MIN_DUR consecutive time points that reject the null
H1_TS = find(H1_TS);   nCand = length(H1_TS) - MIN_DUR;
dtH1_TS = diff(H1_TS);

TST = NaN;
for ii = 1:nCand %loop over candidate timepoints
  
  runLengthII = sum(dtH1_TS(ii:ii+MIN_DUR-1));
  
  if (runLengthII <= (MIN_DUR+ALLOWANCE_TST))
    %found a run of MIN_DURATION at level ALPHA
    TST = H1_TS(ii);
    break
  end
  
end%for:sample(ii)

if (nargout > 1) %output vector of timestamps with sig. diff.
  varargout{1} = H1_TS;
end

if (DEBUG)
  yLim = [min(mean(sdfTin)) max(mean(sdfTin))];
  figure(); hold on
  
  plot(mean(sdfTin), 'k-')
  plot(mean(sdfDin), 'k--')
  plot(H1_TS, yLim(1), 'b.', 'MarkerSize',20)
  plot(TST*ones(1,2), yLim, 'k:', 'LineWidth',0.5)
  
  yyaxis right; plot(-log(pval_TS), 'r-') %plot p-value of Mann-Whitney vs. time
  plot(repmat([0 NUM_SAMP], 3,1)', (ones(2,1)*(-log([.001 .01 .05]))), 'r:') %plot p-value thresholds
  
  ppretty([6.4,4]); pause()
end

end%util:computeTST()
