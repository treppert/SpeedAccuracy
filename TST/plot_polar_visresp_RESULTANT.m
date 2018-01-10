function [  ] = plot_polar_visresp_RESULTANT( spikes , ninfo , moves , binfo )
%plot_resultant_activity Summary of this function goes here
%   Detailed explanation goes here

TYPE_PLOT = {'VM'};

TIME_QUERY = [25, 50, 80, 150, 250];
NUM_QUERY = length(TIME_QUERY);
HALFWIDTH_QUERY = 4; %sample window over which we average activity

NUM_DIR = 8;
NUM_CELLS = length(ninfo);

THETA_CIRC = linspace(0, 2*pi, NUM_DIR+1);
SHIFT_CIRC = deg2rad(1); %angular shift for polar plotting

%% Compute the SDF for each direction
sdf_x_dir = util_compute_SDF_vs_dir(spikes, ninfo, moves, binfo, TYPE_PLOT);

%% Compute polar representation of the visual response
resp_vs_dir = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
resp_vs_dir = populate_struct(resp_vs_dir, {'acc','fast'}, NaN(NUM_QUERY,NUM_DIR));

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
  
  for qq = 1:NUM_QUERY
    idx_qq = 3500 + (TIME_QUERY(qq)-HALFWIDTH_QUERY : TIME_QUERY(qq)+HALFWIDTH_QUERY);
    
    for jj = 1:NUM_DIR
      resp_vs_dir(kk).acc(qq,jj)  = mean(sdf_x_dir(jj,kk).acc(idx_qq));
      resp_vs_dir(kk).fast(qq,jj) = mean(sdf_x_dir(jj,kk).fast(idx_qq));
    end%for:directions(dd)
  end%for:queries(qq)
end%for:cells(kk)

%% Plotting
for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
  
  maxfr_kk = max(max([resp_vs_dir(kk).acc , resp_vs_dir(kk).fast]));
  
  for qq = 1:NUM_QUERY
    
    figure(); polaraxes(); hold on; set(gca, 'thetatick',[])
    if (qq == 1)
      title([ninfo(kk).session,'-',ninfo(kk).unit], 'fontsize',8, 'position',[270,maxfr_kk])
    else
      title(['t=',num2str(TIME_QUERY(qq))], 'fontsize',8, 'position',[270,maxfr_kk])
    end
    
    util_plot_polar(resp_vs_dir(kk).acc(qq,:), 'acc', THETA_CIRC-SHIFT_CIRC, NUM_DIR)
    util_plot_polar(resp_vs_dir(kk).fast(qq,:), 'fast', THETA_CIRC+SHIFT_CIRC, NUM_DIR)
    
    r_max = 50 * ceil(maxfr_kk/50); rlim([0 r_max]);
    if (qq ~= 1); rticklabels(cell(1,length(get(gca, 'rtick')))); end
    ppretty(); pause(.1)
    
%     print(['~/Dropbox/tmp/',ninfo(kk).session,'-',ninfo(kk).unit,'-polar-',num2str(qq),'.tif'], '-dtiff')
%     close(); pause(.1)
    
  end%for:queries(qq)
end%for:cells(kk)

end%function:plot_polar_visual_response()

function [] = util_plot_polar( resp_vs_dir , condition , theta_circ , num_dir )

if strcmp(condition, 'acc')
  color_indiv = [1 .5 .5];
  color_res = 'r';
else
  color_indiv = [.5 .8 .5];
  color_res = [0 .7 0];
end

x_acc = resp_vs_dir.*cos(theta_circ(1:num_dir));
y_acc = resp_vs_dir.*sin(theta_circ(1:num_dir));
r_acc = sqrt(x_acc.*x_acc + y_acc.*y_acc);

polarplot(ones(2,1)*theta_circ(1:num_dir), [zeros(1,num_dir);r_acc], '-o', ...
  'Color',color_indiv, 'LineWidth',1.25)
pause(.1)

x_res_acc = sum(x_acc);
y_res_acc = sum(y_acc);

r_res_acc = sqrt(x_res_acc*x_res_acc + y_res_acc*y_res_acc);
th_res_acc = atan2(y_res_acc,x_res_acc);

polarplot(th_res_acc*ones(1,2), [0,r_res_acc], '-o', 'Color',color_res, 'LineWidth',1.5)
pause(.1) 

end%util_plot_polar()

