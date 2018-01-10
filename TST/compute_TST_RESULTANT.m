function [ varargout ] = compute_TST_RESULTANT( spikes , ninfo , moves , binfo )
%plot_resultant_activity Summary of this function goes here
%   Detailed explanation goes here

TYPE_PLOT = {'V','VM'};

TIME_NORM = (50 : 100); %post-array

TIME_PLOT = (0 : 350);
HALFWIDTH_QUERY = 4; %sample window over which we average activity

NUM_DIR = 8;
NUM_CELLS = length(ninfo);

NUM_QUERY = length(TIME_PLOT);

THETA_CIRC = linspace(0, 2*pi, NUM_DIR+1);

THRESH_TST = 0.20;
MINHOLD_TST = 50;
tst = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);

%% Compute the SDF for each direction
sdf_x_dir = util_compute_SDF_vs_dir(spikes, ninfo, moves, binfo, TYPE_PLOT);

%% Compute the vis-response normalization factor for each cell
norm_factor = util_compute_normfactor_visresp(spikes, ninfo, moves, binfo, TIME_NORM);

%% Convert SDF data to resultant firing rate and get TST

mag_res = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
resp_vs_dir = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
resp_vs_dir = populate_struct(resp_vs_dir, {'acc','fast'}, NaN(NUM_QUERY,NUM_DIR));

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
  
  for qq = 1:NUM_QUERY
    idx_qq = 3500 + (TIME_PLOT(qq)-HALFWIDTH_QUERY : TIME_PLOT(qq)+HALFWIDTH_QUERY);
    
    for jj = 1:NUM_DIR
      resp_vs_dir(kk).acc(qq,jj)  = nanmean(sdf_x_dir(jj,kk).acc(idx_qq));
      resp_vs_dir(kk).fast(qq,jj) = nanmean(sdf_x_dir(jj,kk).fast(idx_qq));
    end%for:directions(dd)
    
  end%for:queries(qq)
  
  %% Compute resultant activity
  
  x_res.acc  = sum(resp_vs_dir(kk).acc.*cos(THETA_CIRC(1:NUM_DIR)), 2);
  x_res.fast = sum(resp_vs_dir(kk).fast.*cos(THETA_CIRC(1:NUM_DIR)), 2);
  y_res.acc  = sum(resp_vs_dir(kk).acc.*sin(THETA_CIRC(1:NUM_DIR)), 2);
  y_res.fast = sum(resp_vs_dir(kk).fast.*sin(THETA_CIRC(1:NUM_DIR)), 2);
  
  mag_res(kk).acc = sqrt(x_res.acc.^2 + y_res.acc.^2) / norm_factor(kk);
  mag_res(kk).fast = sqrt(x_res.fast.^2 + y_res.fast.^2) / norm_factor(kk);
  
  %% Compute target selection time (TST)
  tst(kk) = calculate_TST(mag_res(kk), THRESH_TST, MINHOLD_TST);
  
end%for:cells(kk)

%% Plotting

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
  
%   figure(); hold on
%   plot([TIME_PLOT(1),TIME_PLOT(end)], THRESH_TST*ones(1,2), 'k--')
%   plot(TIME_PLOT, mag_res(kk).acc, 'Color','r', 'LineWidth',1.25)
%   plot(tst(kk).acc*ones(1,2), [0 0.8], 'k-')
%   xlim([TIME_PLOT(1)-2, TIME_PLOT(end)-50+2]); ylim([0 1])
%   print_session_unit(gca, ninfo(kk), 'vertical')
%   ppretty(); pause(.25)
%   
%   print(['~/Dropbox/tmp/',ninfo(kk).session,'-',ninfo(kk).unit,'-tst-acc.tif'], '-dtiff')
%   pause(.25)
%   
%   figure(); hold on
%   plot([TIME_PLOT(1),TIME_PLOT(end)], THRESH_TST*ones(1,2), 'k--')
%   plot(TIME_PLOT, mag_res(kk).fast, 'Color',[0 .7 0], 'LineWidth',1.25)
%   plot(tst(kk).fast*ones(1,2), [0 0.8], 'k-')
%   xlim([TIME_PLOT(1)-2, TIME_PLOT(end)-50+2]); ylim([0 1])
%   ppretty(); pause(.25)
%   
%   print(['~/Dropbox/tmp/',ninfo(kk).session,'-',ninfo(kk).unit,'-tst-fast.tif'], '-dtiff')
%   pause(.25); close all
  
end%for:cells(kk)

if (nargout > 0)
  varargout{1} = tst;
end

end%function:plot_resultant_activity()



function [ tst ] = calculate_TST( mag_res , thresh , min_hold )
%calculate_SST Summary of this function goes here
%   Detailed explanation goes here

%use threshold and minimum hold time to get TDT
tst = struct('acc',NaN, 'fast',NaN);

idx_supra_acc = find(mag_res.acc > thresh); %points with resultant above thresh
num_supra_acc = length(idx_supra_acc);

idx_supra_fast = find(mag_res.fast > thresh);
num_supra_fast = length(idx_supra_fast);

%check the hold time -- accurate trials
for jj = 1:num_supra_acc
  if (sum(ismember((idx_supra_acc(jj):idx_supra_acc(jj)+min_hold-1), idx_supra_acc)) == min_hold)
    tst.acc = idx_supra_acc(jj);
    break
  end
end

%check the hold time -- fast trials
for jj = 1:num_supra_fast
  if (sum(ismember((idx_supra_fast(jj):idx_supra_fast(jj)+min_hold-1), idx_supra_fast)) == min_hold)
    tst.fast = idx_supra_fast(jj);
    break
  end
end

end%function:calculate_TST()
