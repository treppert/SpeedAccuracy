function [  ] = plot_vigor_vs_rxntime_SAT( moves , info )
%[  ] = plot_pv_vs_rt_within_SAT( moves , info )
%   Detailed explanation goes here

MIN_PER_BIN = 10;
MIN_NUM_SESSION = 3;

%set up the RT bins to average data
BIN_LIM = 200 : 40 : 800;
NUM_BIN = length(BIN_LIM) - 1;
RT_PLOT  = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

%% Get binned vigor for each session
NUM_SESSIONS = length(moves);
vigor = new_struct({'acc','fast','all'}, 'dim',[NUM_BIN,NUM_SESSIONS]);

for kk = 1:NUM_SESSIONS
  
  idx_taskrel = ~isnan(moves(kk).vigor);
  
  idx_fast = ((info(kk).condition == 3) & idx_taskrel);
  idx_acc  = ((info(kk).condition == 1) & idx_taskrel);
  
  tmp = bin_saccades(BIN_LIM, moves(kk).resptime(idx_fast), double(moves(kk).vigor(idx_fast)), MIN_PER_BIN);
  [vigor(:,kk).fast] = deal(tmp{:});
  tmp = bin_saccades(BIN_LIM, moves(kk).resptime(idx_acc), double(moves(kk).vigor(idx_acc)), MIN_PER_BIN);
  [vigor(:,kk).acc] = deal(tmp{:});
  tmp = bin_saccades(BIN_LIM, moves(kk).resptime(idx_acc|idx_fast), double(moves(kk).vigor(idx_acc|idx_fast)), MIN_PER_BIN);
  [vigor(:,kk).all] = deal(tmp{:});
  
end


%% Plot across all sessions

mean_vig = mean_struct( vigor , 2 );

mean_acc = reshape([mean_vig.acc], NUM_BIN,NUM_SESSIONS);
mean_fast = reshape([mean_vig.fast], NUM_BIN,NUM_SESSIONS);

num_sem_acc = sum(~isnan(mean_acc),2);
num_sem_fast = sum(~isnan(mean_fast),2);

mean_acc(num_sem_acc < MIN_NUM_SESSION,:) = NaN;
mean_fast(num_sem_fast < MIN_NUM_SESSION,:) = NaN;

figure(); hold on

% subplot(2,1,1); hold on
% errorbar_no_caps(RT_PLOT, nanmean(mean_acc,2), 'err',nanstd(mean_acc,0,2)./sqrt(num_sem_acc), 'marker','d', 'color','r')
% errorbar_no_caps(RT_PLOT, nanmean(mean_fast,2), 'err',nanstd(mean_fast,0,2)./sqrt(num_sem_fast), 'marker','d', 'color',[0 .7 0])
plot(RT_PLOT, mean_fast, 'd-', 'color',[0 .7 0])
xlim([175 800]); xticks(200:100:800)
xticklabels({'200','','400','','600','','800'})
ppretty('image_size',[3.2,2])
% axis_vig = gca;

% subplot(2,1,2); hold on
% plot_prob_distr_rt_SAT(moves_tr, info, 'subplot')

% ppretty('image_size',[3.2,5])

end%function:plot_vigor_vs_rxntime_SAT()

function [ vigor_bin ] = bin_saccades( bin_lim , resptime , vigor , min_per_bin )

%initialize output
NUM_BIN = length(bin_lim) - 1;
vigor_bin = cell(NUM_BIN,1);

%loop over response time bins
for jj = 1:NUM_BIN
  idx_jj = (resptime > bin_lim(jj)) & (resptime <= bin_lim(jj+1));
  if (sum(idx_jj) >= min_per_bin)
    vigor_bin{jj} = vigor(idx_jj);
  else
    vigor_bin{jj} = NaN;
  end
end

end%function:bin_saccades()



function [ ranova_ ] = compute_ranova_vigor( vigor )

%define the levels of the independent variable -- time
within = table({'225','275','325','375','425','475','525','575','625','675','725','775'}', ...
  'VariableNames',{'resptime'});

between  = table(vigor(1,:)', vigor(2,:)', vigor(3,:)', vigor(4,:)', vigor(5,:)', ...
  vigor(6,:)', vigor(7,:)', vigor(8,:)', vigor(9,:)', vigor(10,:)', vigor(11,:)', vigor(12,:)', ...
  'VariableNames',{'meas1','meas2','meas3','meas4','meas5','meas6','meas7','meas8','meas9','meas10','meas11','meas12'});

fit_rm.acc = fitrm(between, 'meas1-meas12 ~ 1', 'WithinDesign',within); %no between-subjects factors

ranova_.acc = ranova(fit_rm.acc);

end%util:compute_ranova_vigor()

