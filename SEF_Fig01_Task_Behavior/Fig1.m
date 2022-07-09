%Fig1.m -- Figure 1 header file
MONKEY = {'E'};

%compute mean task-related parameters per session
% compute_Behavior_X_Sess

%generate Fig1C
% Fig1C_ErrRate_X_RT(behavData, 'monkey',MONKEY)
Fig1C_ErrRate_X_RT_Simple(behavData, 'monkey',MONKEY) %no effect of difficulty

%generate Fig1D
% Fig1D_Behav_X_Trial(behavData, 'monkey',MONKEY)
% Fig1D_Behav_X_Trial_Simple(behavData, 'monkey',MONKEY) %no effect of difficulty

% plot_RT_X_TrialHistory(behavData, 'monkey',MONKEY)

% plot_hazardRT(behavData, 'monkey',MONKEY)
% fitHF = plot_hazard_RTerr(behavData, 'monkey',MONKEY);

