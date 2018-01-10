function [ varargout ] = plot_sdf_visresp_error( spikes , ninfo , moves , binfo )
%[ ] = plot_sdf_visual_response( varargin )
%   Detailed explanation goes here

% REMOVE_SPIKES_POST_RESP = false;
PLOT_INDIV = false;
MIN_NUM_TRIALS = 2;

%average across visual and visuo-movement cells
TYPE_PLOT = {'V','VM'};

%specify time limits for plotting
T_LIM = [0,600];
TIME_PLOT = (T_LIM(1):T_LIM(2));

NUM_CELLS = length(spikes);
TIME_ARRAY = 3500;

%get saccade error information
moves = determine_errors_SAT(moves, binfo);

sdf_Din_Sin = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]); %saccade inside RF
sdf_Din_Sin = populate_struct(sdf_Din_Sin, {'acc','fast'}, NaN(6001,1));
sdf_Din_Sout = sdf_Din_Sin; %saccade outside RF

tst = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
tst = populate_struct(tst, {'acc','fast'}, NaN);

%% Compute the SDF Saccade into RF vs. Saccade outside RF

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).session);
  
  %index by response accuracy
  idx_err = moves(kk_moves).err_direction;
  
  %index by response timing
  idx_time = moves(kk_moves).err_timing;
  
  %index by condition
  idx_fast = (binfo(kk_moves).condition == 3);
  idx_acc = (binfo(kk_moves).condition == 1);
  
  %index by singleton location and saccade direction re. response field
  idx_Tin = ismember(binfo(kk_moves).tgt_octant, ninfo(kk).resp_field);
  idx_Sin = ismember(moves(kk_moves).octant, ninfo(kk).resp_field);
  
  %combine and create composite indexes
  idx_Din_Sin = (~idx_Tin & idx_Sin & idx_err & ~idx_time);
  idx_Din_Sout = (idx_Tin & ~idx_Sin & idx_err & ~idx_time);
  
  %% Compute spike density function
  
  sdf_kk = compute_spike_density_fxn(spikes(kk).SAT);
  
%   if (REMOVE_SPIKES_POST_RESP)
%     sdf_kk = remove_spikes_post_response(sdf_kk, moves(kk_moves).resptime);
%   end
  
  %SDFs and TST for Accurate condition
  if (sum(idx_Din_Sin & idx_acc) >= MIN_NUM_TRIALS)
    sdf_Din_Sin(kk).acc(:) = transpose(nanmean(sdf_kk(idx_Din_Sin & idx_acc,:)));
    tst(kk).acc  = compute_TST_MannWhitney(sdf_kk(idx_Din_Sin & idx_acc,:), sdf_kk(idx_Din_Sout & idx_acc,:));
  end
  sdf_Din_Sout(kk).acc(:) = transpose(nanmean(sdf_kk(idx_Din_Sout & idx_acc,:)));
  
  %SDFs and TST for Fast condition
  if (sum(idx_Din_Sin & idx_fast) >= MIN_NUM_TRIALS)
    sdf_Din_Sin(kk).fast(:) = transpose(nanmean(sdf_kk(idx_Din_Sin & idx_fast,:)));
    tst(kk).fast = compute_TST_MannWhitney(sdf_kk(idx_Din_Sin & idx_fast,:), sdf_kk(idx_Din_Sout & idx_fast,:));
  end
  sdf_Din_Sout(kk).fast(:) = transpose(nanmean(sdf_kk(idx_Din_Sout & idx_fast,:)));
  
end%for:cells(kk)

if (nargout > 0)
  varargout{1} = tst;
end

