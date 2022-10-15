%organize_rscTable.m
% Includes code for reorganization of Rsc table from prior formatting
% **Note: Get spike counts from xSpkCount_win, ySpkCount_win
% **Note: Get mean firing rate from xMeanFr_spkPerSec_win, yMeanFr_spkPerSec_win

field_xSpkCount = 'xSpkCount_win_400ms';
field_xFR = 'xMeanFr_spkPerSec_win_400ms';

rsc_Acc = table();
rsc_Fast = rsc_Acc;

%index by task condition
idxAcc  = ismember(spkCorr.condition, {'AccurateCorrect','AccurateErrorChoice','AccurateErrorTiming'});
idxFast = ismember(spkCorr.condition, {'FastCorrect','FastErrorChoice','FastErrorTiming'});
%index by trial outcome
idxCorr    = ismember(spkCorr.condition, {'AccurateCorrect','FastCorrect'});
idxErrChc  = ismember(spkCorr.condition, {'AccurateErrorChoice','FastErrorChoice'});
idxErrTime = ismember(spkCorr.condition, {'AccurateErrorTiming','FastErrorTiming'});
%index by trial epoch
idxT1 = ismember(spkCorr.alignedName, {'Baseline'});
idxT2 = ismember(spkCorr.alignedName, {'Visual'});
idxT3 = ismember(spkCorr.alignedName, {'PostSaccade'});
idxT4 = ismember(spkCorr.alignedName, {'PostReward'});

%spike counts - Accurate condition
scAcc.Corr = [spkCorr.(field_xSpkCount)(idxAcc & idxCorr & idxT1), spkCorr.(field_xSpkCount)(idxAcc & idxCorr & idxT2), ...
       spkCorr.(field_xSpkCount)(idxAcc & idxCorr & idxT3), spkCorr.(field_xSpkCount)(idxAcc & idxCorr & idxT4)];
scAcc.ErrChc = [spkCorr.(field_xSpkCount)(idxAcc & idxErrChc & idxT1), spkCorr.(field_xSpkCount)(idxAcc & idxErrChc & idxT2), ...
       spkCorr.(field_xSpkCount)(idxAcc & idxErrChc & idxT3), spkCorr.(field_xSpkCount)(idxAcc & idxErrChc & idxT4)];
scAcc.ErrTime = [spkCorr.(field_xSpkCount)(idxAcc & idxErrTime & idxT1), spkCorr.(field_xSpkCount)(idxAcc & idxErrTime & idxT2), ...
       spkCorr.(field_xSpkCount)(idxAcc & idxErrTime & idxT3), spkCorr.(field_xSpkCount)(idxAcc & idxErrTime & idxT4)];
%spike counts - Fast condition
scFast.Corr = [spkCorr.(field_xSpkCount)(idxFast & idxCorr & idxT1), spkCorr.(field_xSpkCount)(idxFast & idxCorr & idxT2), ...
       spkCorr.(field_xSpkCount)(idxFast & idxCorr & idxT3), spkCorr.(field_xSpkCount)(idxFast & idxCorr & idxT4)];
scFast.ErrChc = [spkCorr.(field_xSpkCount)(idxFast & idxErrChc & idxT1), spkCorr.(field_xSpkCount)(idxFast & idxErrChc & idxT2), ...
       spkCorr.(field_xSpkCount)(idxFast & idxErrChc & idxT3), spkCorr.(field_xSpkCount)(idxFast & idxErrChc & idxT4)];
scFast.ErrTime = [spkCorr.(field_xSpkCount)(idxFast & idxErrTime & idxT1), spkCorr.(field_xSpkCount)(idxFast & idxErrTime & idxT2), ...
       spkCorr.(field_xSpkCount)(idxFast & idxErrTime & idxT3), spkCorr.(field_xSpkCount)(idxFast & idxErrTime & idxT4)];

%firing rate - Accurate condition
frAcc.Corr = [spkCorr.(field_xFR)(idxAcc & idxCorr & idxT1), spkCorr.(field_xFR)(idxAcc & idxCorr & idxT2), ...
       spkCorr.(field_xFR)(idxAcc & idxCorr & idxT3), spkCorr.(field_xFR)(idxAcc & idxCorr & idxT4)];
frAcc.ErrChc = [spkCorr.(field_xFR)(idxAcc & idxErrChc & idxT1), spkCorr.(field_xFR)(idxAcc & idxErrChc & idxT2), ...
       spkCorr.(field_xFR)(idxAcc & idxErrChc & idxT3), spkCorr.(field_xFR)(idxAcc & idxErrChc & idxT4)];
