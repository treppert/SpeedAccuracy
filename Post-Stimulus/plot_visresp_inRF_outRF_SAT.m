function [ ] = plot_visresp_inRF_outRF_SAT( spikes , ninfo , binfo )
%plot_visresp_inRF_outRF_SAT Summary of this function goes here
%   Detailed explanation goes here

TIME_PLOT = (-100 : 500);
NUM_SAMP = length(TIME_PLOT);

NUM_CELLS = length(spikes);

%% Compute spike density function

VR_MG = struct('in',NaN(NUM_CELLS,NUM_SAMP), 'out',NaN(NUM_CELLS,NUM_SAMP));
VR_SAT = struct('in',NaN(NUM_CELLS,NUM_SAMP), 'out',NaN(NUM_CELLS,NUM_SAMP));
VR_SAT = struct('acc',VR_SAT, 'fast',VR_SAT);

normFactor_MG = NaN(1,NUM_CELLS);
normFactor_SAT = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  if ~ninfo(cc).visTestTS; continue; end %make sure we can task for target selection
  
  %get session number corresponding to behavioral data
  kk = ismember({binfo.SAT.session}, ninfo(cc).sess);
  
  %index by isolation quality (SAT)
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo.SAT(kk).num_trials);
  
  %index by condition (SAT)
  idxAcc = (binfo.SAT(kk).condition == 1);
  idxFast = (binfo.SAT(kk).condition == 3);
  
  %index by trial outcome
  idxCorrMG = ~(binfo.MG(kk).err_dir | binfo.MG(kk).err_hold | binfo.MG(kk).err_nosacc);
  idxCorrSAT = ~(binfo.SAT(kk).err_dir | binfo.SAT(kk).err_time | binfo.SAT(kk).err_hold);
  
  %index by response direction re. RF
  idxInMG = ismember(binfo.MG(kk).tgt_octant, ninfo(cc).RF);
  idxOutMG = ~ismember(binfo.MG(kk).tgt_octant, ninfo(cc).RF);
  idxInSAT = ismember(binfo.SAT(kk).tgt_octant, ninfo(cc).RF);
  idxOutSAT = ~ismember(binfo.SAT(kk).tgt_octant, ninfo(cc).RF);
  
  %compute and save SDF
  sdfInMG_cc = compute_spike_density_fxn(spikes(cc).MG(idxCorrMG & idxInMG));
  sdfOutMG_cc = compute_spike_density_fxn(spikes(cc).MG(idxCorrMG & idxOutMG));
  sdfInAllSAT_cc = compute_spike_density_fxn(spikes(cc).SAT(~idxIso & (idxAcc | idxFast) & idxCorrSAT & idxInSAT));
  sdfInFastSAT_cc = compute_spike_density_fxn(spikes(cc).SAT(~idxIso & idxFast & idxCorrSAT & idxInSAT));
  sdfOutFastSAT_cc = compute_spike_density_fxn(spikes(cc).SAT(~idxIso & idxFast & idxCorrSAT & idxOutSAT));
  sdfInAccSAT_cc = compute_spike_density_fxn(spikes(cc).SAT(~idxIso & idxAcc & idxCorrSAT & idxInSAT));
  sdfOutAccSAT_cc = compute_spike_density_fxn(spikes(cc).SAT(~idxIso & idxAcc & idxCorrSAT & idxOutSAT));
  
  VR_MG.in(cc,:) = nanmean(sdfInMG_cc(:,3500+TIME_PLOT));
  VR_MG.out(cc,:) = nanmean(sdfOutMG_cc(:,3500+TIME_PLOT));
  VR_SAT.fast.in(cc,:) = nanmean(sdfInFastSAT_cc(:,3500+TIME_PLOT));
  VR_SAT.fast.out(cc,:) = nanmean(sdfOutFastSAT_cc(:,3500+TIME_PLOT));
  VR_SAT.acc.in(cc,:) = nanmean(sdfInAccSAT_cc(:,3500+TIME_PLOT));
  VR_SAT.acc.out(cc,:) = nanmean(sdfOutAccSAT_cc(:,3500+TIME_PLOT));
  
  %compute normalization factors
  normFactor_MG(cc) = max(VR_MG.in(cc,:));
  normFactor_SAT(cc) = max(nanmean(sdfInAllSAT_cc(:,3500+TIME_PLOT)));
  
