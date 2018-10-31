function [ idx_err , idx_corr ] = equate_respdir_err_vs_corr( idx_err , idx_corr , octant , varargin )
%equate_respdir_err_vs_corr Summary of this function goes here
%   Detailed explanation goes here
%   args.equate_num_trials -- If this input is true, then for those
%   directions with both correct and error trials, the number of correct
%   trials is cut to match that of error trials. (default = false)
% 


args = getopt(varargin, {'equate_num_trials'});

MIN_PER_DIR = 8; %min # of trials of each type per resp. direction

for dd = 1:8 %loop over resp. directions

  idx_resp_dd = (octant == dd);

  num_err_dd = sum(idx_err & idx_resp_dd); % # error resp's in this dir.
  num_corr_dd = sum(idx_corr & idx_resp_dd); % # correct resp's

  if (num_err_dd < MIN_PER_DIR) %not enough errors in this direction

    idx_err(idx_err & idx_resp_dd) = false;
    idx_corr(idx_corr & idx_resp_dd) = false;

  elseif ((num_corr_dd > num_err_dd) && args.equate_num_trials) %enough errors but too many correct resp's
    %HERE IS WHERE WE SHOULD CONTROL FOR RT AND/OR TRIAL NUMBER
    %FOR NOW, I JUST SAMPLE TRIALS WITHOUT REPLACEMENT

    tr_corr_dd = find(idx_corr & idx_resp_dd); %get all correct trials in this dir.
    
    %remove the appropriate # of correct trials via random trial sampling
    num_corr_dd_remove = num_corr_dd - num_err_dd;
    tr_corr_dd_remove = datasample(tr_corr_dd, num_corr_dd_remove, 'replace',false);
    idx_corr(tr_corr_dd_remove) = false;

  end

end%for:direction_resp(dd)

end%util:equate_respdir_err_vs_corr()

