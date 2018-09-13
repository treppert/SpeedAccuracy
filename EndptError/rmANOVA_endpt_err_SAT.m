function [ ranova_ ] = rmANOVA_endpt_err_SAT( err_acc , err_fast )
%rmANOVA_endpt_err_SAT Summary of this function goes here
%   Detailed explanation goes here

within_acc = table({'250','350','450','550','650','750'}', 'VariableNames',{'RT'});
within_fast = table({'250','350','450','550'}', 'VariableNames',{'RT'});

between_acc  = table(err_acc(:,1), err_acc(:,2), err_acc(:,3), err_acc(:,4), err_acc(:,5), err_acc(:,6), ...
  'VariableNames',{'meas1','meas2','meas3','meas4','meas5','meas6'});

between_fast  = table(err_fast(:,1), err_fast(:,2), err_fast(:,3), err_fast(:,4), ...
  'VariableNames',{'meas1','meas2','meas3','meas4'});

fit_rm.acc = fitrm(between_acc, 'meas1-meas6 ~ 1', 'WithinDesign',within_acc); %no between-subjects factors
fit_rm.fast = fitrm(between_fast, 'meas1-meas4 ~ 1', 'WithinDesign',within_fast); %no between-subjects factors

ranova_.acc = ranova(fit_rm.acc);
ranova_.fast = ranova(fit_rm.fast);

end

