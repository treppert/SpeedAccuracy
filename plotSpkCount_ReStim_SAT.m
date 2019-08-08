function [ ] = plotSpkCount_ReStim_SAT( binfo , ninfo , spikes , varargin )
%plotSpkCount_ReStim_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxKeep = (idxArea & idxMonkey & (idxVis | idxMove)); %baseline
% idxKeep = (idxArea & idxMonkey & idxVis); %visual response

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

T_TEST = 3500 + [-600 20]; %baseline
% T_TEST = 3500 + [75 200]; %visual response

%initializations
spkCountAcc = NaN(1,NUM_CELLS);
spkCountFast = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  %compute spike count for all trials
  spkCtCC = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikes(cc).SAT);
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
  %index by condition and RT limits
  idxAcc = ((binfo(kk).condition == 1) & idxCorr & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & idxCorr & ~idxIso);
  
  %compute trial-wise spike counts per task condition
  scAccCC = spkCtCC(idxAcc);
  scFastCC = spkCtCC(idxFast);
  
  %remove outliers
  if (nanmedian(scAccCC) >= 1) %make sure we have a minimum spike count
    idxCutAcc = estimate_spread(scAccCC, 3.5);      scAccCC(idxCutAcc) = [];
    idxCutFast = estimate_spread(scFastCC, 3.5);    scFastCC(idxCutFast) = [];
  end
  
  %z-score spike counts
  muSpkCt = mean([scAccCC scFastCC]);
  sdSpkCt = std([scAccCC scFastCC]);
  scAccCC = (scAccCC - muSpkCt) / sdSpkCt;
  scFastCC = (scFastCC - muSpkCt) / sdSpkCt;
    
  %save mean spike counts
  spkCountAcc(cc) = mean(scAccCC);
  spkCountFast(cc) = mean(scFastCC);
  
end%for:cells(cc)

%split by search efficiency
ccMore = ([ninfo.taskType] == 1);   NUM_MORE = sum(ccMore);
ccLess = ([ninfo.taskType] == 2);   NUM_LESS = sum(ccLess);

scAccMore = spkCountAcc(ccMore);    scAccLess = spkCountAcc(ccLess);
scFastMore = spkCountFast(ccMore);  scFastLess = spkCountFast(ccLess);

%% Stats - Two-way split-plot ANOVA
ROOT_DIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Stats\';
spikeCount = struct('AccMore',scAccMore, 'AccLess',scAccLess, 'FastMore',scFastMore, 'FastLess',scFastLess);
writeData_TwoWayANOVA( spikeCount , [ROOT_DIR,args.area,'-VisResponse.mat'] )

%% Plotting

muAccMore = mean(scAccMore);    seAccMore = std(scAccMore) / sqrt(NUM_MORE);
muAccLess = mean(scAccLess);    seAccLess = std(scAccLess) / sqrt(NUM_LESS);
muFastMore = mean(scFastMore);    seFastMore = std(scFastMore) / sqrt(NUM_MORE);
muFastLess = mean(scFastLess);    seFastLess = std(scFastLess) / sqrt(NUM_LESS);

figure(); hold on
bar((1:4), [muAccMore muFastMore muAccLess muFastLess], 0.6, 'FaceColor',[.4 .4 .4], 'LineWidth',0.25)
errorbar((1:4), [muAccMore muFastMore muAccLess muFastLess], [seAccMore seFastMore seAccLess seFastLess], 'Color','k', 'CapSize',0)
ppretty([1.5,3])

end%fxn:plotSpkCount_ReStim_SAT()

function [ ] = writeData_TwoWayANOVA( param , writeFile )

N_MORE = length(param.AccMore);
N_LESS = length(param.AccLess);
N_CELL = N_MORE + N_LESS;

%dependent variable
DV_Parameter = [ param.AccMore param.AccLess param.FastMore param.FastLess ]';

%factors
F_Condition = [ ones(1,N_CELL) 2*ones(1,N_CELL) ]';
F_Efficiency = [ ones(1,N_MORE) 2*ones(1,N_LESS) ones(1,N_MORE) 2*ones(1,N_LESS) ]';
F_Neuron = linspace(1,N_CELL,N_CELL); F_Neuron = repmat(F_Neuron, 1,2)';

%write data
save(writeFile, 'DV_Parameter','F_Condition','F_Efficiency','F_Neuron')

tmp = [param.AccMore param.AccLess param.FastMore param.FastLess]';
Condition = [ones(1,N_CELL) 2*ones(1,N_CELL)]';
Efficiency = [ones(1,N_MORE) 2*ones(1,N_LESS) ones(1,N_MORE) 2*ones(1,N_LESS)]';
anovan(tmp, {Condition Efficiency}, 'model','interaction', 'varnames',{'Condition','Efficiency'});

end%util:writeData()