function [ ] = plot_SDF_from_primary_sacc_SAT( A_PostSacc , ninfo , varargin )
%plot_SDF_from_primary_sacc_SAT Summary of this function goes here
%   Detailed explanation goes here

if (nargin > 2)
  statsCE = varargin{1};
end

NUM_CELLS = length(A_PostSacc);

for cc = 1:NUM_CELLS
  
  A_Corr = nanmean(A_PostSacc(cc).FastCorr);
  A_ErrDir = nanmean(A_PostSacc(cc).FastErrDir);
  
  lim_lin = [min(A_ErrDir), max(A_ErrDir)];
  
  figure(); hold on
  plot([0 0], lim_lin, 'k--', 'LineWidth',1.0)
  
  if (nargin > 2)
    plot(statsCE.fast.tStart(cc)*ones(1,2), lim_lin, '--', 'Color',[0 .4 0], 'LineWidth',1.0)
  end
  
  plot(A_PostSacc(cc).t, A_Corr, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
  plot(A_PostSacc(cc).t, A_ErrDir, '--', 'Color',[0 .7 0], 'LineWidth',1.0)
  
  xlabel('Time from primary saccade (ms)')
  ylabel('Activity (sp/sec)')
  print_session_unit(gca, ninfo(cc), 'horizontal')
  ppretty()
  
  pause(0.5)
%   print_fig_SAT(ninfo(cc), gcf, '-dtiff')
  pause(0.5)
  
end%for:cells(cc)

end%fxn:plot_SDF_from_primary_sacc_SAT()


