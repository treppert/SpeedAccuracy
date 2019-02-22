function [ ] = plotDistrConditionLengthSAT( info , monkey )
%plotDistrConditionLengthSAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(info);

%get trials with change in cueing
tr_switch = identify_condition_switch(info, monkey);

len_miniblk = [];
num_miniblk = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  tr_switch_kk = sort([tr_switch(kk).A2F, tr_switch(kk).F2A]);
  dt_switch_kk = diff(tr_switch_kk);
  
  len_miniblk = cat(2, len_miniblk, dt_switch_kk);
  num_miniblk(kk) = length(dt_switch_kk);
  
end%for:sessions(kk)

fprintf('Number of mini-blocks = %d +- %d (mean +- sd)\n', mean(num_miniblk), std(num_miniblk))

figure()
histogram(len_miniblk, 'Normalization','probability', 'FaceColor',[.5 .5 .5], 'BinEdges',0.5:30.5)
ppretty()

end%fxn:plotDistrConditionLengthSAT()

