function [ varargout ] = plot_sdf_ChoiceError_SAT( spikes , ninfo , moves , binfo )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

PLOT_INDIVIDUAL_CELLS = false;
NORMALIZE = true;

TIME_POSTSACC  = 3500 + (-400 : 400);
NSAMP_POSTSACC = length(TIME_POSTSACC);
TIME_TEST_MANNWHITNEY = 3500 + (1 : 400);
NUM_CELLS = length(spikes);

%activity re. saccade initiation
A_corr = NaN(NUM_CELLS,NSAMP_POSTSACC);
A_err  = NaN(NUM_CELLS,NSAMP_POSTSACC);

%median RT for each condition X trial outcome
RT_corr = NaN(1,NUM_CELLS);
RT_err = NaN(1,NUM_CELLS);

%time of separation of SDFs
t_sep_err = NaN(1,NUM_CELLS);

%direction of error-related modulation
dir_sep_err = cell(1,NUM_CELLS);

binfo = index_timing_errors_SAT(binfo, moves);

%% Compute the SDFs split by condition and correct/error

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  TRIAL_POOR_ISOLATION = false(1,binfo(kk).num_trials);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, moves(kk).resptime); 
  
  %remove trials with poor unit isolation
%   if (ninfo(cc).iRem1)
%     TRIAL_POOR_ISOLATION(ninfo(cc).iRem1 : ninfo(cc).iRem2) = true;
%   end
  
  %index by condition
  idx_cond = ((binfo(kk).condition == 3) & ~TRIAL_POOR_ISOLATION);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_err = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %control for choice error direction
  [idx_err, idx_corr] = equate_respdir_err_vs_corr(idx_err, idx_corr, moves(kk).octant);
  
  A_corr(cc,:) = nanmean(sdf_kk(idx_cond & idx_corr,TIME_POSTSACC));
  A_err(cc,:) = nanmean(sdf_kk(idx_cond & idx_err,TIME_POSTSACC));
  
  %assess time of separation between A_corr and A_err
  sdf_corr_test = sdf_kk(idx_cond & idx_corr,TIME_TEST_MANNWHITNEY);
  sdf_err_test = sdf_kk(idx_cond & idx_err,TIME_TEST_MANNWHITNEY);
  t_sep_err(cc) = compute_time_sep_sdf_SAT(sdf_corr_test, sdf_err_test, 'min_length',20);
  
  %assess direction of error-related modulation (if any)
  if isnan(t_sep_err(cc))
    dir_sep_err{cc} = 'N';
  elseif (A_err(cc,400+t_sep_err(cc)) > A_corr(cc,400+t_sep_err(cc)))
    dir_sep_err{cc} = 'E';
  else
    dir_sep_err{cc} = 'C';
  end
  
  %save median RTs
  RT_corr(cc) = nanmedian(moves(kk).resptime(idx_cond & idx_corr));
  RT_err(cc) = nanmedian(moves(kk).resptime(idx_cond & idx_err));
  
%   pause(1.0)
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = t_sep_err;
  if (nargout > 1)
    varargout{2} = dir_sep_err;
  end
end

fprintf('%d and %d (out of %d) cells with E- and C-modulation\n', sum(ismember(dir_sep_err, {'E'})), ...
  sum(ismember(dir_sep_err, {'C'})), NUM_CELLS)

%% Plotting - across-cell average
TIME_PLOT = TIME_POSTSACC - 3500;
% IDX_CC_PLOT = ismember(dir_sep_err, {'E'});
IDX_CC_PLOT = true(1,NUM_CELLS);

A_DIFF = A_err(IDX_CC_PLOT,:) - A_corr(IDX_CC_PLOT,:);

if (NORMALIZE)
%   NORM_FACTOR = max(A_DIFF,[],2);
  NORM_FACTOR = A_corr(:,400);
  A_DIFF = A_DIFF ./ NORM_FACTOR;
end

figure(); hold on

% plot(TIME_PLOT, A_DIFF, 'k-')
shaded_error_bar(TIME_PLOT, mean(A_DIFF), std(A_DIFF)/sqrt(sum(IDX_CC_PLOT)), ...
  {'LineWidth',1.5, 'Color',[0 .5 0]})

xlim([TIME_PLOT(1), TIME_PLOT(end)])
xlabel('Time re. saccade (ms)')
ylabel('Difference in normalized activity')

ppretty('image_size',[6,4])


%% Plotting - individual cells
if (PLOT_INDIVIDUAL_CELLS)
TIME_PLOT = TIME_POSTSACC - 3500;

for cc = 1:NUM_CELLS
%   if ~strcmp(dir_sep_err{cc}, 'C'); continue; end
  lim_lin = [min([A_corr(cc,:), A_err(cc,:)]), max([A_corr(cc,:), A_err(cc,:)])];
  
  figure(); hold on
  
  plot([0 0], lim_lin, 'k--', 'LineWidth',1.0)
  plot(-RT_corr(cc)*ones(1,2), lim_lin, '-', 'Color',[0 .5 0])
  plot(-RT_err(cc)*ones(1,2), lim_lin, ':', 'Color',[0 .5 0])
%   plot(t_sep_err(cc)*ones(1,2), lim_lin, 'k:')
  
  plot(TIME_PLOT, A_corr(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',1.5)
  plot(TIME_PLOT, A_err(cc,:), ':', 'Color',[0 .7 0], 'LineWidth',1.5)
  
  xlim([TIME_PLOT(1), TIME_PLOT(end)])
  xlabel('Time re. saccade (ms)')
  ylabel('Activity (sp/sec)')
  print_session_unit(gca, ninfo(cc))
  
  ppretty('image_size',[6,4])
  print_fig_SAT(ninfo(cc), gcf, '-dtiff')
  
  pause(0.5)
  
end%for:cells(cc)
end%if(PLOT_INDIVIDUAL_CELLS)

end%function:plot_sdf_error_SEF()
