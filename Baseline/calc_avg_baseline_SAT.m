function [ avg_bline , varargout ] = calc_avg_baseline_SAT( spikes , ninfo , binfo )
%calc_avg_baseline_SAT Summary of this function goes here
%   Detailed explanation goes here

TIME_STIM = 3500;
TIME_BASE = ( -500 : -1 );

MIN_GRADE = 3;
NUM_CELLS = length(spikes);

avg_bline = NaN(1,NUM_CELLS);
sd_bline = NaN(1,NUM_CELLS);

bline_Acc = NaN(1,NUM_CELLS);
bline_Fast = NaN(1,NUM_CELLS);
sd_Acc = NaN(1,NUM_CELLS);
sd_Fast = NaN(1,NUM_CELLS);

for kk = 1:NUM_CELLS
%   if (ninfo(kk).vis < MIN_GRADE); continue; end
  
  sdf_kk = compute_spike_density_fxn( spikes(kk).SAT );
  tmp = mean(sdf_kk(:,TIME_STIM + TIME_BASE), 2); %average per trial
  
  avg_bline(kk) = mean(tmp);
  sd_bline(kk) = std(tmp);
  
  %% Now split on condition
  
  kk_info = ismember({binfo.session}, ninfo(kk).sesh);
  
  idx_Acc = (binfo(kk_info).condition == 1);
  idx_Fast = (binfo(kk_info).condition == 3);
  
  avg_acc = mean(sdf_kk(idx_Acc,TIME_STIM + TIME_BASE), 2);
  avg_fast = mean(sdf_kk(idx_Fast,TIME_STIM + TIME_BASE), 2);
  
  bline_Acc(kk) = mean(avg_acc);
  bline_Fast(kk) = mean(avg_fast);
  
  sd_Acc(kk) = std(avg_acc);
  sd_Fast(kk) = std(avg_fast);
  
end%for:cells(kk)

if (nargout > 1)
  varargout{1} = sd_bline;
end

%% Plotting

figure(); hold on
plot([0 70], [0 70], 'k--')
errorbarxy(bline_Acc, bline_Fast, sd_Acc, sd_Fast, {'k.','k','k'})
ppretty('image_size',[3,3])

%bar plot
err = [nanstd(bline_Acc) nanstd(bline_Fast)] / sqrt(sum([ninfo.vis] >= MIN_GRADE));
figure(); hold on
bar([1 2], [nanmean(bline_Acc) nanmean(bline_Fast)], 'BarWidth',0.4)
errorbar_no_caps([1 2], [nanmean(bline_Acc) nanmean(bline_Fast)], 'err',err)
xlim([0 3]); ppretty('image_size',[2,3])

end%util:calc_avg_baseline_SAT()

