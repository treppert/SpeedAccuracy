function [ spike_times ] = load_spike_times_SAT( neuron_info )
%load_spike_times_SAT Summary of this function goes here
%   Detailed explanation goes here

unit = {neuron_info.unit};
session = {neuron_info.sess};
NUM_NEURONS = length(neuron_info);

%initialize output
spike_times = new_struct({'DET','MG','SAT'}, 'dim',[1,NUM_NEURONS]);

%% Data processing ****

for nn = 1:NUM_NEURONS
  
  fprintf('Session %s - Unit %s\n', session{nn}, unit{nn})
  
  if (length(unit{nn}) > 2)
    UNIT = ['DSP', unit{nn}];
  else
    UNIT = ['DSP0', unit{nn}];
  end
  
%   spike_times(nn).DET = load_spike_times(UNIT, session{nn}, 'DET');
  spike_times(nn).MG  = load_spike_times(UNIT, session{nn}, 'MG');
  spike_times(nn).SAT = load_spike_times(UNIT, session{nn}, 'SAT');
  
end%for:neurons(nn)

end


function [ spike_times ] = load_spike_times( unit , session , task )

switch (session(1))
  case 'D'
    monkey = 'Darwin';
  case 'E'
    monkey = 'Euler';
  case 'Q'
    monkey = 'Quincy';
  case 'S'
    monkey = 'Seymour';
  otherwise
    error('Monkey initial not recognized for unit %s', unit)
end%switch:initial

% ROOT_DIR = ['~/Documents/SAT/', monkey, '/'];
ROOT_DIR = ['/data/search/SAT/', monkey, '/'];

if strcmp(task, 'SAT')
  mat_file = [ROOT_DIR, session, '-RH_SEARCH.mat'];
else
  mat_file = [ROOT_DIR, session, '-RH_',task,'.mat'];
end

if (~exist(mat_file, 'file'))
  fprintf('Warning -- File %s not found\n', mat_file)
  spike_times = [];
  return
end

load(mat_file, unit)
eval(['neuron = ', unit, ';'])

%initialize spike times
num_trials = size(neuron,1);
spike_times = cell(1,num_trials);

%save spike times
for jj = 1:num_trials
  DSP = neuron(jj,:);
  DSP(DSP == 0) = [];
  spike_times{jj} = DSP;
end

end%function:load_spike_times
