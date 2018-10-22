function [ sdf_out ] = rem_spikes_post_corrective_SAT( sdf_in , movesAll )
%[ sig_out ] = remove_spikes_post_response( sig_in , movesAll.resptime )
%   Detailed explanation goes here

LEAD_TIME = 0;
TIME_PRIMARY_RESP = 3500; %note -- SDF has already been centered at primary resp.

[NUM_TRIAL, NUM_SAMP] = size(sdf_in);

%initialize corrected signal (i.e. signal w/o movement-related activity)
sdf_out = sdf_in;

%get timing of corrective saccade
RT_corrective = NaN(1,NUM_TRIAL);
for jj = 1:NUM_TRIAL
  
  idx_jj = (movesAll.trial == jj);
  
  %NOTE -- This needs to be indexed correctly -- i.e. pass idx_err as
  %input!!
  if (sum(idx_jj) < 2)
    error('No corrective saccade on Trial %d', jj)
  end
  
end%for:trials(jj)

%loop over all trials and remove response-locked signal
for jj = 1:NUM_TRIAL
  
  %if response time is zero or NaN, just continue
  if isnan(movesAll.resptime(jj)); continue; end
  
  idx_remove = TIME_PRIMARY_RESP + movesAll.resptime(jj) - LEAD_TIME;
  
  %remove spikes post-response
  sdf_out(jj,idx_remove:NUM_SAMP) = NaN;
  
end%for:trials(jj)

%remove signals from all trials after median RT
idx_remove = TIME_PRIMARY_RESP + round(nanmedian(movesAll.resptime)) - LEAD_TIME;

sdf_out(:,idx_remove:NUM_SAMP) = NaN;

end%utility:rem_spikes_post_corrective_SAT()

