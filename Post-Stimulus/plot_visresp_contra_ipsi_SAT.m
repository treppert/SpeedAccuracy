function [ ] = plot_visresp_contra_ipsi_SAT( spikes , ninfo , binfo , moves )
%plot_visresp_contra_ipsi_SAT Summary of this function goes here
%   Detailed explanation goes here

PLOT_INDIV_CELLS = false;
MIN_GRADE = 3;

TIME_PLOT = (-100 : 400);
NUM_SAMP = length(TIME_PLOT);

NUM_CELLS = length(spikes);

%% Compute spike density function

VR_MG = struct('in',NaN(NUM_CELLS,NUM_SAMP), 'out',NaN(NUM_CELLS,NUM_SAMP));
VR_SAT = struct('in',NaN(NUM_CELLS,NUM_SAMP), 'out',NaN(NUM_CELLS,NUM_SAMP));

for cc = 1:NUM_CELLS
  if (ninfo(cc).vis < MIN_GRADE); continue; end
  
  %get session number corresponding to behavioral data
  kk = ismember({binfo.SAT.session}, ninfo(cc).sess);
  
  %index by isolation quality (SAT)
  idxIsoSAT = identify_trials_poor_isolation_SAT(ninfo(cc), binfo.SAT(kk).num_trials);
  %index by condition (SAT)
%   idxCondSAT = ((binfo.SAT(kk).condition == 1) | (binfo.SAT(kk).condition == 3));
  idxCondSAT = (binfo.SAT(kk).condition == 3);
  
  %index by trial outcome
  idxCorrMG = ~(binfo.MG(kk).err_dir | binfo.MG(kk).err_hold | binfo.MG(kk).err_nosacc);
  idxCorrSAT = ~(binfo.SAT(kk).err_dir | binfo.SAT(kk).err_time | binfo.SAT(kk).err_hold);
  
  %get location of RF by hemifield
  if strcmp(binfo.SAT(kk).session(1), 'D')
    LOC_RF_IN = [4 5 6];
    LOC_RF_OUT = [1 2 8];
  elseif strcmp(binfo.SAT(kk).session(1), 'E')
    LOC_RF_OUT = [4 5 6];
    LOC_RF_IN = [1 2 8];
  end
  
  %index by response direction
  idxInMG = ismember(moves.MG(kk).octant, LOC_RF_IN);
  idxOutMG = ismember(moves.MG(kk).octant, LOC_RF_OUT);
  idxInSAT = ismember(moves.SAT(kk).octant, LOC_RF_IN);
  idxOutSAT = ismember(moves.SAT(kk).octant, LOC_RF_OUT);
  
  %compute SDF
  sdfInMGcc = compute_spike_density_fxn(spikes(cc).MG(idxCorrMG & idxInMG));
  sdfOutMGcc = compute_spike_density_fxn(spikes(cc).MG(idxCorrMG & idxOutMG));
  sdfInSATcc = compute_spike_density_fxn(spikes(cc).SAT(~idxIsoSAT & idxCondSAT & idxCorrSAT & idxInSAT));
  sdfOutSATcc = compute_spike_density_fxn(spikes(cc).SAT(~idxIsoSAT & idxCondSAT & idxCorrSAT & idxOutSAT));
  
  %save SDF
  VR_MG.in(cc,:) = nanmean(sdfInMGcc(:,3500+TIME_PLOT));
  VR_MG.out(cc,:) = nanmean(sdfOutMGcc(:,3500+TIME_PLOT));
  VR_SAT.in(cc,:) = nanmean(sdfInSATcc(:,3500+TIME_PLOT));
  VR_SAT.out(cc,:) = nanmean(sdfOutSATcc(:,3500+TIME_PLOT));
  
end%for:cells(cc)