%% Plotting - individual cells
if (PLOT_INDIV)
  IDX_PLOT = TIME_PLOT + TIME_ARRAY;
  
  for kk = 1:NUM_CELLS
    if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
    
    figure()
    
    subplot(2,1,1); hold on
    plot(TIME_PLOT, sdf_Din_Sin(kk).acc(IDX_PLOT), 'r:', 'LineWidth',1.5)
    plot(TIME_PLOT, sdf_Din_Sout(kk).acc(IDX_PLOT), 'r--', 'LineWidth',1.5)
    xlim([T_LIM(1)-10, T_LIM(2)+10]); xticklabels(cell(1,length(get(gca,'xtick'))))
    print_session_unit(gca, ninfo(kk), 'type'); pause(.1)
    
    subplot(2,1,2); hold on
    plot(TIME_PLOT, sdf_Din_Sin(kk).fast(IDX_PLOT), ':', 'Color',[0 .7 0], 'LineWidth',1.5)
    plot(TIME_PLOT, sdf_Din_Sout(kk).fast(IDX_PLOT), '--', 'Color',[0 .7 0], 'LineWidth',1.5)
    xlim([T_LIM(1)-10, T_LIM(2)+10])
    print_session_unit(gca, ninfo(kk), 'type')
    
    ppretty('image_size',[3.2,5]); pause(2.0)
  end%for:cells(kk)
  
  return
end%plot individual cells?

%% Compute normalization factor for each neuron
norm_factor = util_compute_normfactor_visresp(spikes, ninfo, binfo);

%% Compute TST based on the across-cell average data
sdf_Sin_acc = [sdf_Din_Sin.acc] ./ norm_factor;
sdf_Sout_acc = [sdf_Din_Sout.acc] ./ norm_factor;

sdf_Sin_fast = [sdf_Din_Sin.fast] ./ norm_factor;
sdf_Sout_fast = [sdf_Din_Sout.fast] ./ norm_factor;

tst_acc = compute_TST_MannWhitney(sdf_Sin_acc', sdf_Sout_acc');
tst_fast = compute_TST_MannWhitney(sdf_Sin_fast', sdf_Sout_fast');

fprintf('TST Acc = %g\n', tst_acc)
fprintf('TST Fast = %g\n', tst_fast)

%% Plotting - across-cell average
idx_plot = ismember({ninfo.type}, TYPE_PLOT);
NUM_SEM = sum(idx_plot);

sdf_Sin_acc = sdf_Sin_acc(TIME_PLOT+TIME_ARRAY,idx_plot);
sdf_Sout_acc = sdf_Sout_acc(TIME_PLOT+TIME_ARRAY,idx_plot);

sdf_Sin_fast = sdf_Sin_fast(TIME_PLOT+TIME_ARRAY,idx_plot);
sdf_Sout_fast = sdf_Sout_fast(TIME_PLOT+TIME_ARRAY,idx_plot);

figure()

subplot(2,1,1); hold on
shaded_error_bar(TIME_PLOT, nanmean(sdf_Sin_acc,2), nanstd(sdf_Sin_acc,0,2)/sqrt(NUM_SEM), {'r:', 'LineWidth',1.5})
shaded_error_bar(TIME_PLOT, nanmean(sdf_Sout_acc,2), nanstd(sdf_Sout_acc,0,2)/sqrt(NUM_SEM), {'r--', 'LineWidth',1.5})
plot(tst_acc*ones(1,2), [0 1], 'k--')
xlim([T_LIM(1)-10, T_LIM(2)+10]); xticklabels(cell(1,length(get(gca,'xtick')))); pause(.1)

subplot(2,1,2); hold on
shaded_error_bar(TIME_PLOT, nanmean(sdf_Sin_fast,2), nanstd(sdf_Sin_fast,0,2)/sqrt(NUM_SEM), {':', 'Color',[0 .7 0], 'LineWidth',1.5})
shaded_error_bar(TIME_PLOT, nanmean(sdf_Sout_fast,2), nanstd(sdf_Sout_fast,0,2)/sqrt(NUM_SEM), {'--', 'Color',[0 .7 0], 'LineWidth',1.5})
plot(tst_fast*ones(1,2), [0 1], 'k--')
xlim([T_LIM(1)-10, T_LIM(2)+10])

ppretty('image_size',[3.2,5])
% y_tick = get(gca, 'ytick')'; set(gca, 'yticklabel',num2str(y_tick,'%.1f'))

end%function:plot_sdf_visresp_error()

