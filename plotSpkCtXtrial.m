function [ ] = plotSpkCtXtrial( ninfo , spikes , varargin )
%plotSpkCtXtrial Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Figs\2-Baseline\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);

idxKeep = (idxArea & idxMonkey);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

T_BLINE = 3500 + [-600 20];
% T_STIM = 3500 + (-50 : 350);

%if desired, isolate one neuron of interest
sessionPlot = [];   unitPlot = [];

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  spikesCC = spikes(cc).SAT;  numTrial = length(spikesCC);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), numTrial);
  trialIso = find(idxIso);
  
  if any(idxIso)
    for jj = 1:numTrial
      if ismember(jj, trialIso)
        spikesCC{jj} = [];
      end
    end%for:trial(jj)
  end
  
  spkCtCC = cellfun(@(x) sum((x > T_BLINE(1)) & (x < T_BLINE(2))), spikesCC);
  
  %% Plotting
  figure(); hold on
  plot(spkCtCC, 'k-', 'LineWidth',1.25)
  xlabel('Trial')
  ylabel('Baseline spike count')
  print_session_unit(gca, ninfo(cc), 0, 'horizontal')
  ppretty([14,4])
  print([ROOTDIR,ninfo(cc).area,'-',ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff'); pause(0.1); close()
  
end%for:cells(cc)

end%fxn:plotSpkCtXtrial()

