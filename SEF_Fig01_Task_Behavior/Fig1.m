%Fig1.m -- Figure 1 header file
%load('C:\Users\Tom\Dropbox\Speed Accuracy\__SEF_SAT\Data\AllData_SAT.mat')

%compute mean task-related parameters per session
compute_Behavior_X_Sess( behavData )

%generate Fig1C
Fig1C_ErrRate_X_RT( behavData )

%generate Fig1D
Fig1D_Behav_X_Trial( behavData )
