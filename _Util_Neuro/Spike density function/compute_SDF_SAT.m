function [ sdf ] = compute_SDF_SAT( spike_times )
%compute_spike_density_fxn This function computes the spike density
%function from spike time (raster) data for the SAT visual search data set.
%   Detailed explanation goes here

%make sure our input is of the correct format
if ~iscell(spike_times)
  error('Input "spike_times" should be of class "cell"')
end

N_TRIAL = length(spike_times);
N_SAMP = 6001; %num samples per trial
sdf = single( NaN(N_TRIAL,N_SAMP) );

%initialize the excitatory post-synaptic potential
tau_d = 20; tau_g = 1;
epsp = @(x) exp(-x/tau_d) .* (1 - exp(-x/tau_g));
epsp_conv = epsp((0:199)');
epsp_conv = 1000 * epsp_conv / sum(epsp_conv);


%loop over trials and calculate single-trial SDF
for tt = 1:N_TRIAL
  
  train_tt = zeros(1,N_SAMP);
  train_tt(spike_times{tt}) = 1;
  
  %compute the convolution
  tmp = conv(train_tt, epsp_conv, 'full');
  sdf(tt,:) = tmp(1:N_SAMP);
  
end % for : trial (tt)

end % fxn : compute_SDF_SAT()

