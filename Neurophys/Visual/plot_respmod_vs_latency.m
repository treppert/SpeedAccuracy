function [  ] = plot_respmod_vs_latency( modF2A , modA2F , latency )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Bin by latency

BIN_LIM = [ (40:10:100) , 130 ];
NUM_BIN = length(BIN_LIM) - 1;
LAT_PLOT = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM);
MIN_PER_BIN = 2;


%% Compute mean and SD of modulation across bins

mod_mean = new_struct({'F2A','A2F'}, 'dim',[1,NUM_BIN]);
mod_mean = populate_struct(mod_mean, {'F2A','A2F'}, NaN);
mod_sd = mod_mean;

mod_num = NaN(1,NUM_BIN); %number of cells per bin

for jj = 1:NUM_BIN
  
  idx_jj = ((latency >= BIN_LIM(jj)) & (latency < BIN_LIM(jj+1)));
  
  if (sum(idx_jj) < MIN_PER_BIN); continue; end
  
  mod_num(jj) = sum(idx_jj);
  
  mod_mean(jj).F2A = mean(modF2A(idx_jj));
  mod_mean(jj).A2F = mean(modA2F(idx_jj));
  
  mod_sd(jj).F2A = std(modF2A(idx_jj));
  mod_sd(jj).A2F = std(modA2F(idx_jj));
  
end%for:latency_bins(jj)


%% Plotting

figure(); hold on %mean modulation
errorbar_no_caps(LAT_PLOT, [mod_mean.A2F], 'err',[mod_sd.A2F]./sqrt(mod_num), 'color',[0 .7 0])
errorbar_no_caps(LAT_PLOT, [mod_mean.F2A], 'err',[mod_sd.F2A]./sqrt(mod_num), 'color','r')
ppretty()

figure(); hold on %sd of modulation
plot(LAT_PLOT, [mod_sd.A2F], '--', 'Color',[0 .7 0])
plot(LAT_PLOT, [mod_sd.F2A], 'r--')
ppretty()

end%function:plot_respmod_vs_latency()


