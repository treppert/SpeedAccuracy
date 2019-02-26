function [ ] = plotBlineXcondSAT( binfo , ninfo , spikes , varargin )
%plotBlineXcondSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

NUM_CELLS = length(spikes);
T_BASE  = 3500 + (-700 : -1);

blineAcc = NaN(1,NUM_CELLS);
blineFast = NaN(1,NUM_CELLS);
sdfAcc = NaN(NUM_CELLS,length(T_BASE));
sdfFast = NaN(NUM_CELLS,length(T_BASE));

for cc = 1:NUM_CELLS
%   if (ninfo(cc).errGrade ~= 1); continue; end
  kk = ismember({binfo.session}, ninfo(cc).sess);

  %compute spike density function and align on primary response
  sdfSess = compute_spike_density_fxn(spikes(cc).SAT);

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idx_A = ((binfo(kk).condition == 1) & ~idxIso);
  idx_F = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
  idxErr = (binfo(kk).err_time & ~binfo(kk).err_dir);
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  
  sdfAcc(cc,:) = nanmean(sdfSess(idx_A & idxCorr, T_BASE));
  sdfFast(cc,:) = nanmean(sdfSess(idx_F & idxCorr, T_BASE));
  
  blineAcc(cc) = mean(sdfAcc(cc,:));
  blineFast(cc) = mean(sdfFast(cc,:));
  
end%for:cells(kk)


%% Plotting - Scatter X condition

figure(); hold on
plot(blineAcc, blineFast, 'ko', 'MarkerSize',5)
plot([5 100], [5 100], ':', 'Color',[.5 .5 .5])
xlim([0 80]); ylim([0 80]); ppretty('image_size',[5,4])

pause(0.25)

figure(); hold on
histogram(blineFast-blineAcc, 'BinWidth',2, 'FaceColor',[.4 .4 .4])
ppretty('image_size',[4,4])


end%fxn:plotBlineXcondSAT()

