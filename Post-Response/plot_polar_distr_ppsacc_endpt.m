function [] = plot_polar_distr_ppsacc_endpt( info , movesAll )
%plot_polar_distr_ppsacc_endpt Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(info);

octant_ppsacc = [];

for kk = 1:NUM_SESSION
  
  for jj = 1:info(kk).num_trials
    
    idx_jj = find(movesAll(kk).trial == jj);
    
    if (length(idx_jj) < 2); continue; end
    
    tgt_octant = uint16(info(kk).tgt_octant(jj));
    ppsacc_oct_jj = movesAll(kk).octant(idx_jj(2)) - tgt_octant;
    
    octant_ppsacc = cat(2, octant_ppsacc, ppsacc_oct_jj);
    
  end%for:trial(jj)
  
end%for:session(kk)

%keep convention that 1 = rightward (in this case, to the correct tgt)
octant_ppsacc = octant_ppsacc + 1;

%convert to appropriate format for polarscatter()
weight_octant = NaN(1,8);
for jj = 1:8
  weight_octant(jj) = sum(octant_ppsacc == jj);
end%for:octant(jj)

figure(); polaraxes()
polarscatter((0:pi/4:7*pi/4), 6*ones(1,8), weight_octant/4, [.2 .2 .2])
rlim([0 8]); rticklabels([]); thetaticks([])
ppretty()

end%fxn:plot_polar_distr_ppsacc_endpt()

