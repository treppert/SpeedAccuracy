%computeTrialTypesDB.m

TrialTypesDB = table();

for k = 1:16 %loop over all sessions for Da & Eu
  
  TrialTypesDB.session{k} = behavData.Session{k};

  %index by task condition
  idxAcc  = (behavData.Condition{k} == 1);
  idxFast = (behavData.Condition{k} == 3);

  %index by trial outcome
  idxCorrect   = behavData.Correct{k};
  idxErrChoice = behavData.ErrChoiceOnly{k};
  idxErrTiming = behavData.ErrTimeOnly{k};

  %populate trial types - Accurate condition
  TrialTypesDB.Accurate{k} = idxAcc;
  TrialTypesDB.AccurateCorrect{k} = (idxAcc & idxCorrect);
  TrialTypesDB.AccurateErrorChoice{k} = (idxAcc & idxErrChoice);
  TrialTypesDB.AccurateErrorTiming{k} = (idxAcc & idxErrTiming);

  %populate trial types - Accurate condition
  TrialTypesDB.Fast{k} = idxFast;
  TrialTypesDB.FastCorrect{k} = (idxFast & idxCorrect);
  TrialTypesDB.FastErrorChoice{k} = (idxFast & idxErrChoice);
  TrialTypesDB.FastErrorTiming{k} = (idxFast & idxErrTiming);

end % for : session (k)

ROOTDIR_SAT = 'C:\Users\thoma\Dropbox\Speed Accuracy\Data\';
save([ROOTDIR_SAT, 'spkCorr\SAT_SEF_TrialTypesDB.mat'], 'TrialTypesDB')

clear idx* k