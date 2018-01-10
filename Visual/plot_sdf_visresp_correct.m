function [ varargout ] = plot_sdf_visresp_correct( spikes , ninfo , moves , binfo )
%[ ] = plot_sdf_visual_response( varargin )
%   Detailed explanation goes here

% REMOVE_SPIKES_POST_RESP = false;
PLOT_INDIV = false;
MIN_NUM_TRIALS = 5;

%average across visual and visuo-movement cells
TYPE_PLOT = {'V','VM'};

%specify time limits for plotting
T_LIM = [0,500];
TIME_PLOT = (T_LIM(1):T_LIM(2));

NUM_CELLS = length(spikes);
TIME_ARRAY = 3500;

%get saccade error information
moves = determine_errors_SAT(moves, binfo);

%% Initialize output information

sdf_Tin = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
sdf_Tin = populate_struct(sdf_Tin, {'acc','fast'}, NaN(6001,1));
sdf_Din = sdf_Tin;

tst = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
tst = populate_struct(tst, {'acc','fast'}, NaN);

%% Compute the SDF corresponding to Target In RF vs. Distractor In RF

for kk = 1:NUM_CELLS
  %make sure we have vis- or vis-move cell
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).session);
  
  %index by response accuracy
  idx_err = (moves(kk_moves).err_direction | moves(kk_moves).err_timing);
  
  %index by condition
  idx_fast = (binfo(kk_moves).condition == 3);
  idx_acc = (binfo(kk_moves).condition == 1);
  
  %index by location of singleton re. RF (Target In vs. Distractor In)
  idx_Tin = ismember(binfo(kk_moves).tgt_octant, ninfo(kk).resp_field);
  
  %% Compute spike density function
  
  sdf_kk = compute_spike_density_fxn(spikes(kk).SAT);
  
%   if (REMOVE_SPIKES_POST_RESP)
%     sdf_kk = remove_spikes_post_response(sdf_kk, moves(kk_moves).resptime);
%   end
  
  %SDFs for Target In
  if (sum(idx_Tin & ~idx_err & idx_acc) >= MIN_NUM_TRIALS)
    sdf_Tin(kk).acc(:) = transpose(nanmean(sdf_kk(idx_Tin & ~idx_err & idx_acc,:)));
    tst(kk).acc = compute_TST_MannWhitney(sdf_kk(idx_Tin & ~idx_err & idx_acc,:), sdf_kk(~idx_Tin & ~idx_err & idx_acc,:));
  end
  if (sum(idx_Tin & ~idx_err & idx_fast) >= MIN_NUM_TRIALS)
    sdf_Tin(kk).fast(:) = transpose(nanmean(sdf_kk(idx_Tin & ~idx_err & idx_fast,:)));
    tst(kk).fast = compute_TST_MannWhitney(sdf_kk(idx_Tin & ~idx_err & idx_fast,:), sdf_kk(~idx_Tin & ~idx_err & idx_fast,:));
  end
  
  %SDFs for Distractor In
  sdf_Din(kk).acc(:) = transpose(nanmean(sdf_kk(~idx_Tin & ~idx_err & idx_acc,:)));
  sdf_Din(kk).fast(:) = transpose(nanmean(sdf_kk(~idx_Tin & ~idx_err & idx_fast,:)));
  
  %% Compute target selection time
  
  
  %if only have TST for one condition, then remove
  if (isnan(tst(kk).acc) || isnan(tst(kk).fast))
    tst(kk).acc = NaN;
    tst(kk).fast = NaN;
  end
  
end%for:cells(kk)

if (nargout > 0)
  varargout{1} = tst;
end

