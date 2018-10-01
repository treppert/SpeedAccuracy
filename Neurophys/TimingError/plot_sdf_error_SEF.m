function [ ] = plot_sdf_error_SEF( spikes , ninfo , moves , binfo )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);

TOL_ERROR = 5; %millisec
MIN_NUM_TRIAL = 10;

TIME_ZERO = 3500;
TIME_VEC = (-600 : 600);
NUM_SAMP = length(TIME_VEC);

sdf_CorrFast = NaN(NUM_CELLS, NUM_SAMP);
sdf_CorrAcc = NaN(NUM_CELLS, NUM_SAMP);
sdf_ErrFast = NaN(NUM_CELLS, NUM_SAMP);
sdf_ErrAcc = NaN(NUM_CELLS, NUM_SAMP);

RT_CorrFast = NaN(1,NUM_CELLS);
RT_CorrAcc = NaN(1,NUM_CELLS);
RT_ErrFast = NaN(1,NUM_CELLS);
RT_ErrAcc = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  
  sdf = compute_spike_density_fxn(spikes(cc).SAT);
  
  %get session number corresponding to behavioral data
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  resptime = moves(kk).resptime;
  
  %align SDF to response
  sdf = align_signal_on_response(sdf, resptime);
  
  %index by condition
  idx_fast = (binfo(kk).condition == 3);
  idx_acc = (binfo(kk).condition == 1);
  
  %index by error
  err_RT = resptime - binfo(kk).tgt_dline;
  ierr_fast = (idx_fast & (err_RT > TOL_ERROR));  icorr_fast = (idx_fast & (err_RT < 0));
  ierr_acc = (idx_acc & (err_RT < -TOL_ERROR));  icorr_acc = (idx_acc & (err_RT > 0));
  
  if (sum(icorr_fast) >= MIN_NUM_TRIAL)
    RT_CorrFast(cc) = median(resptime(icorr_fast));
    sdf_CorrFast(cc,:) = mean(sdf(icorr_fast,TIME_ZERO + TIME_VEC));
  end
  
  if (sum(icorr_acc) >= MIN_NUM_TRIAL)
    RT_CorrAcc(cc) = median(resptime(icorr_acc));
    sdf_CorrAcc(cc,:) = mean(sdf(icorr_acc,TIME_ZERO + TIME_VEC));
  end
  
  if (sum(ierr_fast) >= MIN_NUM_TRIAL)
    RT_ErrFast(cc) = median(resptime(ierr_fast));
    sdf_ErrFast(cc,:) = mean(sdf(ierr_fast,TIME_ZERO + TIME_VEC));
  end
  
  if (sum(ierr_acc) >= MIN_NUM_TRIAL)
    RT_ErrAcc(cc) = median(resptime(ierr_acc));
    sdf_ErrAcc(cc,:) = mean(sdf(ierr_acc,TIME_ZERO + TIME_VEC));
  end
  
end%for:cells(kk)

% %normalization
% sdf_CorrFast_Sacc = sdf_CorrFast_Sacc ./ bline_avg';
% sdf_ErrDir_Sacc = sdf_ErrDir_Sacc ./ bline_avg';
% sdf_ErrTIME_VEC = sdf_ErrTIME_VEC ./ bline_avg';

%% Plotting - individual cells

for cc = 1:NUM_CELLS
  
  linmin = min([sdf_CorrFast(cc,:),sdf_CorrAcc(cc,:)]);
  linmax = max([sdf_ErrFast(cc,:),sdf_ErrAcc(cc,:)]);
  
  figure(); hold on
  plot([0 0], [linmin linmax], 'k--')
  plot(-RT_CorrAcc(cc)*ones(1,2), [linmin linmax], 'r-')
  plot(-RT_CorrFast(cc)*ones(1,2), [linmin linmax], '-', 'Color',[0 .7 0])
  plot(-RT_ErrAcc(cc)*ones(1,2), [linmin linmax], 'r-.')
  plot(-RT_ErrFast(cc)*ones(1,2), [linmin linmax], '-.', 'Color',[0 .7 0])
  plot(TIME_VEC, sdf_CorrFast(cc,:), '-', 'LineWidth',1.0, 'Color',[0 .7 0])
  plot(TIME_VEC, sdf_ErrFast(cc,:), ':', 'LineWidth',1.0, 'Color',[0 .7 0])
  plot(TIME_VEC, sdf_CorrAcc(cc,:), 'r-', 'LineWidth',1.0)
  plot(TIME_VEC, sdf_ErrAcc(cc,:), 'r:', 'LineWidth',1.0)
  xlim([-605 605]); xticks(-600:200:600); %yticks([])
  
  ppretty('image_size',[2.4,2])
  print_session_unit(gca, ninfo(cc), 'horizontal')
  pause(0.25)
  print(['~/Dropbox/tmp/',ninfo(cc).sesh,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(0.25)
end

return
%% Plotting - average across cells

NUM_SEM = sum([ninfo.errTime] == -1);

figure(); hold on
plot(mean(time_rew)*ones(1,2), [1 2], 'k--')
shaded_error_bar(TIME_VEC, nanmean(sdf_Corr_Sacc), nanstd(sdf_Corr_Sacc)/sqrt(NUM_SEM), {'k-'})
shaded_error_bar(TIME_VEC, nanmean(sdf_ErrTIME_VEC), nanstd(sdf_ErrTIME_VEC)/sqrt(NUM_SEM), {'r-'})
% shaded_error_bar(TIME_VEC, nanmean(sdf_ErrDir_Sacc), nanstd(sdf_ErrDir_Sacc)/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0]})
ppretty('image_size',[4.8,3])

end%function:plot_sdf_error_SEF()
