function [  ] = compute_avg_vigor_SAT( info , moves )
%compute_avg_vigor_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

vigor_A = NaN(1,NUM_SESSION);
vigor_F = NaN(1,NUM_SESSION);

info = index_timing_errors_SAT(info, moves);

for kk = 1:NUM_SESSION
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  ierr_dir = info(kk).Task_ErrChoice;
  ierr_time = info(kk).Task_ErrTime;
  
  vigor_A(kk) = nanmean(moves(kk).vigor(idx_acc));
  vigor_F(kk) = nanmean(moves(kk).vigor(idx_fast));

  %err_dir(kk).acc = sum(idx_acc & ierr_dir) / sum(idx_acc);
  %err_dir(kk).fast = sum(idx_fast & ierr_dir) / sum(idx_fast);
  
  %err_time(kk).acc = sum(idx_acc & ierr_time) / sum(idx_acc);
  %err_time(kk).fast = sum(idx_fast & ierr_time) / sum(idx_fast);
  
end%for:sessions(kk)

fprintf('Vigor: ACC %g +- %g  FAST %g +- %g\n', ...
	nanmean(vigor_A), nanstd(vigor_A)/sqrt(NUM_SESSION), ...
	nanmean(vigor_F), nanstd(vigor_F)/sqrt(NUM_SESSION))


%% Now compute vigor X condition X choice error

vigor_corr_A = NaN(1,NUM_SESSION);
vigor_corr_F = NaN(1,NUM_SESSION);
vigor_errdir_A = NaN(1,NUM_SESSION);
vigor_errdir_F = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION

  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  idx_corr = ~(info(kk).Task_ErrChoice | info(kk).Task_ErrHold);
  idx_errdir = info(kk).Task_ErrChoice;

  vigor_corr_A(kk) = nanmean(moves(kk).vigor(idx_corr & idx_acc));
  vigor_corr_F(kk) = nanmean(moves(kk).vigor(idx_corr & idx_fast));

  vigor_errdir_A(kk) = nanmean(moves(kk).vigor(idx_errdir & idx_acc));
  vigor_errdir_F(kk) = nanmean(moves(kk).vigor(idx_errdir & idx_fast));

end%for:session(kk)

fprintf('\nVigor -- Correct: ACC %g +- %g  FAST %g +- %g\n', ...
	nanmean(vigor_corr_A), nanstd(vigor_corr_A)/sqrt(NUM_SESSION), ...
	nanmean(vigor_corr_F), nanstd(vigor_corr_F)/sqrt(NUM_SESSION))

fprintf('Vigor -- Choice Error: ACC %g +- %g  FAST %g +- %g\n', ...
	nanmean(vigor_errdir_A), nanstd(vigor_errdir_A)/sqrt(NUM_SESSION), ...
	nanmean(vigor_errdir_F), nanstd(vigor_errdir_F)/sqrt(NUM_SESSION))

end%function:compute_avg_vigor_SAT()
