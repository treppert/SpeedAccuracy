function [ ] = plot_sdf_reward_SEF( spikes , ninfo , binfo )
%plot_sdf_reward_SEF Summary of this function goes here
%   Detailed explanation goes here

T_PLOT = (-400 : 800);
OFFSET_TEST = 200;
NUM_CELLS = length(spikes);

Acorr = NaN(NUM_CELLS, length(T_PLOT));
Aerr = NaN(NUM_CELLS, length(T_PLOT));

normFactor = NaN(1,NUM_CELLS); %normalization

tStartRPE = NaN(1,NUM_CELLS); %stats
tVecRPE = cell(1,NUM_CELLS);

%compute expected/actual time of reward for each session
binfo = determine_time_reward_SAT(binfo);

for cc = 1:NUM_CELLS
  if (ninfo(cc).RPE ~= 1); continue; end
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  idxIso = false(1,binfo(kk).num_trials);
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idxErr = (~binfo(kk).err_dir & binfo(kk).err_time);
  
  %compute SDF
  sdf_cc = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_cc = align_signal_on_response(sdf_cc, binfo(kk).resptime + binfo(kk).rewtime);
  
  sdfAccCorr = sdf_cc(idxAcc & idxCorr, T_PLOT+3500);
  sdfAccErr = sdf_cc(idxAcc & idxErr, T_PLOT+3500);
  
  %compute timing stats for RPE
  sdfAC_test = sdfAccCorr(:,OFFSET_TEST:end); %offset in time
  sdfAE_test = sdfAccErr(:,OFFSET_TEST:end);
  [tStartRPE(cc),tVecRPE{cc}] = compute_time_RPE(sdfAC_test, sdfAE_test, 0.05, 100);
  tVecRPE{cc} = tVecRPE{cc} - OFFSET_TEST; %correct for offset
  
  Acorr(cc,:) = nanmean(sdfAccCorr);
  Aerr(cc,:) = nanmean(sdfAccErr);
  
  %compute normalization factor
  normFactor(cc) = max(nanmean(sdf_cc(idxAcc, T_PLOT+3500)));
  
end%for:cells(kk)

tStartRPE = tStartRPE - OFFSET_TEST; %correct for offset


%% Plotting - individual cells

if (0)
for cc = 1:NUM_CELLS
  if (ninfo(cc).RPE ~= 1); continue; end
  
  linMin = min([Acorr(cc,:),Aerr(cc,:)]);
  linMax = max([Acorr(cc,:),Aerr(cc,:)]);
  
  figure(); hold on
  
  plot([0 0], [linMin linMax], 'k--')
  plot([tStartRPE(cc) tStartRPE(cc)], [linMin linMax], 'k:')
  plot(tVecRPE{cc}, linMin, 'k.', 'MarkerSize',8)
  
  plot(T_PLOT, Acorr(cc,:), 'r-', 'LineWidth',1.75)
  plot(T_PLOT, Aerr(cc,:), 'r-', 'LineWidth',0.75)
  
  print_session_unit(gca, ninfo(cc), binfo(kk), 'horizontal')
  ppretty('image_size',[7,3])
  
  pause()
  
end%for:cells(cc)
end

%% Plotting - across cells
NUM_SEM = sum([ninfo.RPE] == 1);

%normalization
Acorr = Acorr ./ normFactor';
Aerr = Aerr ./ normFactor';

figure(); hold on
shaded_error_bar(T_PLOT, nanmean(Acorr), nanstd(Acorr)/sqrt(NUM_SEM), {'r-', 'LineWidth',1.5})
shaded_error_bar(T_PLOT, nanmean(Aerr), nanstd(Aerr)/sqrt(NUM_SEM), {'r-', 'LineWidth',0.5})
ytickformat('%3.2f')
ppretty('image_size',[6,4])

figure(); hold on
shaded_error_bar(T_PLOT, nanmean(Aerr-Acorr), nanstd(Aerr-Acorr)/sqrt(NUM_SEM), {'k-', 'LineWidth',1.5})
ytickformat('%3.2f')
ppretty('image_size',[6,4])

end%function:plot_sdf_reward_SEF()


function [tStart, tVec] = compute_time_RPE( A_corr , A_err , alpha , minLength)

NUM_MISSES_ALLOWED = 5; %can skip up to this number of timepoints

tStart = NaN; %initialization
tVec = NaN;

[~,NUM_SAMP] = size(A_corr);

H_MW = false(1,NUM_SAMP); %Mann-Whitney U-test
P_MW = NaN(1,NUM_SAMP);
for ii = 1:NUM_SAMP
  [P_MW(ii),H_MW(ii)] = ranksum(A_corr(:,ii), A_err(:,ii), 'alpha',alpha, 'tail','both');
end%for:samples(ii)

samp_H_1 = find(H_MW);
dsamp_H_1 = diff(samp_H_1);
NUM_DSAMP = length(dsamp_H_1);

for ii = 1:(NUM_DSAMP-minLength+1)
  if (sum(dsamp_H_1(ii : ii+minLength-1)) <= (minLength+NUM_MISSES_ALLOWED))
    tStart = samp_H_1(ii);
    tVec = samp_H_1;
    break
  end
end%for:num-dsamp-estimates(ii)

end%util:compute_time_RPE()