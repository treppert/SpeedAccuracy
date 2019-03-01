function [ varargout ] = plotBlineXcondSAT( binfo , ninfo , spikes , varargin )
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
%   if ~(ninfo(cc).baseLine); continue; end %make sure we have modulation Fast > Acc
  kk = ismember({binfo.session}, ninfo(cc).sess);

  %compute spike density function
  sdfSess = compute_spike_density_fxn(spikes(cc).SAT);

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
%   idxErr = (~binfo(kk).err_time & binfo(kk).err_dir);
%   idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  
  sdfAcc(cc,:) = nanmean(sdfSess(idxAcc, T_BASE));
  sdfFast(cc,:) = nanmean(sdfSess(idxFast, T_BASE));
  blineAcc(cc) = mean(sdfAcc(cc,:));
  blineFast(cc) = mean(sdfFast(cc,:));
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = struct('Acc',blineAcc, 'Fast',blineFast);
  if (nargout > 1)
    varargout{2} = struct('Acc',sdfAcc, 'Fast',sdfFast);
  end
end


%% Plotting
blineDiff = blineFast - blineAcc;

% figure(); hold on
% plot(blineAcc, blineFast, 'ko', 'MarkerSize',5)
% plot([5 100], [5 100], ':', 'Color',[.5 .5 .5])
% xlim([0 80]); ylim([0 80]); ppretty('image_size',[5,4])

figure(); hold on
histogram(blineDiff, 'BinWidth',2, 'FaceColor',[.5 .5 .5])
histogram(blineDiff([ninfo.baseLine]~=0), 'BinWidth',2, 'FaceColor','b')
ppretty([5,4])

end%fxn:plotBlineXcondSAT()