frAcc.ErrTime = [spkCorr.(field_xFR)(idxAcc & idxErrTime & idxT1), spkCorr.(field_xFR)(idxAcc & idxErrTime & idxT2), ...
       spkCorr.(field_xFR)(idxAcc & idxErrTime & idxT3), spkCorr.(field_xFR)(idxAcc & idxErrTime & idxT4)];
%firing rate - Fast condition
frFast.Corr = [spkCorr.(field_xFR)(idxFast & idxCorr & idxT1), spkCorr.(field_xFR)(idxFast & idxCorr & idxT2), ...
       spkCorr.(field_xFR)(idxFast & idxCorr & idxT3), spkCorr.(field_xFR)(idxFast & idxCorr & idxT4)];
frFast.ErrChc = [spkCorr.(field_xFR)(idxFast & idxErrChc & idxT1), spkCorr.(field_xFR)(idxFast & idxErrChc & idxT2), ...
       spkCorr.(field_xFR)(idxFast & idxErrChc & idxT3), spkCorr.(field_xFR)(idxFast & idxErrChc & idxT4)];
frFast.ErrTime = [spkCorr.(field_xFR)(idxFast & idxErrTime & idxT1), spkCorr.(field_xFR)(idxFast & idxErrTime & idxT2), ...
       spkCorr.(field_xFR)(idxFast & idxErrTime & idxT3), spkCorr.(field_xFR)(idxFast & idxErrTime & idxT4)];

%correlation values - Accurate condition
rhoAcc.Corr = [spkCorr.rhoRaw(idxAcc & idxCorr & idxT1), spkCorr.rhoRaw(idxAcc & idxCorr & idxT2), ...
       spkCorr.rhoRaw(idxAcc & idxCorr & idxT3), spkCorr.rhoRaw(idxAcc & idxCorr & idxT4)];
rhoAcc.ErrChc = [spkCorr.rhoRaw(idxAcc & idxErrChc & idxT1), spkCorr.rhoRaw(idxAcc & idxErrChc & idxT2), ...
       spkCorr.rhoRaw(idxAcc & idxErrChc & idxT3), spkCorr.rhoRaw(idxAcc & idxErrChc & idxT4)];
rhoAcc.ErrTime = [spkCorr.rhoRaw(idxAcc & idxErrTime & idxT1), spkCorr.rhoRaw(idxAcc & idxErrTime & idxT2), ...
       spkCorr.rhoRaw(idxAcc & idxErrTime & idxT3), spkCorr.rhoRaw(idxAcc & idxErrTime & idxT4)];
%correlation values - Fast condition
rhoFast.Corr = [spkCorr.rhoRaw(idxFast & idxCorr & idxT1), spkCorr.rhoRaw(idxFast & idxCorr & idxT2), ...
       spkCorr.rhoRaw(idxFast & idxCorr & idxT3), spkCorr.rhoRaw(idxFast & idxCorr & idxT4)];
rhoFast.ErrChc = [spkCorr.rhoRaw(idxFast & idxErrChc & idxT1), spkCorr.rhoRaw(idxFast & idxErrChc & idxT2), ...
       spkCorr.rhoRaw(idxFast & idxErrChc & idxT3), spkCorr.rhoRaw(idxFast & idxErrChc & idxT4)];
rhoFast.ErrTime = [spkCorr.rhoRaw(idxFast & idxErrTime & idxT1), spkCorr.rhoRaw(idxFast & idxErrTime & idxT2), ...
       spkCorr.rhoRaw(idxFast & idxErrTime & idxT3), spkCorr.rhoRaw(idxFast & idxErrTime & idxT4)];

%p values - Accurate condition
pvalAcc.Corr = [spkCorr.pvalRaw(idxAcc & idxCorr & idxT1), spkCorr.pvalRaw(idxAcc & idxCorr & idxT2), ...
       spkCorr.pvalRaw(idxAcc & idxCorr & idxT3), spkCorr.pvalRaw(idxAcc & idxCorr & idxT4)];
pvalAcc.ErrChc = [spkCorr.pvalRaw(idxAcc & idxErrChc & idxT1), spkCorr.pvalRaw(idxAcc & idxErrChc & idxT2), ...
       spkCorr.pvalRaw(idxAcc & idxErrChc & idxT3), spkCorr.pvalRaw(idxAcc & idxErrChc & idxT4)];
