function [  ] = Fig4A_ErrRate_X_Trial( behavData , varargin )
%Fig4A_ErrRate_X_Trial Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

%isolate sessions from monkey(s)
kkKeep = (ismember(behavData.Monkey, args.monkey) & behavData.Task_RecordedSEF);
behavData = behavData(kkKeep, :);
NUM_SESS = sum(kkKeep);

%plot vs trial from condition change
TRIAL_PLOT = ( -4 : 3 );
NUM_TRIAL = length(TRIAL_PLOT);

%initializations
ER_Time_A2F = NaN(NUM_SESS,NUM_TRIAL);
ER_Time_F2A = ER_Time_A2F;

%% Compute probability of error vs trial

for kk = 1:NUM_SESS
  
  %index by task condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};     jjCorr = find(idxCorr);
  idxErr  = behavData.Task_ErrTime{kk};     jjErr  = find(idxErr);
  
  %index by trial number from change
  idxSwitch = (behavData.Task_Trial{kk} == 0);
  jjA2F = find(idxSwitch & idxFast);  nA2F = length(jjA2F);
  jjF2A = find(idxSwitch & idxAcc);   nF2A = length(jjF2A);
  
  for ii = 1:NUM_TRIAL %trial from change
    %get trial numbers for ith position from change
    jjA2F_ii = jjA2F + TRIAL_PLOT(ii);
    jjF2A_ii = jjF2A + TRIAL_PLOT(ii);
    %find those that are timing errors
    idxErrA2F_ii = ismember(jjA2F_ii, jjErr);
    idxErrF2A_ii = ismember(jjF2A_ii, jjErr);
    %save the proportion of errors
    ER_Time_A2F(kk,ii) = sum(idxErrA2F_ii);
    ER_Time_F2A(kk,ii) = sum(idxErrF2A_ii);
  end
  
  ER_Time_A2F(kk,:) = ER_Time_A2F(kk,:) / nA2F;
  ER_Time_F2A(kk,:) = ER_Time_F2A(kk,:) / nF2A;
  
end % for : sessions(kk)

%% Plotting

figure(); hold on
errorbar(TRIAL_PLOT, mean(ER_Time_F2A), std(ER_Time_F2A)/sqrt(NUM_SESS), 'Color','k', 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL, mean(ER_Time_A2F), std(ER_Time_A2F)/sqrt(NUM_SESS), 'Color','k', 'CapSize',0)
xlim([-5 12]); xticks(-5:12); xticklabels(cell(1,12)); 
ylabel('Timing error rate'); ytickformat('%3.2f')

ppretty([2.4,1.0])
set(gca, 'XMinorTick','off')

%% Statistics



end % function : Fig4A_ErrRate_X_Trial()

