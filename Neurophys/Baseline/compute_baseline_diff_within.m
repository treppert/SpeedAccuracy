function [ varargout ] = compute_baseline_diff_within( spikes , ninfo , binfo )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);

IDX_BASE = 3500 + (-500:-100);

%% Get the number of spikes during baseline on trial-by-trial basis

num_spikes = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);

for kk = 1:NUM_CELLS
  
  %get session number corresponding to behavioral data
  kk_binfo = ismember({binfo.session}, ninfo(kk).session);
  
  %index by condition
  trial_acc = find(binfo(kk_binfo).condition == 1);
  trial_fast = find(binfo(kk_binfo).condition == 3);
  
  %compute spike trains
  num_acc = length(trial_acc);
  num_fast = length(trial_fast);
  
  train_acc = false(num_acc, 6001);
  train_fast = false(num_fast, 6001);
  
  for jj = 1:num_acc
    train_acc(jj,spikes(kk).SAT{trial_acc(jj)}) = true;
  end
  for jj = 1:num_fast
    train_fast(jj,spikes(kk).SAT{trial_fast(jj)}) = true;
  end
  
  %get sum of spikes on baseline interval of interest
  num_spikes(kk).acc = sum(train_acc(:,IDX_BASE), 2);
  num_spikes(kk).fast = sum(train_fast(:,IDX_BASE), 2);
  
end%for:cells(kk)


%% Determine significance of baseline difference for each cell
pval = cell(1,NUM_CELLS);
hval = pval;
info = pval;

for kk = 1:NUM_CELLS
  
  num_acc = num_spikes(kk).acc;
  num_fast = num_spikes(kk).fast;
  
  %Mann-Whitney U-test
  [pval{kk},hval{kk},info{kk}] = ranksum(num_fast, num_acc, 'alpha',.05);
  hval{kk} = sign(info{kk}.zval) * hval{kk}; %determine direction of bias
  
end%for:cells(kk)

if (nargout > 0)
  varargout{1} = struct('h',hval, 'p',pval, 'info',info);
end

%% Report number of cells with significant difference by cell type
cell_type = {ninfo.type};

idx_vis = ismember(cell_type,'V');
idx_vismove = ismember(cell_type,'VM');
idx_move = ismember(cell_type,'M');
idx_none = ~ismember(cell_type, {'V','VM','M'});

hval = cell2mat(hval);

fprintf('%d out of %d vis cells with F > A baseline\n',sum(hval(idx_vis)==1), sum(idx_vis))
fprintf('%d out of %d vis cells with A > F baseline\n',sum(hval(idx_vis)==-1), sum(idx_vis))
fprintf('%d out of %d vis-move cells with F > A baseline\n',sum(hval(idx_vismove)==1), sum(idx_vismove))
fprintf('%d out of %d vis-move cells with A > F baseline\n',sum(hval(idx_vismove)==-1), sum(idx_vismove))
fprintf('%d out of %d move cells with F > A baseline\n',sum(hval(idx_move)==1), sum(idx_move))
fprintf('%d out of %d move cells with A > F baseline\n',sum(hval(idx_move)==-1), sum(idx_move))
% fprintf('%d out of %d unclassified cells with F > A baseline\n',sum(hval(idx_none)==1), sum(idx_none))
% fprintf('%d out of %d unclassified cells with A > F baseline\n',sum(hval(idx_none)==-1), sum(idx_none))

end%function:compute_baseline_diff_within()

