function [  ] = plot_vigor_at_switch( moves , info , monkey )
%plot_vigor_at_switch Summary of this function goes here
%   Detailed explanation goes here

MIN_NUM_TRIALS = 8;
NUM_SESSION = length(moves);

Vig_TimeErr = [];
Vig_TimeCorr = [];

trial_switch = identify_condition_switch(info, monkey);

for kk = 1:NUM_SESSION
  
  num_F2A = length(trial_switch(kk).F2A);
  
  if (num_F2A < MIN_NUM_TRIALS); continue; end
  
  idx_err = find(info(kk).err_time);
  idx_corr = find(~info(kk).err_time);
  
%   err_RT = moves(kk).resptime - info(kk).tgt_dline;
%   idx_err = find(err_RT < -25);
%   idx_corr = find(err_RT > 25);
  
  idx_F2A_err = intersect(trial_switch(kk).F2A, idx_err);
  idx_F2A_corr = intersect(trial_switch(kk).F2A, idx_corr);
  
  Vig_TimeErr = cat(2, Vig_TimeErr, moves(kk).vigor(idx_F2A_err));
  Vig_TimeCorr = cat(2, Vig_TimeCorr, moves(kk).vigor(idx_F2A_corr));
  
end%for:session(kk)

% figure(); hold on
% histogram(Vig_TimeCorr, 'BinWidth',.02, 'FaceColor','k', 'Normalization','probability')
% histogram(Vig_TimeErr, 'BinWidth',.02, 'FaceColor','r', 'Normalization','probability')

Vig_TimeErr(isnan(Vig_TimeErr)) = [];
Vig_TimeCorr(isnan(Vig_TimeCorr)) = [];

y_TimeErr = (1:length(Vig_TimeErr)) / length(Vig_TimeErr);
y_TimeCorr = (1:length(Vig_TimeCorr)) / length(Vig_TimeCorr);

figure(); hold on
plot(sort(Vig_TimeCorr), y_TimeCorr, 'k-')
plot(sort(Vig_TimeErr), y_TimeErr, 'r-')
ppretty(); pause(0.25)

end%function:plot_vigor_at_switch()

