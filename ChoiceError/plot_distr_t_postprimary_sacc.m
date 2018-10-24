function [ ] = plot_distr_t_postprimary_sacc( moves , movesAll )
%plot_distr_t_postprimary_sacc Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);
BIN_EDGES = (0 : 25 : 400);

t_sacc_pp = [];

for kk = 1:NUM_SESSION
  
  num_trial = length(moves(kk).clipped);
  
  for jj = 1:num_trial
    
    idx_jj = find(movesAll(kk).trial == jj);
    
    if (length(idx_jj) < 2); continue; end
    
    t_primary_jj = moves(kk).resptime(jj);
    t_postprim_jj = double(movesAll(kk).resptime(idx_jj(2:end)) - t_primary_jj);
    
    t_sacc_pp = cat(2, t_sacc_pp, t_postprim_jj);
    
  end%for:trial(jj)
  
end%for:session(kk)

t_sacc_pp(t_sacc_pp > BIN_EDGES(end)) = [];

figure()
histogram(t_sacc_pp, BIN_EDGES, 'Normalization','probability', 'FaceColor',[.2 .2 .2])
ppretty()

end%fxn:plot_distr_t_postprimary_sacc()

