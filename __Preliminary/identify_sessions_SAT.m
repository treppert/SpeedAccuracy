function [ sessions , num_trials ] = identify_sessions_SAT( root_dir , type , varargin )
%identify_sessions_SAT Summary of this function goes here
%   Detailed explanation goes here

if (nargin > 2)
  monkey = varargin{1};
else
  monkey = {''};
end

MIN_TOTAL_TRIALS_PER_SESSION = 700;

%identify recording sessions
sessions.SAT = dir([root_dir, '*_SEARCH.mat']);
sessions.MG = dir([root_dir, '*_MG.mat']);

if isempty(sessions.SAT);  error('No %s sessions found', type);  end
num_sessions = length(sessions.SAT);

%get the number of trials per session
num_trials = struct('MG',zeros(1,num_sessions), 'SAT',zeros(1,num_sessions));
for kk = 1:num_sessions
  
  file_SAT_kk = [sessions.SAT(kk).folder,'/',sessions.SAT(kk).name];
  vars_SAT_kk = whos('-file', file_SAT_kk);
  
  file_MG_kk = [sessions.MG(kk).folder,'/',sessions.MG(kk).name];
  vars_MG_kk = whos('-file', file_MG_kk);
  
  num_trials.SAT(kk) = vars_SAT_kk(1).size(1);
  num_trials.MG(kk) = vars_MG_kk(1).size(1);
  
end

%remove sessions without enough total trials (Q & S)
if ismember(monkey, {'Quincy','Seymour'})
  kkRemove = (num_trials.SAT < MIN_TOTAL_TRIALS_PER_SESSION);
else %Darwin or Euler
%   kkRemove = 1;
  kkRemove = [];
end

sessions.SAT(kkRemove) = [];
num_trials.SAT(kkRemove) = [];
sessions.MG(kkRemove) = [];
num_trials.MG(kkRemove) = [];

end % util : identify_sessions_SAT()
