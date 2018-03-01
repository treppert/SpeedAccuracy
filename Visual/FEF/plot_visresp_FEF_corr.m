function [  ] = plot_visresp_FEF_corr( visresp , TST , spikes , ninfo , binfo )
%[ ] = plot_sdf_visual_response( varargin )
%   Detailed explanation goes here

PLOT_INDIV = true;

%specify time limits for plotting
T_LIM = [0,500];
TIME_PLOT = (T_LIM(1):T_LIM(2));
TIME_ARRAY = 3500;

if (PLOT_INDIV)
  
  NUM_CELLS = length(ninfo);
  TYPE_PLOT = {'V','VM','M'};
  
  for kk = 1:NUM_CELLS
    if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
    
    figure(); hold on
    
    plot(TIME_PLOT, visresp.Tin(kk).fast(TIME_PLOT+TIME_ARRAY), '-', 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(TIME_PLOT, visresp.Din(kk).fast(TIME_PLOT+TIME_ARRAY), '--', 'Color',[0 .7 0], 'LineWidth',1.0)
    plot(TIME_PLOT, visresp.Tin(kk).acc(TIME_PLOT+TIME_ARRAY), 'r-', 'LineWidth',1.25)
    plot(TIME_PLOT, visresp.Din(kk).acc(TIME_PLOT+TIME_ARRAY), 'r--', 'LineWidth',1.0)
    
    xlim([T_LIM(1)-10, T_LIM(2)+10])
    print_session_unit(gca, ninfo(kk), 'type')
    
    ppretty(); pause(0.25)
    print(['~/Dropbox/tmp/VR-', ninfo(kk).sesh,'-',ninfo(kk).unit,'-',ninfo(kk).type,'.eps'], '-depsc2')
    
  end%for:cells(kk)
  
else %PLOT_AVG_ACROSS
  
  norm_factor = util_compute_normfactor_visresp(spikes, ninfo, binfo);

  TST_acc = [TST.acc];
  TST_fast = [TST.fast];

  %% Plotting - TST comparison
%   [~,pval] = ttest(TST_acc', TST_fast');
  
  figure(); hold on
  plot(TST_acc, TST_fast, 'ko')
  plot([150 240], [150 240], 'k--')
  xlim([100 360]); ylim([75 275])
  ppretty()
  return
  
  %% Plotting - Avg visual response
  
  idx_plot = ~isnan(TST_acc); %only include SDFs for cells with TST
  NUM_SEM = sum(idx_plot);

  visresp.Tin_acc = [visresp.Tin.acc] ./ norm_factor;     visresp.Tin_acc = visresp.Tin_acc(TIME_PLOT+TIME_ARRAY,idx_plot);
  sdf_Tout_acc = [visresp.Din.acc] ./ norm_factor;    sdf_Tout_acc = sdf_Tout_acc(TIME_PLOT+TIME_ARRAY,idx_plot);

  visresp.Tin_fast = [visresp.Tin.fast] ./ norm_factor;   visresp.Tin_fast = visresp.Tin_fast(TIME_PLOT+TIME_ARRAY,idx_plot);
  sdf_Tout_fast = [visresp.Din.fast] ./ norm_factor;  sdf_Tout_fast = sdf_Tout_fast(TIME_PLOT+TIME_ARRAY,idx_plot);

  figure()

  subplot(2,1,1); hold on
  shaded_error_bar(TIME_PLOT, nanmean(visresp.Tin_acc,2), nanstd(visresp.Tin_acc,0,2)/sqrt(NUM_SEM), {'r-', 'LineWidth',1.25})
  shaded_error_bar(TIME_PLOT, nanmean(sdf_Tout_acc,2), nanstd(sdf_Tout_acc,0,2)/sqrt(NUM_SEM), {'r--', 'LineWidth',1.25})
  plot(nanmean(TST_acc)*ones(1,2), [0.0 1.0], 'k--')
  xlim([T_LIM(1)-10, T_LIM(2)+10]); xticklabels(cell(1,length(get(gca,'xtick')))); pause(.1)

  subplot(2,1,2); hold on
  shaded_error_bar(TIME_PLOT, nanmean(visresp.Tin_fast,2), nanstd(visresp.Tin_fast,0,2)/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
  shaded_error_bar(TIME_PLOT, nanmean(sdf_Tout_fast,2), nanstd(sdf_Tout_fast,0,2)/sqrt(NUM_SEM), {'--', 'Color',[0 .7 0], 'LineWidth',1.25})
  plot(nanmean(TST_fast)*ones(1,2), [0.0 1.0], 'k--')
  xlim([T_LIM(1)-10, T_LIM(2)+10])

  ppretty('image_size',[3.2,5])
  % y_tick = get(gca, 'ytick')'; set(gca, 'yticklabel',num2str(y_tick,'%.1f'))
  
end

end%function:plot_sdf_visresp_correct()
