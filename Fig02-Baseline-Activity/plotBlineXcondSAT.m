function [ varargout ] = plotBlineXcondSAT( binfo , ninfo , nstats , spikes , varargin )
%plotBlineXcondSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
if strcmp(args.area, 'SEF')
  idxVis = ismember({ninfo.visType}, {'sustained'});
else
  idxVis = ([ninfo.visGrade] >= 0.5);
end
idxEfficient = ismember([ninfo.taskType], [1]);
idxKeep = (idxArea & idxMonkey & idxVis & idxEfficient);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

NUM_CELLS = length(spikes);
T_BASE  = 3500 + (-600 : 20);

sdfAcc = NaN(NUM_CELLS,length(T_BASE));
sdfFast = NaN(NUM_CELLS,length(T_BASE));

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  sdfKK = compute_spike_density_fxn(spikes(cc).SAT);

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  
  %compute SDFs
  sdfAcc(cc,:) = nanmean(sdfKK(idxAcc, T_BASE));
  sdfFast(cc,:) = nanmean(sdfKK(idxFast, T_BASE));
  
  %parameterize baseline activity
  ccNS = ninfo(cc).unitNum; %index nstats correctly
  nstats(ccNS).blineAccMEAN = mean(sdfAcc(cc,:));
  nstats(ccNS).blineFastMEAN = mean(sdfFast(cc,:));
  nstats(ccNS).blineAccSD = std(sdfAcc(cc,:));
  nstats(ccNS).blineFastSD = std(sdfFast(cc,:));
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

%% Plotting
nstats = nstats(idxKeep);   NUM_SEM = sum(idxKeep);

%spike density function
% normFactor = mean([[nstats.blineAccMEAN] ; [nstats.blineFastMEAN]])';
% sdfAcc = sdfAcc ./ normFactor;
% sdfFast = sdfFast ./ normFactor;
% 
% figure(); hold on
% shaded_error_bar(T_BASE-3500, mean(sdfFast), std(sdfFast)/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0], 'LineWidth',1.0})
% shaded_error_bar(T_BASE-3500, mean(sdfAcc), std(sdfAcc)/sqrt(NUM_SEM), {'r-', 'LineWidth',1.0})
% xlabel('Time from array (ms)')
% ylabel('Normalized activity')
% ppretty([4.8,3])


%histogram of difference in discharge rate X condition
pause(0.1)
blineDiff = [nstats.blineFastMEAN] - [nstats.blineAccMEAN];
blineEffect = [nstats.blineEffect];

figure(); hold on
histogram(blineDiff, 'BinWidth',2, 'FaceColor',[.5 .5 .5])
histogram(blineDiff(blineEffect==1), 'BinWidth',2, 'FaceColor',[0 .7 0])
histogram(blineDiff(blineEffect==-1), 'BinWidth',2, 'FaceColor','r')
plot(mean(blineDiff)*ones(1,2), [0 4], 'k:', 'LineWidth',2.0)
xlabel('Discharge rate diff. (sp/s')
ylabel('Number of neurons')
ppretty([5,4])

end%fxn:plotBlineXcondSAT()

