function [ sdf_out ] = rem_spikes_post_corrective_SAT( sdf_in , movesAll , trial_err )
%[ sig_out ] = rem_spikes_post_corrective_SAT( sig_in , movesAll.resptime )
%   Detailed explanation goes here

LEAD_TIME = 0;
TIME_ZERO = 3500; %note -- SDF has already been centered at primary resp.

[NUM_TRIAL, NUM_SAMP] = size(sdf_in);

%initialize corrected signal (i.e. signal w/o movement-related activity)
sdf_out = sdf_in;

%get timing of corrective saccade
RT_corrective = NaN(1,NUM_TRIAL);
for jj = 1:NUM_TRIAL
  idx_jj = find(movesAll.trial == trial_err(jj));
  
  if (length(idx_jj) < 2); continue; end
  RT_corrective(jj) = double(movesAll.resptime(idx_jj(2)) - movesAll.resptime(idx_jj(1)));
end%for:trials(jj)

%remove post-corrective saccade spikes (SDF already aligned on RT)
for jj = 1:NUM_TRIAL
  if isnan(RT_corrective(jj)); continue; end
  
  idx_rem = TIME_ZERO + RT_corrective(jj) - LEAD_TIME;
  sdf_out(jj,idx_rem:NUM_SAMP) = NaN;
end%for:trials(jj)

%take care of any trials with no corrective saccade
sdf_out(isnan(RT_corrective),:) = NaN;

%remove signals from all trials after median corrective saccade RT
idx_remove = TIME_ZERO + round(nanmedian(RT_corrective)) - LEAD_TIME;
sdf_out(:,idx_remove:NUM_SAMP) = NaN;

end%utility:rem_spikes_post_corrective_SAT()