%% Plotting -- Individual neurons
if (PLOT_INDIV_CELLS)
for cc = 1:NUM_CELLS
  if (ninfo(cc).vis < MIN_GRADE); continue; end
  
  tmp = [VR_MG.in(cc,:), VR_MG.out(cc,:), VR_SAT.in(cc,:), VR_SAT.out(cc,:)];
  limLin = [min(tmp), max(tmp)];
  
  figure()
  
  subplot(1,2,1); hold on
  
  plot([0 0], limLin, 'k--')
  plot(TIME_PLOT, VR_MG.in(cc,:), '-', 'Color',[.5 .5 .5], 'LineWidth',1.25)
  plot(TIME_PLOT, VR_MG.out(cc,:), '-', 'Color',[.5 .5 .5], 'LineWidth',0.75)
  
  print_session_unit(gca , ninfo(cc))
  
  subplot(1,2,2); hold on
  
  plot([0 0], limLin, 'k--')
  plot(TIME_PLOT, VR_SAT.in(cc,:), 'r-', 'LineWidth',1.25)
  plot(TIME_PLOT, VR_SAT.out(cc,:), 'r-', 'LineWidth',0.75)
  
  ppretty('image_size',[7,3])
  
  pause(0.5)
  
end%for:cells(cc)
end%if:PLOT-INDIV-CELLS

%% Plotting -- All neurons
NUM_SEM = sum([ninfo.vis] >= MIN_GRADE);

%compute the normalization factor for each cell
aNormMG = NaN(1,NUM_CELLS);
aNormSAT = NaN(1,NUM_CELLS);
for cc = 1:NUM_CELLS
  if (ninfo(cc).vis < MIN_GRADE); continue; end
  aNormMG(cc) = max(VR_MG.in(cc,:));
  aNormSAT(cc) = max(VR_SAT.in(cc,:));
end%for:cells(cc)

%normalize all SDFs
VR_MG.in = VR_MG.in ./ aNormMG';
VR_MG.out = VR_MG.out ./ aNormMG';
VR_SAT.in = VR_SAT.in ./ aNormSAT';
VR_SAT.out = VR_SAT.out ./ aNormSAT';

%compute the difference in SDFs
dVR_MG = VR_MG.in - VR_MG.out;
dVR_SAT = VR_SAT.in -VR_SAT.out;

figure()

subplot(2,2,1); hold on

plot([0 0], [0.2 0.9], 'k--')
shaded_error_bar(TIME_PLOT, nanmean(VR_MG.in), nanstd(VR_MG.in)/sqrt(NUM_SEM), {'Color',[.5 .5 .5], 'LineWidth',1.25})
shaded_error_bar(TIME_PLOT, nanmean(VR_MG.out), nanstd(VR_MG.out)/sqrt(NUM_SEM), {'Color',[.5 .5 .5], 'LineWidth',0.75})
% plot(TIME_PLOT, VR_MG.in, '-', 'Color',[.5 .5 .5], 'LineWidth',1.25)
% plot(TIME_PLOT, VR_MG.out, '-', 'Color',[.5 .5 .5], 'LineWidth',0.75)

subplot(2,2,2); hold on

plot([0 0], [0.2 0.9], 'k--')
shaded_error_bar(TIME_PLOT, nanmean(VR_SAT.in), nanstd(VR_SAT.in)/sqrt(NUM_SEM), {'Color','r', 'LineWidth',1.25})
shaded_error_bar(TIME_PLOT, nanmean(VR_SAT.out), nanstd(VR_SAT.out)/sqrt(NUM_SEM), {'Color','r', 'LineWidth',0.75})
% plot(TIME_PLOT, VR_SAT.in, 'r-', 'LineWidth',1.25)
% plot(TIME_PLOT, VR_SAT.out, 'r-', 'LineWidth',0.75)

subplot(2,2,3); hold on

plot([-100 400], [0 0], 'k--')
shaded_error_bar(TIME_PLOT, nanmean(dVR_MG), nanstd(dVR_MG)/sqrt(NUM_SEM), {'Color',[.3 .3 .3], 'LineWidth',1.25})

subplot(2,2,4); hold on

plot([-100 400], [0 0], 'k--')
shaded_error_bar(TIME_PLOT, nanmean(dVR_SAT), nanstd(dVR_SAT)/sqrt(NUM_SEM), {'Color',[.5 0 0], 'LineWidth',0.75})

ppretty('image_size',[9,7])

end%function:plot_visresp_contra_ipsi_SAT()

