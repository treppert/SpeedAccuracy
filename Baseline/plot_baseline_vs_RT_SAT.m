function [ varargout ] = plot_baseline_vs_RT_SAT( binfo , moves , ninfo , spikes )
%plot_baseline_vs_RT_SAT Summary of this function goes here
%   Detailed explanation goes here

NORMALIZE = true;
MIN_NUM_CELLS = 10; %for purposes of plotting across all cells

BIN_RT = (300 : 40 : 700);
% BIN_RT = (200 : 20 : 400);
RT_PLOT = BIN_RT(1:end-1) + diff(BIN_RT)/2;
NUM_BIN = length(RT_PLOT);
MIN_PER_BIN = 10; %minimum number of trials per RT bin

TIME_STIM = 3500;
TIME_BASE = ( -700 : -1 );
IDX_BASE = TIME_BASE([1,end]) + TIME_STIM;

NUM_CELLS = length(spikes);

binfo = index_timing_errors_SAT(binfo, moves);

%initializations
sp_A_Corr = NaN(NUM_CELLS,NUM_BIN);
sd_A_Corr = NaN(NUM_CELLS,NUM_BIN);

%stats
rho_A = NaN(1,NUM_CELLS);
pval_A = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  idx_A = (binfo(kk).condition == 1);
  idx_F = (binfo(kk).condition == 3);
  
  idx_corr_F = (~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold) & idx_F);
  idx_corr_A = (~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold) & idx_A);
  
  RT = moves(kk).resptime;
  
  num_sp_bline = NaN(1,binfo(kk).num_trials);
  for jj = 1:binfo(kk).num_trials
    num_sp_bline(jj) = sum((spikes(cc).SAT{jj} > IDX_BASE(1)) & (spikes(cc).SAT{jj} > IDX_BASE(2)));
  end
  
%   figure()
%   subplot(2,1,1); hold on
%   plot(RT(idx_corr_A), num_sp_bline(idx_corr_A), 'ro')
%   subplot(2,1,2); hold on
%   plot(RT(idx_corr_F), num_sp_bline(idx_corr_F), 'go')
%   ppretty('image_size',[4.8,6])
  
  %use regression to determine cells that show a postive relationship
  [rho_A(cc),pval_A(cc)] = corr(RT(idx_corr_A)', num_sp_bline(idx_corr_A)', 'type','Pearson');
  if ~((rho_A(cc) > 0) && (pval_A(cc) < .05)); continue; end
  
  %bin spike counts by RT
  for jj = 1:NUM_BIN
    idx_jj = ((RT > BIN_RT(jj)) & (RT < BIN_RT(jj+1)));
    
    if (sum(idx_jj) >= MIN_PER_BIN) %enforce min number of trials
      sp_A_Corr(cc,jj) = mean(num_sp_bline(idx_corr_A & idx_jj));
      sd_A_Corr(cc,jj) = std(num_sp_bline(idx_corr_A & idx_jj));
      
      if (NORMALIZE)
        sp_A_Corr(cc,jj) = sp_A_Corr(cc,jj) - mean(num_sp_bline(idx_corr_A | idx_corr_F));
      end
      
    end
  end%for:RT_bins(jj)
  
%   figure(); hold on
%   plot(RT_PLOT, sp_A_Corr(cc,:), 'r.-')
% %   errorbar_no_caps(RT_PLOT, sp_A_Corr(cc,:), 'err',sd_A_Corr(cc,:), 'color','r')
%   ppretty()
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = rho_A;
  if (nargout > 1)
    varargout{2} = pval_A;
  end
end

%% Plotting
sp_A_Corr(:,sum(~isnan(sp_A_Corr),1) < MIN_NUM_CELLS) = NaN;
NUM_SEM = sum(~isnan(sp_A_Corr),1);

figure(); hold on
plot([450 650], [0 0], 'k--')
% plot([250 350], [0 0], 'k--')
errorbar_no_caps(RT_PLOT, nanmean(sp_A_Corr), 'err',nanstd(sp_A_Corr)./sqrt(NUM_SEM), 'color','r')
ppretty()

pause(0.25)

figure(); hold on
plot([-.2 .3], -log(.05)*ones(1,2), '-', 'Color',[.5 .5 .5])
plot([-.2 .3], -log(.01)*ones(1,2), '-', 'Color',[.5 .5 .5])
plot([-.2 .3], -log(.001)*ones(1,2), '-', 'Color',[.5 .5 .5])
plot(rho_A, -log(pval_A), 'ko')
ppretty('image_size',[3.2,5])

end%fxn:plot_baseline_vs_RT_SAT()

