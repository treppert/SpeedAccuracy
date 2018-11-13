function [ varargout ] = plot_distr_t_postprimary_sacc( moves , movesAll , binfo )
%plot_distr_t_postprimary_sacc Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);
BIN_EDGES = (0 : 25 : 800);

t_pp = [];
t_pp_out = cell(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  num_trial = length(moves(kk).clipped);
  t_pp_out{kk} = NaN(1,num_trial);
  
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  trial_errdir = find(idx_errdir);
  
  for jj = 1:num_trial
    
    if ~ismember(jj, trial_errdir); continue; end
    
    idx_jj = find(movesAll(kk).trial == jj);
    
    if (length(idx_jj) < 2); continue; end
    
    t_primary_jj = moves(kk).resptime(jj);
    t_postprim_jj = double(movesAll(kk).resptime(idx_jj(2)) - t_primary_jj);
    
    if (t_postprim_jj > BIN_EDGES(end)); continue; end
    
    t_pp = cat(2, t_pp, t_postprim_jj);
    t_pp_out{kk}(jj) = t_postprim_jj;
    
  end%for:trial(jj)
  
end%for:session(kk)

figure()
histogram(t_pp, BIN_EDGES, 'Normalization','probability', 'FaceColor',[.2 .2 .2])
ppretty()

if (nargout > 0)
  varargout{1} = t_pp_out;
end

end%fxn:plot_distr_t_postprimary_sacc()

