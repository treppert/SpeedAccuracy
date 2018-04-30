function [ info ] = determine_errors_SAT( info , moves , gaze )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

DEBUG = true;

NUM_SESSION = length(info);

% for kk = 1:NUM_SESSION
%   info(kk).err_dir = false(1,info(kk).num_trials);
%   info(kk).err_time = false(1,info(kk).num_trials);
% end%for:sessions(kk)
% for kk = 1:NUM_SESSION
%   info(kk).err_dir(info(kk).errors == 3) = true;
%   info(kk).err_time(info(kk).errors == 4) = true;
% end%for:sessions(kk)

%determine direction errors
for kk = 1:NUM_SESSION
  
  trial_err_TEMPO = find(info(kk).err_dir);
  trial_err_ = find(moves(kk).octant ~= info(kk).tgt_octant);
  
  trial_intersect = intersect(trial_err_TEMPO, trial_err_);
  trial_union = union(trial_err_TEMPO, trial_err_);
  
  trial_disagree = trial_union(~ismember(trial_union, trial_intersect));
  NUM_DISAGREE = length(trial_disagree);
  
  fprintf('Session %d %s -- %d/%d trials\n', kk, info(kk).session, NUM_DISAGREE, info(kk).num_trials)
  
  if (DEBUG)
    for jj = 1:NUM_DISAGREE
      
      idx_jj = trial_disagree(jj);
      
      th_tgt = convert_tgt_octant_to_angle(info(kk).tgt_octant(idx_jj));
      r_tgt = info(kk).tgt_eccen(idx_jj);
      
      th = atan2(gaze(kk).y(3500:4500,idx_jj), gaze(kk).x(3500:4500,idx_jj));
      r = sqrt(gaze(kk).x(3500:4500,idx_jj).^2 + gaze(kk).y(3500:4500,idx_jj).^2);
      
      figure(); polaraxes(); hold on
      polarplot(th, r, 'k-')
      polarplot(th_tgt, r_tgt, 'bo')
      
      if (ismember(trial_disagree(jj), trial_err_TEMPO))
        title('Error - TEMPO')
      else
        title('Error - Tom')
      end
      
    end
  end%DEBUG?
  
end

%determine timing errors


end%function:determine_errors_SAT()
