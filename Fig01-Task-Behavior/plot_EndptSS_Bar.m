function [ ] = plot_EndptSS_Bar( binfo , movesPP , varargin )
%plot_EndptSS_Bar Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, ~, movesPP] = utilIsolateMonkeyBehavior(binfo, cell(1,length(binfo)), movesPP, args.monkey);
NUM_SESSION = length(binfo);

NUM_MORE = sum([binfo.taskType] == 1);  iiMore = 0;
NUM_LESS = sum([binfo.taskType] == 2);  iiLess = 0;

Pr2tgt = struct('AccMore',[], 'AccLess',[], 'FastMore',[], 'FastLess',[]);
Pr2tgt = populate_struct(Pr2tgt, {'AccMore','FastMore'}, NaN(1,NUM_MORE));
Pr2tgt = populate_struct(Pr2tgt, {'AccLess','FastLess'}, NaN(1,NUM_LESS));

for kk = 1:NUM_SESSION
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErrChc = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  if (binfo(kk).taskType == 1) %More efficient
    iiMore = iiMore + 1;
    Pr2tgt.AccMore(iiMore) = sum((movesPP(kk).endpt == 1) & idxAcc & idxErrChc) / sum(idxAcc & idxErrChc);
    Pr2tgt.FastMore(iiMore) = sum((movesPP(kk).endpt == 1) & idxFast & idxErrChc) / sum(idxFast & idxErrChc);
  else %Less efficient
    iiLess = iiLess + 1;
    Pr2tgt.AccLess(iiLess) = sum((movesPP(kk).endpt == 1) & idxAcc & idxErrChc) / sum(idxAcc & idxErrChc);
    Pr2tgt.FastLess(iiLess) = sum((movesPP(kk).endpt == 1) & idxFast & idxErrChc) / sum(idxFast & idxErrChc);
  end
  
end%for:session(kk)

%% Stats - two-way between-subjects ANOVA
% writeData_TwoWayANOVA( Pr2tgt , 'C:\Users\Thomas Reppert\Dropbox\SAT\Stats\Behavior-SSendpt.mat' )

DV_Pr2tgt = [Pr2tgt.AccMore Pr2tgt.AccLess Pr2tgt.FastMore Pr2tgt.FastLess]';
Condition = [ones(1,NUM_SESSION) 2*ones(1,NUM_SESSION)]';
Efficiency = [ones(1,NUM_MORE) 2*ones(1,NUM_LESS) ones(1,NUM_MORE) 2*ones(1,NUM_LESS)]';
anovan(DV_Pr2tgt, {Condition Efficiency}, 'model','interaction', 'varnames',{'Condition','Efficiency'});

%% Plotting
muAccMore = mean(Pr2tgt.AccMore);     seAccMore = std(Pr2tgt.AccMore) / sqrt(NUM_MORE);
muAccLess = mean(Pr2tgt.AccLess);     seAccLess = std(Pr2tgt.AccLess) / sqrt(NUM_LESS);
muFastMore = mean(Pr2tgt.FastMore);     seFastMore = std(Pr2tgt.FastMore) / sqrt(NUM_MORE);
muFastLess = mean(Pr2tgt.FastLess);     seFastLess = std(Pr2tgt.FastLess) / sqrt(NUM_LESS);

%barplot
figure(); hold on
bar(1, muFastMore, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
bar(2, muFastLess, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',1.25)
bar(3, muAccMore, 0.7, 'FaceColor','r', 'LineWidth',0.25)
bar(4, muAccLess, 0.7, 'FaceColor','r', 'LineWidth',1.25)
errorbar([muFastMore muFastLess muAccMore muAccLess], [seFastMore seFastLess seAccMore seAccLess], ...
  'Color','k', 'CapSize',0)
xticks([]); xticklabels([])
ylim([.6 .9]); ylabel('P (saccade to target)')
ppretty([2,3])

end%fxn:plot_EndptSS_Bar()

function [ ] = writeData_TwoWayANOVA( param , writeFile )

N_MORE = length(param.AccMore);
N_LESS = length(param.AccLess);
N_SESS = N_MORE + N_LESS;

%dependent variable
DV_Parameter = [ param.AccMore param.AccLess param.FastMore param.FastLess ]';

%factors
F_Condition = [ ones(1,N_SESS) 2*ones(1,N_SESS) ]';
F_Efficiency = [ ones(1,N_MORE) 2*ones(1,N_LESS) ones(1,N_MORE) 2*ones(1,N_LESS) ]';

%write data
save(writeFile, 'DV_Parameter','F_Condition','F_Efficiency')

end%util:writeData()