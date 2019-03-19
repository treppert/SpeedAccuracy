function [ varargout ] = plotBlineXcondSAT( binfo , ninfo , nstats , spikes , varargin )
%plotBlineXcondSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idxArea & idxMonkey);
spikes = spikes(idxArea & idxMonkey);

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
%   idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  
  %compute SDFs
  sdfAcc(cc,:) = nanmean(sdfKK(idxAcc, T_BASE));
  sdfFast(cc,:) = nanmean(sdfKK(idxFast, T_BASE));
  
  %parameterize baseline activity
  idxStats = ninfo(cc).unitNum; %index nstats correctly
  nstats(idxStats).blineAccMEAN = mean(sdfAcc(cc,:));
  nstats(idxStats).blineFastMEAN = mean(sdfFast(cc,:));
  nstats(idxStats).blineAccSD = std(sdfAcc(cc,:));
  nstats(idxStats).blineFastSD = std(sdfFast(cc,:));
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

%% Plotting

blineDiff = [nstats.blineFastMEAN] - [nstats.blineAccMEAN];

figure(); hold on
histogram(blineDiff, 'BinWidth',2, 'FaceColor',[.5 .5 .5])
histogram(blineDiff([nstats(idxArea & idxMonkey).blineEffect]==1), 'BinWidth',2, 'FaceColor',[0 .7 0])
histogram(blineDiff([nstats(idxArea & idxMonkey).blineEffect]==-1), 'BinWidth',2, 'FaceColor','r')
ppretty([5,4])

end%fxn:plotBlineXcondSAT()

