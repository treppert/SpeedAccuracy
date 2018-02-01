function [  ] = plot_baseline_vs_trial( binfo , ninfo , spikes , bline_avg , monkey )
%plot_baseline_vs_trial Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);

MIN_GRADE = 3;
MIN_BLINE = 5; %sp/sec
NUM_SEM = sum(([ninfo.vis] >= MIN_GRADE) & (bline_avg >= MIN_BLINE));

TIME_STIM = 3500;
TIME_BASE = ( -500 : -1 );

TRIAL_PLOT = ( -2 : 1 ) ;
NUM_TRIALS = length(TRIAL_PLOT);

trial_switch = identify_condition_switch( binfo , monkey );
% bline_avg = calc_avg_baseline_SAT( spikes );

%% Compute baseline activity vs. trial

bline_F2A = NaN(NUM_CELLS,NUM_TRIALS);
bline_A2F = NaN(NUM_CELLS,NUM_TRIALS);

for kk = 1:NUM_CELLS
  if (ninfo(kk).vis < MIN_GRADE); continue; end
  if (bline_avg(kk) < MIN_BLINE); continue; end
  
  sesh = find(ismember({binfo.session}, ninfo(kk).sesh));
  
  for jj = 1:NUM_TRIALS
    
    sdf_bline_F2A = compute_spike_density_fxn( spikes(kk).SAT(trial_switch(sesh).F2A + TRIAL_PLOT(jj)));
    sdf_bline_A2F = compute_spike_density_fxn( spikes(kk).SAT(trial_switch(sesh).A2F + TRIAL_PLOT(jj)));
    
    bline_F2A(kk,jj) = mean(mean(sdf_bline_F2A(:,TIME_STIM + TIME_BASE)));
    bline_A2F(kk,jj) = mean(mean(sdf_bline_A2F(:,TIME_STIM + TIME_BASE)));
    
  end%for:trials(jj)
  
end%for:cells(kk)

%normalization
bline_F2A = bline_F2A ./ bline_avg';
bline_A2F = bline_A2F ./ bline_avg';

%% Plotting

figure(); hold on

% plot([-2.5 -2.5], [0.8 1.2], 'k--')
% plot([1.5 1.5], [0.8 1.2], 'k--')

% plot((-4:-1), bline_F2A, 'LineWidth',1.25)
% plot( (0:3),  bline_A2F, 'LineWidth',1.25)
errorbar_no_caps((-4:-1), nanmean(bline_F2A), 'err',nanstd(bline_F2A)/sqrt(NUM_SEM), 'color','k')
errorbar_no_caps( (0:3),  nanmean(bline_A2F), 'err',nanstd(bline_A2F)/sqrt(NUM_SEM), 'color','k')

xlim([-4.2 3.2]); xticks(-4 : 3)
xticklabels({'-2','-1','0','+1','-2','-1','0','+1'})

ppretty()%'image_size',[5,5])

end%function:plot_baseline_vs_trial()

