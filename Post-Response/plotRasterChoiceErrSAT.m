function [  ] = plotRasterChoiceErrSAT( binfo , moves , ninfo , spikes , varargin )
%plotRasterChoiceErrSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SC'}, {'monkey=','D'}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

NUM_CELLS = length(spikes);
T_PLOT  = 3500 + (-400 : 800);
SORT_ISI = true;

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by resp. dir re. MF
  idxMF = ismember(moves(kk).octant, ninfo(cc).MF);
  %index by condition
  idxFast = ((binfo(kk).condition == 3) & ~idxIso & idxMF);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
%   idxCorr = (~binfo(kk).err_dir & binfo(kk).err_time);
  
  %organize spikes as 1-D array for plotting
  tmp = spikes(cc).SAT(idxFast & idxCorr);
  t_spikes = cell2mat(tmp);
  trials = NaN(1,length(t_spikes));
  
  %get trial numbers corresponding to each spike
  idx = 1;
  nTrials = sum(idxFast & idxCorr);
  for jj = 1:nTrials
    trials(idx:idx+length(tmp{jj})-1) = jj;
    idx = idx + length(tmp{jj});
  end%for:trials(jj)
  
  if (SORT_ISI) %if desired, sort trials by ISI
    RT = double(moves(kk).resptime(idxFast & idxCorr));
    [RT,idx_RT] = sort(RT);
    
    trials_new = NaN(1,length(t_spikes));
    for jj = 1:nTrials
      trials_new(trials == jj) = idx_RT(jj);
    end
    trials = trials_new;
    
  end%if:sort-x-ISI
  
  %remove spikes outside of time window of interest
  idx_time = ((t_spikes >= T_PLOT(1)) & (t_spikes <= T_PLOT(end)));
  t_spikes = t_spikes(idx_time);
  trials = trials(idx_time);
  
  
  %% Plotting
  figure(); hold on
  plot(t_spikes-3500, trials, '.', 'Color',[0 .5 0], 'MarkerSize',4)
  plot([0 0], [0 nTrials], 'k--', 'LineWidth',1.5)
  if (SORT_ISI)
    plot(RT, (1:nTrials), 'o', 'Color',[.4 .4 .4], 'MarkerSize',3)
  end
  
  xlabel('Time from stimulus (ms)')
  ylabel('Trial number')
  
  title([ninfo(cc).sess,'-',ninfo(cc).unit,' -- N_{trial} = ',num2str(nTrials)], 'FontSize',8)
  ppretty('image_size',[8,9])
  pause()
  
end%for:cells(cc)

end%util:plotRasterChoiceErrSAT()
