function [ ] = plot_cdf_RT_MG( moves , binfo )
%plot_CDF_RT_MG() Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

QUANTILE = (0.0 : 0.2 : 1.0);
NUM_QUANT = length(QUANTILE);

respTime = cell(1,NUM_SESSION);
for kk = 1:NUM_SESSION
  respTime{kk} = NaN(NUM_QUANT,8);
end

for kk = 1:NUM_SESSION
  
  RT_kk = double(moves(kk).resptime);
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_hold | binfo(kk).err_nosacc);
  
  for dd = 1:8
    
    respTime{kk}(:,dd) = quantile(RT_kk((moves(kk).octant == dd) & idx_corr), QUANTILE);
    
  end
  
  respTime{kk} = cat(2, respTime{kk}, respTime{kk}(:,1)); %complete the circle for plotting
  
end%for:session(kk)


%% Plotting
THETA_PLOT = (0 : pi/4 : 2*pi);

figure()

for kk = 1:NUM_SESSION
  
  subplot(4,2,kk,polaraxes); hold on
  subaxis(4,2,kk, 'SpacingHoriz', 0.01, 'SpacingVert', 0.01, 'Padding',0.0, 'Margin', 0.0);
  polarplot(THETA_PLOT, respTime{kk}, 'k-', 'LineWidth',1.0)
  thetaticks([])
  rlim([0 1300])
  pause(0.10)
  
end%for:session(kk)

ppretty('image_size',[7,8])

end%fxn:plot_cdf_RT_MG()

