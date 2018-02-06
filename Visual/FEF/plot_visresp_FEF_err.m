function [  ] = plot_visresp_FEF_err( visresp , TST , spikes , ninfo , binfo )
%[ ] = plot_sdf_visual_response( varargin )
%   Detailed explanation goes here

PLOT_INDIV = false;
TYPE_PLOT = {'V','VM'};

%specify time limits for plotting
T_LIM = [0,600];
TIME_PLOT = (T_LIM(1):T_LIM(2));
TIME_ARRAY = 3500;


if (PLOT_INDIV)
  
  NUM_CELLS = length(ninfo);
  
  for kk = 1:NUM_CELLS
    if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
    
    figure()
    
    subplot(2,1,1); hold on
    plot(TIME_PLOT, visresp.Tout_Sin(kk).acc(TIME_PLOT+TIME_ARRAY), 'r:', 'LineWidth',1.25)
    plot(TIME_PLOT, visresp.Tin_Sout(kk).acc(TIME_PLOT+TIME_ARRAY), 'r--', 'LineWidth',1.0)
    xlim([T_LIM(1)-10, T_LIM(2)+10]); xticklabels(cell(1,length(get(gca,'xtick'))))
    print_session_unit(gca, ninfo(kk), 'type')
    
    subplot(2,1,2); hold on
    plot(TIME_PLOT, visresp.Tout_Sin(kk).fast(TIME_PLOT+TIME_ARRAY), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(TIME_PLOT, visresp.Tin_Sout(kk).fast(TIME_PLOT+TIME_ARRAY), '--', 'Color',[0 .7 0], 'LineWidth',1.0)
    xlim([T_LIM(1)-10, T_LIM(2)+10])
    print_session_unit(gca, ninfo(kk), 'type')
    
    ppretty('image_size',[3.2,5])
    
  end%for:cells(kk)
  
else %PLOT_AVG_ACROSS
  
  norm_factor = util_compute_normfactor_visresp(spikes, ninfo, binfo);

  %% Compute TST based on the across-cell average data
  VR_Din_acc = [visresp.Tout_Sin.acc] ./ norm_factor;
  VR_Tin_acc = [visresp.Tin_Sout.acc] ./ norm_factor;

  VR_Din_fast = [visresp.Tout_Sin.fast] ./ norm_factor;
  VR_Tin_fast = [visresp.Tin_Sout.fast] ./ norm_factor;

  TST_acc = compute_TST_MannWhitney(VR_Din_acc', VR_Tin_acc');
  TST_fast = compute_TST_MannWhitney(VR_Din_fast', VR_Tin_fast');

  fprintf('TST Acc = %g\n', TST_acc)
  fprintf('TST Fast = %g\n', TST_fast)

  %% Plotting - across-cell average
  idx_plot = ismember({ninfo.type}, TYPE_PLOT);
  NUM_SEM = sum(idx_plot);

  VR_Din_acc = VR_Din_acc(TIME_PLOT+TIME_ARRAY,idx_plot);
  VR_Tin_acc = VR_Tin_acc(TIME_PLOT+TIME_ARRAY,idx_plot);

  VR_Din_fast = VR_Din_fast(TIME_PLOT+TIME_ARRAY,idx_plot);
  VR_Tin_fast = VR_Tin_fast(TIME_PLOT+TIME_ARRAY,idx_plot);

  figure()

  subplot(2,1,1); hold on
  shaded_error_bar(TIME_PLOT, nanmean(VR_Din_acc,2), nanstd(VR_Din_acc,0,2)/sqrt(NUM_SEM), {'r:', 'LineWidth',1.5})
  shaded_error_bar(TIME_PLOT, nanmean(VR_Tin_acc,2), nanstd(VR_Tin_acc,0,2)/sqrt(NUM_SEM), {'r--', 'LineWidth',1.5})
  plot(TST_acc*ones(1,2), [0 1], 'k--')
  xlim([T_LIM(1)-10, T_LIM(2)+10]); xticklabels(cell(1,length(get(gca,'xtick')))); pause(.1)

  subplot(2,1,2); hold on
  shaded_error_bar(TIME_PLOT, nanmean(VR_Din_fast,2), nanstd(VR_Din_fast,0,2)/sqrt(NUM_SEM), {':', 'Color',[0 .7 0], 'LineWidth',1.5})
  shaded_error_bar(TIME_PLOT, nanmean(VR_Tin_fast,2), nanstd(VR_Tin_fast,0,2)/sqrt(NUM_SEM), {'--', 'Color',[0 .7 0], 'LineWidth',1.5})
  plot(TST_fast*ones(1,2), [0 1], 'k--')
  xlim([T_LIM(1)-10, T_LIM(2)+10])

  ppretty('image_size',[3.2,5])
  % y_tick = get(gca, 'ytick')'; set(gca, 'yticklabel',num2str(y_tick,'%.1f'))
  
end

end%function:plot_sdf_visresp_error()

