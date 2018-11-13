function [  ] = plot_baseline_vs_switch_SAT( binfo , moves , ninfo , spikes , bline_avg , monkey )
%plot_baseline_vs_trial Summary of this function goes here
%   Detailed explanation goes here

DEBUG = true;

NUM_CELLS = length(spikes);

% MIN_BLINE = 2; %sp/sec
% NUM_SEM = sum([bline_avg.all] >= MIN_BLINE);

TIME_STIM = 3500;
TIME_BASE = ( -700 : -1 );
IDX_BASE = TIME_BASE([1,end]) + TIME_STIM;

TRIAL_PLOT = ( -3 : 2 ) ;
NUM_TRIALS = length(TRIAL_PLOT);

binfo = index_timing_errors_SAT(binfo, moves);
trial_switch = identify_condition_switch( binfo , monkey );

%% Compute baseline activity vs. trial

bline_F2A = NaN(NUM_CELLS,NUM_TRIALS);
bline_A2F = NaN(NUM_CELLS,NUM_TRIALS);

for cc = 1:NUM_CELLS
%   if (bline_avg(cc).all < MIN_BLINE); continue; end
  
  kk = find(ismember({binfo.session}, ninfo(cc).sesh));
  
  %count spikes in the appropriate baseline interval
  num_sp_bline = NaN(1,binfo(kk).num_trials);
  for jj = 1:binfo(kk).num_trials
    num_sp_bline(jj) = sum((spikes(cc).SAT{jj} > IDX_BASE(1)) & (spikes(cc).SAT{jj} > IDX_BASE(2)));
  end
  
  for jj = 1:NUM_TRIALS
    bline_F2A(cc,jj) = mean(num_sp_bline(trial_switch(kk).F2A + TRIAL_PLOT(jj)));
    bline_A2F(cc,jj) = mean(num_sp_bline(trial_switch(kk).A2F + TRIAL_PLOT(jj)));
  end%for:trials(jj)
  
  if (DEBUG)
    tmp = [bline_F2A(cc,:),bline_A2F(cc,:)];
    Y_LIM = [ min(tmp)-2 , max(tmp)+2 ];
    
    figure()
    
    subplot(1,2,1); hold on
    plot(TRIAL_PLOT(1:3), bline_F2A(cc,1:3), '.-', 'Color',[0 .7 0])
    plot(TRIAL_PLOT(4:6), bline_F2A(cc,4:6), 'r.-')
    xlim([-3.5 2.5]); ylim(Y_LIM)
    
    subplot(1,2,2); hold on
    plot(TRIAL_PLOT(1:3), bline_A2F(cc,1:3), 'r.-')
    plot(TRIAL_PLOT(4:6), bline_A2F(cc,4:6), '.-', 'Color',[0 .7 0])
    xlim([-3.5 2.5]); ylim(Y_LIM)
    
    pause(1.0)
    
  end%if:DEBUG
  
end%for:cells(cc)

if (DEBUG)
  return
end

%normalization
bline_F2A = bline_F2A - repmat([bline_avg.all]', 1,NUM_TRIALS);
bline_A2F = bline_A2F - repmat([bline_avg.all]', 1,NUM_TRIALS);

%% Plotting

figure(); hold on
plot(TRIAL_PLOT, bline_F2A, 'k-', 'LineWidth',0.75)
plot(TRIAL_PLOT, mean(bline_F2A), 'b-', 'LineWidth',1.5)
% errorbar_no_caps(TRIAL_PLOT, nanmean(bline_F2A), 'err',nanstd(bline_F2A)/sqrt(NUM_SEM), 'color','k')
ppretty()

pause(0.25)

figure(); hold on
plot(TRIAL_PLOT, bline_A2F, 'k-', 'LineWidth',0.75)
plot(TRIAL_PLOT, mean(bline_A2F), 'b-', 'LineWidth',1.5)
% errorbar_no_caps(TRIAL_PLOT,  nanmean(bline_A2F), 'err',nanstd(bline_A2F)/sqrt(NUM_SEM), 'color','k')
ppretty()

end%function:plot_baseline_vs_trial()

