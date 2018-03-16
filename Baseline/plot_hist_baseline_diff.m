function [ avg_base ] = plot_hist_baseline_diff( spikes , ninfo , binfo , varargin )
%plot_hist_diff_baseline Summary of this function goes here
%   Detailed explanation goes here

%option to color-code cells with significant baseline diff -- this input
%comes from fxn compute_baseline_diff_within()
if (nargin > 3)
  hval = varargin{1};
else
  hval = [];
end

NUM_CELLS = length(spikes);

IDX_ARRAY = 3500;
TIME_BASE = (-500:-100);

avg_base = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);

norm_factor = NaN(1,NUM_CELLS); %avg baseline activity across all trials

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, {'V','VM'}); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).sesh);
  
  %index by condition
  idx_acc = (binfo(kk_moves).condition == 1);
  idx_fast = (binfo(kk_moves).condition == 3);
  
  %get normalization factor
  sdf_all = compute_spike_density_fxn(spikes(kk).SAT(idx_acc | idx_fast));
  norm_factor(kk) = mean(mean(sdf_all(:,TIME_BASE+IDX_ARRAY)));
  
  sdf_fast = compute_spike_density_fxn(spikes(kk).SAT(idx_fast));
  sdf_acc = compute_spike_density_fxn(spikes(kk).SAT(idx_acc));
  
  avg_base(kk).acc = mean(mean(sdf_acc(:,TIME_BASE+IDX_ARRAY))) / norm_factor(kk);
  avg_base(kk).fast = mean(mean(sdf_fast(:,TIME_BASE+IDX_ARRAY))) / norm_factor(kk);
  
end%for:neurons(kk)


%% Plotting
figure(); hold on

avg_diff = [avg_base.fast] - [avg_base.acc];

if ~isempty(hval)
  histogram(avg_diff(abs(hval)==1), 'BinWidth',2, 'FaceColor',.3*ones(1,3), 'LineStyle','none') %significant
  histogram(avg_diff(hval==0), 'BinWidth',2, 'FaceColor',.7*ones(1,3), 'LineStyle','none')
  ylim([0 5])
else
  histogram(avg_diff, 'BinWidth',1, 'FaceColor',.4*ones(1,3))%, 'LineStyle','none')
end

% plot(nanmean(avg_diff)*ones(1,2), [0 5], 'k--', 'LineWidth',1.25)

ppretty()

end%function:plot_baseline_diff_vs_trial()

