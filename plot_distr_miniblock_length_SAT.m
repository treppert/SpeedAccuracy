function [  ] = plot_distr_miniblock_length_SAT( info , monkey )
%plot_distr_miniblock_length_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(info);

%get trials with change in cueing
tr_switch = identify_condition_switch(info, monkey);

len_miniblk = [];

for kk = 1:NUM_SESSION
  
  tr_switch_kk = sort([tr_switch(kk).A2F, tr_switch(kk).F2A]);
  dt_switch_kk = diff(tr_switch_kk);
  
  len_miniblk = cat(2, len_miniblk, dt_switch_kk);
  
end%for:sessions(kk)

figure()
histogram(len_miniblk, 'Normalization','probability', 'FaceColor',[.5 .5 .5], 'BinEdges',0.5:30.5)
ppretty()

end%fxn:plot_distr_miniblock_length_SAT()

