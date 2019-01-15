function [ ] = plot_numResp_vs_dir_MG( moves , binfo )
%plot_numResp_vs_dir_MG() Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

numResp = NaN(NUM_SESSION,8);

for kk = 1:NUM_SESSION
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_hold | binfo(kk).err_nosacc);
  
  for dd = 1:8
    
    numResp(kk,dd) = sum((moves(kk).octant == dd) & idx_corr);
    
  end
  
end%for:session(kk)

numResp = cat(2, numResp, numResp(:,1)); %complete the circle for plotting

%% Plotting
THETA_PLOT = (0 : pi/4 : 2*pi);

figure(); polaraxes(); hold on
polarplot(THETA_PLOT, numResp, 'k-', 'LineWidth',1.0)
thetaticks([])
ppretty('image_size',[4,4])

end%fxn:plot_numResp_vs_dir_MG()

