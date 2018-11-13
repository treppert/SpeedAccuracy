function [ StatsRPE ] = quantify_RPE_signal_SAT( A_rew )
%quantify_RPE_signal_SAT() Summary of this function goes here
%   Detailed explanation goes here

ALPHA_MW = 0.30;
MIN_LENGTH = 160; %number of consecutive samples with rejection of null

NUM_CELLS = length(A_rew);

StatsRPE = new_struct({'tStart','tFinish','AbarErr','AbarCorr','Adiff'});
StatsRPE = populate_struct(StatsRPE, {'tStart','tFinish','AbarErr','AbarCorr','Adiff'}, NaN(1,NUM_CELLS));
StatsRPE = struct('acc',StatsRPE, 'fast',StatsRPE);

for cc = 1:NUM_CELLS
  
  StatsRPE.acc.tStart(cc) = compute_time_RPE(A_rew(cc).AccCorr, A_rew(cc).AccErrTime, ALPHA_MW, MIN_LENGTH);
  StatsRPE.fast.tStart(cc) = compute_time_RPE(A_rew(cc).FastCorr, A_rew(cc).FastErrTime, ALPHA_MW, MIN_LENGTH);
  
end%for:cells(cc)

end%fxn:quantify_RPE_signal_SAT()

function [ tStart ] = compute_time_RPE( A_corr , A_err , alpha , minLength)

tStart = NaN; %initialization

[~,NUM_SAMP] = size(A_corr);

H_MW = false(1,NUM_SAMP); %Mann-Whitney U-test
P_MW = NaN(1,NUM_SAMP);
for ii = 1:NUM_SAMP
  [P_MW(ii),H_MW(ii)] = ranksum(A_corr(:,ii), A_err(:,ii), 'alpha',alpha, 'tail','both');
end%for:samples(ii)

samp_H_1 = find(H_MW);
dsamp_H_1 = diff(samp_H_1);
NUM_DSAMP = length(dsamp_H_1);

for ii = 1:(NUM_DSAMP-minLength+1)
  if (sum(dsamp_H_1(ii : ii+minLength-1)) == minLength)
    tStart = samp_H_1(ii);
    break
  end
end%for:num-dsamp-estimates(ii)

end%util:compute_time_RPE()