end%for:cells(cc)


%% Plotting -- Individual cells

if (1)
for cc = 1:NUM_CELLS
  if ~ninfo(cc).visTestTS; continue; end
  
  tmp = [VR_MG.in(cc,:), VR_MG.out(cc,:), VR_SAT.fast.in(cc,:), VR_SAT.fast.out(cc,:)];
  limLin = [min(tmp), max(tmp)];
  
  figure()
  
  subplot(1,2,1); hold on
  plot([0 0], limLin, 'k--')
  plot(TIME_PLOT, VR_MG.in(cc,:), '-', 'Color',[.5 .5 .5], 'LineWidth',1.25)
  plot(TIME_PLOT, VR_MG.out(cc,:), '-', 'Color',[.5 .5 .5], 'LineWidth',0.75)
  print_session_unit(gca , ninfo(cc))
  
  subplot(1,2,2); hold on
  plot([0 0], limLin, 'k--')
  plot(TIME_PLOT, VR_SAT.acc.in(cc,:), 'r-', 'LineWidth',1.25)
  plot(TIME_PLOT, VR_SAT.acc.out(cc,:), 'r-', 'LineWidth',0.75)
  plot(TIME_PLOT, VR_SAT.fast.in(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(TIME_PLOT, VR_SAT.fast.out(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',0.75)
  yticklabels([])
  
  ppretty('image_size',[8,4])
  
  pause()
  
end%for:cells(cc)
end%if:PLOT_INDIV_CELLS

%% Plotting -- Across cells
NUM_SEM = sum([ninfo.visTestTS]);

%normalize activity (independent for MG and SAT)
VR_MG.in = VR_MG.in ./ normFactor_MG';
VR_MG.out = VR_MG.out ./ normFactor_MG';
VR_SAT.acc.in = VR_SAT.acc.in ./ normFactor_SAT';
VR_SAT.acc.out = VR_SAT.acc.out ./ normFactor_SAT';
VR_SAT.fast.in = VR_SAT.fast.in ./ normFactor_SAT';
VR_SAT.fast.out = VR_SAT.fast.out ./ normFactor_SAT';


figure()

subplot(1,2,1); hold on
% plot(TIME_PLOT, VR_MG.in, '-', 'Color',[.5 .5 .5], 'LineWidth',1.25)
% plot(TIME_PLOT, VR_MG.out, '-', 'Color',[.5 .5 .5], 'LineWidth',0.75)
shaded_error_bar(TIME_PLOT, nanmean(VR_MG.in), nanstd(VR_MG.in)/sqrt(NUM_SEM), {'k-', 'LineWidth',1.25})
shaded_error_bar(TIME_PLOT, nanmean(VR_MG.out), nanstd(VR_MG.out)/sqrt(NUM_SEM), {'k-', 'LineWidth',0.75})
ytickformat('%2.1f')

subplot(1,2,2); hold on
% plot(TIME_PLOT, VR_SAT.acc.in, 'r-', 'LineWidth',1.25)
% plot(TIME_PLOT, VR_SAT.acc.out, 'r-', 'LineWidth',0.75)
% plot(TIME_PLOT, VR_SAT.fast.in, '-', 'Color',[0 .7 0], 'LineWidth',1.25)
% plot(TIME_PLOT, VR_SAT.fast.out, '-', 'Color',[0 .7 0], 'LineWidth',0.75)
shaded_error_bar(TIME_PLOT, nanmean(VR_SAT.acc.in), nanstd(VR_SAT.acc.in)/sqrt(NUM_SEM), {'r-', 'LineWidth',1.25})
shaded_error_bar(TIME_PLOT, nanmean(VR_SAT.acc.out), nanstd(VR_SAT.acc.out)/sqrt(NUM_SEM), {'r-', 'LineWidth',0.75})
shaded_error_bar(TIME_PLOT, nanmean(VR_SAT.fast.in), nanstd(VR_SAT.fast.in)/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
shaded_error_bar(TIME_PLOT, nanmean(VR_SAT.fast.out), nanstd(VR_SAT.fast.out)/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0], 'LineWidth',0.75})
ytickformat('%2.1f')

ppretty('image_size',[8,4])


end%function:plot_visresp_inRF_outRF_SAT()

