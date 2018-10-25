function [] = plot_trajec_ppsacc_SAT( info , movesAll )
%plot_trajec_ppsacc_SAT Summary of this function goes here
%   Detailed explanation goes here

DEBUG = false;
NUM_TRIALS = 50;
NUM_SESSION = 3;%length(info);

X_ppsacc =[];
Y_ppsacc = [];

for kk = 3:NUM_SESSION
  
  TGT_ECCEN_kk = unique(info(kk).tgt_eccen);
  if (length(TGT_ECCEN_kk) > 1)
    error('More than one target eccentricity for session %d', kk)
  end
  
%   tgt_angle_kk = convert_tgt_octant_to_angle(info(kk).tgt_octant);
  
  trials_kk = randsample(info(kk).num_trials, NUM_TRIALS);
  
  for jj = 1:info(kk).num_trials
    
    %make sure this is a trial from our subset
    if ~ismember(jj, trials_kk); continue; end
    
    %make sure we have a post-primary saccade
    idx_jj = find(movesAll(kk).trial == jj);
    if (length(idx_jj) < 2); continue; end
    
    %remove clipped saccades
    if (movesAll(kk).clipped(idx_jj(2))); continue; end
    
    %determine location of singleton relative to absolute right
    th_tgt = convert_tgt_octant_to_angle(info(kk).tgt_octant(jj));
    
    %prepare for counterclockwise rotation
    th_tgt = 2*pi - th_tgt;
    
    %rotate post-primary saccade trajectory according to singleton loc.
    x_ppsacc_jj = cos(th_tgt) * movesAll(kk).zz_x(:,idx_jj(2))' - sin(th_tgt) * movesAll(kk).zz_y(:,idx_jj(2))';
    y_ppsacc_jj = sin(th_tgt) * movesAll(kk).zz_x(:,idx_jj(2))' + cos(th_tgt) * movesAll(kk).zz_y(:,idx_jj(2))';
    
    %get location of target as reference
%     x_tgt = TGT_ECCEN_kk * cos(tgt_angle_kk(jj));
%     y_tgt = TGT_ECCEN_kk * sin(tgt_angle_kk(jj));
    
    %save trajectory relative to target location
%     x_ppsacc_jj = movesAll(kk).zz_x(:,idx_jj(2))' - x_tgt;
%     y_ppsacc_jj = movesAll(kk).zz_y(:,idx_jj(2))' - y_tgt;
    
    X_ppsacc = cat(1, X_ppsacc, x_ppsacc_jj);
    Y_ppsacc = cat(1, Y_ppsacc, y_ppsacc_jj);
    
    if (DEBUG)
      figure(44)
      plot(movesAll(kk).zz_x(:,idx_jj(2)),  movesAll(kk).zz_y(:,idx_jj(2)), '.', 'Color','b'); hold on
      plot(x_ppsacc_jj, y_ppsacc_jj, '.', 'Color',[.2 .2 .2]); hold off
      axis equal
      ppretty()
      pause(1.0)
    end
    
  end%for:trial(jj)
  
end%for:session(kk)

% figure()
% plot(X_ppsacc, Y_ppsacc, '.', 'Color',[.2 .2 .2])
% xlim([-12 12]); ylim([-12 12]); axis square
% ppretty()

th_ppsacc = atan2(Y_ppsacc,X_ppsacc);
r_ppsacc = sqrt(X_ppsacc.^2 + Y_ppsacc.^2);
figure(); polaraxes()
polarplot(th_ppsacc, r_ppsacc, '.', 'Color',[.2 .2 .2]);
thetaticklabels([])
ppretty()

end%fxn:plot_trajec_ppsacc_SAT()