pvalAcc.ErrTime = [spkCorr.pvalRaw(idxAcc & idxErrTime & idxT1), spkCorr.pvalRaw(idxAcc & idxErrTime & idxT2), ...
       spkCorr.pvalRaw(idxAcc & idxErrTime & idxT3), spkCorr.pvalRaw(idxAcc & idxErrTime & idxT4)];
%p values - Fast condition
pvalFast.Corr = [spkCorr.pvalRaw(idxFast & idxCorr & idxT1), spkCorr.pvalRaw(idxFast & idxCorr & idxT2), ...
       spkCorr.pvalRaw(idxFast & idxCorr & idxT3), spkCorr.pvalRaw(idxFast & idxCorr & idxT4)];
pvalFast.ErrChc = [spkCorr.pvalRaw(idxFast & idxErrChc & idxT1), spkCorr.pvalRaw(idxFast & idxErrChc & idxT2), ...
       spkCorr.pvalRaw(idxFast & idxErrChc & idxT3), spkCorr.pvalRaw(idxFast & idxErrChc & idxT4)];
pvalFast.ErrTime = [spkCorr.pvalRaw(idxFast & idxErrTime & idxT1), spkCorr.pvalRaw(idxFast & idxErrTime & idxT2), ...
       spkCorr.pvalRaw(idxFast & idxErrTime & idxT3), spkCorr.pvalRaw(idxFast & idxErrTime & idxT4)];

%populate new Accurate-specific rsc table
rsc_Acc.PairID = spkCorr.Pair_UID(idxAcc & idxCorr & idxT1);
rsc_Acc.Monkey = spkCorr.X_Monkey(idxAcc & idxCorr & idxT1);
rsc_Acc.Session = spkCorr.X_Session(idxAcc & idxCorr & idxT1);
rsc_Acc.X_Area = spkCorr.X_Area(idxAcc & idxCorr & idxT1);
rsc_Acc.Y_Area = spkCorr.Y_Area(idxAcc & idxCorr & idxT1);
rsc_Acc.X_Grade_Vis = spkCorr.X_Grade_Vis(idxAcc & idxCorr & idxT1);
rsc_Acc.X_Grade_CErr = spkCorr.X_Grade_Err(idxAcc & idxCorr & idxT1);
rsc_Acc.X_Grade_TErr = spkCorr.X_Grade_TErr(idxAcc & idxCorr & idxT1);
rsc_Acc.rhoCorr = rhoAcc.Corr;
rsc_Acc.rhoErrChc = rhoAcc.ErrChc;
rsc_Acc.rhoErrTime = rhoAcc.ErrTime;
rsc_Acc.pvalCorr = pvalAcc.Corr;
rsc_Acc.pvalErrChc = pvalAcc.ErrChc;
rsc_Acc.pvalErrTime = pvalAcc.ErrTime;
% rsc_Acc.X_FR = [frAcc.Corr, frAcc.ErrChc, frAcc.ErrTime];
% rsc_Acc.X_sc = {scAcc.Corr, scAcc.ErrChc, scAcc.ErrTime};

%populate new Fast-specific rsc table
rsc_Fast.PairID = spkCorr.Pair_UID(idxFast & idxCorr & idxT1);
rsc_Fast.Monkey = spkCorr.X_Monkey(idxFast & idxCorr & idxT1);
rsc_Fast.Session = spkCorr.X_Session(idxFast & idxCorr & idxT1);
rsc_Fast.X_Area = spkCorr.X_Area(idxFast & idxCorr & idxT1);
rsc_Fast.Y_Area = spkCorr.Y_Area(idxFast & idxCorr & idxT1);
rsc_Fast.X_Grade_Vis = spkCorr.X_Grade_Vis(idxFast & idxCorr & idxT1);
rsc_Fast.X_Grade_CErr = spkCorr.X_Grade_Err(idxFast & idxCorr & idxT1);
rsc_Fast.X_Grade_TErr = spkCorr.X_Grade_TErr(idxFast & idxCorr & idxT1);
rsc_Fast.rhoCorr = rhoFast.Corr;
rsc_Fast.rhoErrChc = rhoFast.ErrChc;
rsc_Fast.rhoErrTime = rhoFast.ErrTime;
rsc_Fast.pvalCorr = pvalFast.Corr;
rsc_Fast.pvalErrChc = pvalFast.ErrChc;
rsc_Fast.pvalErrTime = pvalFast.ErrTime;

writetable(rsc_Acc,  'spkCorr.xlsx', 'Sheet','Accurate')
writetable(rsc_Fast, 'spkCorr.xlsx', 'Sheet','Fast')

clear idx* pval* rho* fr* sc* field*
