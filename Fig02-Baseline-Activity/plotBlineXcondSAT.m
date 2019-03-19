function [ varargout ] = plotBlineXcondSAT( binfo , ninfo , spikes , varargin )
%plotBlineXcondSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

NUM_CELLS = length(spikes);
T_BASE  = 3500 + (-100 : 20);

sdfAcc = NaN(NUM_CELLS,length(T_BASE));
sdfFast = NaN(NUM_CELLS,length(T_BASE));

for cc = 1:NUM_CELLS
%   if ~(ninfo(cc).baseLine); continue; end %make sure we have modulation Fast > Acc
  kk = ismember({binfo.session}, ninfo(cc).sess);
  sdfKK = compute_spike_density_fxn(spikes(cc).SAT);

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  
  %compute SDFs
  sdfAcc(cc,:) = nanmean(sdfKK(idxAcc & idxCorr, T_BASE));
  sdfFast(cc,:) = nanmean(sdfKK(idxFast & idxCorr, T_BASE));
  
  %parameterize baseline activity
  ninfo(cc).muBlineAcc = mean(sdfAcc(cc,:));
  ninfo(cc).muBlineFast = mean(sdfFast(cc,:));
  ninfo(cc).sdBlineAcc = std(sdfAcc(cc,:));
  ninfo(cc).sdBlineFast = std(sdfFast(cc,:));
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = ninfo;
  if (nargout > 1)
    varargout{2} = spikes;
  end
end


%% Plotting
blineDiff = [ninfo.muBlineFast] - [ninfo.muBlineAcc];

figure(); hold on
histogram(blineDiff, 'BinWidth',2, 'FaceColor',[.5 .5 .5])
histogram(blineDiff([ninfo.baseLine]~=0), 'BinWidth',2, 'FaceColor','b')
ppretty([5,4])

end%fxn:plotBlineXcondSAT()

