function [ StatsCE ] = quantify_ChoiceErr_signal_SAT( A_PostSacc )
%quantify_RPE_signal_SAT() Summary of this function goes here
%   Detailed explanation goes here

ALPHA_MW = 0.30;
MIN_LENGTH = 150; %number of consecutive samples with rejection of null

NUM_CELLS = length(A_PostSacc);

StatsCE = new_struct({'tStart','tFinish','AbarErr','AbarCorr','Adiff'});
StatsCE = populate_struct(StatsCE, {'tStart','tFinish','AbarErr','AbarCorr','Adiff'}, NaN(1,NUM_CELLS));
StatsCE = struct('acc',StatsCE, 'fast',StatsCE);

OFFSET_T = A_PostSacc(1).t(1);

for cc = 1:NUM_CELLS
  
  StatsCE.acc.tStart(cc) = OFFSET_T + compute_time_CE(A_PostSacc(cc).AccCorr, A_PostSacc(cc).AccErrDir, ALPHA_MW, MIN_LENGTH);
  StatsCE.fast.tStart(cc) = OFFSET_T + compute_time_CE(A_PostSacc(cc).FastCorr, A_PostSacc(cc).FastErrDir, ALPHA_MW, MIN_LENGTH);
  
end%for:cells(cc)

end%fxn:quantify_RPE_signal_SAT()

function [ tStart ] = compute_time_CE( A_corr , A_err , alpha , minLength)

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