function [ ] = plotDistr_TimingError( behavData )
%plotDistr_TimingError Summary of this function goes here
%   Detailed explanation goes here

idxMonk = ismember({behavData.Monkey}, {'E'});

NUM_SESSION = sum(idxMonk);
behavData = behavData(idxMonk);

errRT_Acc = [];
errRT_Fast = [];

for kk = 1:NUM_SESSION
  
  errKK = double(behavData.Sacc_RT{kk}) - double(behavData.Task_Deadline{kk});
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  %index by trial outcome
  idxErr = (behavData.Task_ErrTime{kk});
  %index by screen clear on Fast trials
  idxClear = logical(behavData.Task_ClearDisplayFast{kk}); %do not include
  
  errRT_Acc = cat(2, errRT_Acc, errKK(idxAcc & idxErr));
  errRT_Fast = cat(2, errRT_Fast, errKK(idxFast & idxErr & ~idxClear));
  
end%for:session(kk)

%% Plotting

figure()

subplot(1,2,1); hold on %Accurate condition
histogram(errRT_Acc, 'FaceColor','r', 'BinWidth',20)

subplot(1,2,2); hold on %Fast condition
histogram(errRT_Fast, 'FaceColor',[0 .7 0], 'BinWidth',40)
set(gca, 'YAxisLocation','right')

ppretty([6,2.5])

end%fxn:plotDistr_TimingError()

