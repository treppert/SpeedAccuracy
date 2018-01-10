function [ ] = plot_prob_error_vs_rxntime_SAT( moves , info )
%[  ] = plot_pv_vs_rt_within_SAT( moves , info )
%   Detailed explanation goes here

MIN_PER_BIN = 1;
MIN_NUM_SESSION = 2;

%set up the RT bins to average data
BIN_LIM = 200 : 50 : 800;
NUM_BIN = length(BIN_LIM) - 1;
RT_PLOT  = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

if (~isfield(moves, 'err_direction'))
  moves = determine_errors_FEF(moves, info);
end

%% Get binned vigor for each session
NUM_SESSIONS = length(moves);
prob_acc = NaN(NUM_BIN,NUM_SESSIONS);
prob_fast = prob_acc;

for kk = 1:NUM_SESSIONS
  
  idx_acc  = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  for jj = 1:NUM_BIN %loop over RT bins
    
    idx_jj = (moves(kk).resptime > BIN_LIM(jj)) & (moves(kk).resptime < BIN_LIM(jj+1));
    
    if (sum(idx_jj & idx_acc) >= MIN_PER_BIN)
      prob_acc(jj,kk) = sum(moves(kk).err_direction(idx_jj & idx_acc)) / sum(idx_jj & idx_acc);
    end
    if (sum(idx_jj & idx_fast) >= MIN_PER_BIN)
      prob_fast(jj,kk) = sum(moves(kk).err_direction(idx_jj & idx_fast)) / sum(idx_jj & idx_fast);
    end
    
  end%for:RT bins(jj)
  
end%for:sessions(kk)

%% Compute RM-ANOVA
% compute_ranova_Perr(prob_fast, RT_PLOT)
% compute_ranova_Perr(prob_acc, RT_PLOT)

%% Plot across all sessions

num_sem_acc = sum(~isnan(prob_acc),2);
prob_acc(num_sem_acc < MIN_NUM_SESSION,:) = NaN;

num_sem_fast = sum(~isnan(prob_fast),2);
prob_fast(num_sem_fast < MIN_NUM_SESSION,:) = NaN;

figure(); hold on

% subplot(2,1,1); hold on
errorbar_no_caps(RT_PLOT, nanmean(prob_acc,2), 'err',nanstd(prob_acc,0,2)./sqrt(num_sem_acc), ...
  'color','r', 'marker','d')
errorbar_no_caps(RT_PLOT, nanmean(prob_fast,2), 'err',nanstd(prob_fast,0,2)./sqrt(num_sem_fast), ...
  'color',[0 .7 0], 'marker','d')
xlim([175 800]); xticks(200:100:800)
xticklabels({'200','','400','','600','','800'})
ppretty()

% subplot(2,1,2); hold on
% plot_prob_distr_rt_SAT(moves_tr, info, 'subplot')

% ppretty('image_size',[3.2,5]); pause(.1)
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'))


end%function:plot_prob_error_vs_rxntime_SAT()


function [  ] = compute_ranova_Perr( Perr , RT )

%define the levels of the independent variable (RT)
within = table(RT', 'VariableNames',{'RT'});

%structure factors and response values for input into RM model
% data_rm = table(Perr(1,:)', Perr(2,:)', Perr(3,:)', Perr(4,:)', Perr(5,:)', Perr(6,:)', Perr(7,:)', Perr(8,:)', ...
%   Perr(9,:)', Perr(10,:)', Perr(11,:)', Perr(12,:)', ...
%   'VariableNames', {'t1','t2','t3','t4','t5','t6','t7','t8','t9','t10','t11','t12'});
data_rm = table(Perr(1,:)', Perr(2,:)', Perr(3,:)', Perr(4,:)', Perr(5,:)', Perr(6,:)', ...
  'VariableNames', {'t1','t2','t3','t4','t5','t6'});

%fit the Repeated-Measures model
fit_rm = fitrm(data_rm, 't1-t6 ~ 1', 'WithinDesign',within);

% anova(fit_rm)
ranova(fit_rm)

end%util:compute_ranova_vigor()
