function [ spikes ] = load_spikes_SAT( uNum , varargin )
%load_spikes_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'dataDir=',[]}});

if isempty(args.dataDir)
  dataDir = 'C:\Users\thoma\Dropbox\Speed Accuracy\Data\spikes\';
else
  dataDir = args.dataDir;
end

str_uu = num2str(uNum);
if (uNum < 10)
  str_uu = ['00', str_uu];
elseif (uNum < 100)
  str_uu = ['0', str_uu];
end

spikes = load([dataDir, 'spikes', str_uu, '.mat'], 'spikes');
spikes = spikes.spikes;

end % util : load_spikes_SAT()

