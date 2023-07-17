function [ spikes ] = load_spikes_SAT( uNum , varargin )
%load_spikes_SAT This function loads the pre-processed spike times for the
%neuron of interest from the SAT data set (Da, Eu, Q, S).
% 
%   Inputs
%   uNum - unit identification number
%   task - SAT (search), MG (mem-guided), DET (detection)
% 

args = getopt(varargin, {{'user=','thoma'}, {'task=','Search'}});

if isempty(args.user)
  user = 'Thomas Reppert';
else
  user = args.user;
end

dataDir = ['C:\Users\', user, '\Dropbox\Speed Accuracy\Data\spikes', args.task, '\'];

str_uu = num2str(uNum);
if (uNum < 10)
  str_uu = ['00', str_uu];
elseif (uNum < 100)
  str_uu = ['0', str_uu];
end

switch (args.task)
  case 'Search'
    spikes = load([dataDir, 'spikes', str_uu, '.mat'], 'spikes');
    spikes = spikes.spikes;

  case 'MG'
    spikes = load([dataDir, 'spikesMG_', str_uu, '.mat'], ['spikesMG',str_uu]);
    spikes = spikes.(['spikesMG',str_uu]);

end % switch : (args.task)

end % util : load_spikes_SAT()