%% Plotting - Individual cells
if (PLOT_INDIV)
  
  for kk = 1:NUM_CELLS
    if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
    
    figure()
    
    subplot(2,1,1); hold on
    plot(TIME_PLOT, sdf_Tin(kk).acc(TIME_PLOT+TIME_ARRAY), 'r-', 'LineWidth',1.25)
    plot(TIME_PLOT, sdf_Din(kk).acc(TIME_PLOT+TIME_ARRAY), 'r--', 'LineWidth',1.0)
    plot(tst(kk).acc*ones(1,2), [0 max(sdf_Tin(kk).acc)], 'k--')
    xlim([T_LIM(1)-10, T_LIM(2)+10]); xticklabels(cell(1,length(get(gca,'xtick'))))
    
    subplot(2,1,2); hold on
    plot(TIME_PLOT, sdf_Tin(kk).fast(TIME_PLOT+TIME_ARRAY), '-', 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(TIME_PLOT, sdf_Din(kk).fast(TIME_PLOT+TIME_ARRAY), '--', 'Color',[0 .7 0], 'LineWidth',1.0)
    plot(tst(kk).fast*ones(1,2), [0 max(sdf_Tin(kk).fast)], 'k--')
    xlim([T_LIM(1)-10, T_LIM(2)+10])
    
    print_session_unit(gca, ninfo(kk), 'type')
    ppretty('image_size',[3.2,5]); pause(1.5)
    
  end%for:cells(kk)
  
  return
  
end%plot individual cells?

%% Plotting - across-cell average
norm_factor = util_compute_normfactor_visresp(spikes, ninfo, binfo);

tst_acc = [tst.acc];
tst_fast = [tst.fast];

idx_plot = ~isnan(tst_acc); %only include SDFs for cells with TST
NUM_SEM = sum(idx_plot);

sdf_Tin_acc = [sdf_Tin.acc] ./ norm_factor;     sdf_Tin_acc = sdf_Tin_acc(TIME_PLOT+TIME_ARRAY,idx_plot);
sdf_Tout_acc = [sdf_Din.acc] ./ norm_factor;    sdf_Tout_acc = sdf_Tout_acc(TIME_PLOT+TIME_ARRAY,idx_plot);

sdf_Tin_fast = [sdf_Tin.fast] ./ norm_factor;   sdf_Tin_fast = sdf_Tin_fast(TIME_PLOT+TIME_ARRAY,idx_plot);
sdf_Tout_fast = [sdf_Din.fast] ./ norm_factor;  sdf_Tout_fast = sdf_Tout_fast(TIME_PLOT+TIME_ARRAY,idx_plot);

figure()

subplot(2,1,1); hold on
shaded_error_bar(TIME_PLOT, nanmean(sdf_Tin_acc,2), nanstd(sdf_Tin_acc,0,2)/sqrt(NUM_SEM), {'r-', 'LineWidth',1.25})
shaded_error_bar(TIME_PLOT, nanmean(sdf_Tout_acc,2), nanstd(sdf_Tout_acc,0,2)/sqrt(NUM_SEM), {'r--', 'LineWidth',1.25})
plot(nanmean(tst_acc)*ones(1,2), [0.0 1.0], 'k--')
xlim([T_LIM(1)-10, T_LIM(2)+10]); xticklabels(cell(1,length(get(gca,'xtick')))); pause(.1)

subplot(2,1,2); hold on
shaded_error_bar(TIME_PLOT, nanmean(sdf_Tin_fast,2), nanstd(sdf_Tin_fast,0,2)/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
shaded_error_bar(TIME_PLOT, nanmean(sdf_Tout_fast,2), nanstd(sdf_Tout_fast,0,2)/sqrt(NUM_SEM), {'--', 'Color',[0 .7 0], 'LineWidth',1.25})
plot(nanmean(tst_fast)*ones(1,2), [0.0 1.0], 'k--')
xlim([T_LIM(1)-10, T_LIM(2)+10])

ppretty('image_size',[3.2,5])
% y_tick = get(gca, 'ytick')'; set(gca, 'yticklabel',num2str(y_tick,'%.1f'))


%% Plotting - TST comparison
[~,pval] = ttest(tst_acc', tst_fast');

figure(); hold on
plot(tst_acc, tst_fast, 'ko')
plot([150 240], [150 240], 'k--')
title(['p=',num2str(pval)], 'fontsize',8)
axis equal
ppretty()

end%function:plot_sdf_visresp_correct()
