function [ idx_err , idx_corr ] = equate_respdir_err_vs_corr( idx_err , idx_corr , octant )
%equate_respdir_err_vs_corr Summary of this function goes here
%   Detailed explanation goes here

MIN_PER_DIR = 8;

for dd = 1:8

  idx_resp_dd = (octant == dd);

  num_err_dd = sum(idx_err & idx_resp_dd);
  num_corr_dd = sum(idx_corr & idx_resp_dd);

  if (num_err_dd < MIN_PER_DIR) %not enough errors in this direction

    idx_err(find(idx_err & idx_resp_dd)) = false;
    idx_corr(find(idx_corr & idx_resp_dd)) = false;

  elseif (num_corr_dd > num_err_dd) %enough errors but too many correct resp's
    %HERE IS WHERE WE SHOULD CONTROL FOR RT AND/OR TRIAL NUMBER
    %FOR NOW, I JUST TAKE THE FIRST XX TRIALS

    tr_corr_dd = find(idx_corr & idx_resp_dd);
    tr_corr_dd_remove = tr_corr_dd(num_err_dd+1:end);
    idx_corr(tr_corr_dd_remove) = false;

  end

end%for:direction_resp(dd)

end%util:equate_respdir_err_vs_corr()

