
NUM_SESS = 16;

%bin by timing error magnitude
ERR_LIM = linspace(0, 1, 5);
NUM_BIN = length(ERR_LIM) - 1;
errLim_Acc = NaN(NUM_SESS,NUM_BIN+1);
errLim_Fast = errLim_Acc;

for kk = 1:NUM_SESS
  RTerr = behavData.Sacc_RTerr{kk}; %RT relative to deadline
  RT_P = behavData.Sacc_RT{kk}; %RT of primary saccade
  
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1));
  idxFast = ((behavData.Task_SATCondition{kk} == 3));
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = (behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
    
  %combine indexing
  idxAC = (idxAcc & idxCorr);    idxAE = (idxAcc & idxErr & (RTerr < 0));
  idxFC = (idxFast & idxCorr);   idxFE = (idxFast & idxErr & (RTerr > 0));
  
  %use absolute error for Accurate condition
  RTerr = abs(RTerr);
  %compute RT error quantiles for binning based on distribution of RT error
  errLim_Acc(kk,:)  = quantile(RTerr(idxAE), ERR_LIM);
  errLim_Fast(kk,:) = quantile(RTerr(idxFE), ERR_LIM);
  
end  

behavData.Task_RTErrLim_Acc  = NaN(50,NUM_BIN+1);
behavData.Task_RTErrLim_Fast = NaN(50,NUM_BIN+1);
behavData.Task_RTErrLim_Acc(1:NUM_SESS,:)  = errLim_Acc;
behavData.Task_RTErrLim_Fast(1:NUM_SESS,:) = errLim_Fast;

clear idx* NUM_* RT*
