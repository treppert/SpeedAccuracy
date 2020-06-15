function [ ] = computeRandomShuffle_EdgeCount( edgeCount )
%computeRandomShuffle_EdgeCount Summary of this function goes here
%   This function takes as input SEFspikecorrelationwithFEFSC7June2020.mat
% 

edgeCount_mat = table2array(edgeCount(:,2:end));

NUM_ITER = 1000;
NUM_EDGE_TYPE = 6; %SEF-FEF > 0, etc.
NUM_CONDITION = 6; %Fast_Correct, Accurate_Correct, etc.

%initialize matrix of average counts per condition
edgeCount_shuffle_pos = NaN(NUM_ITER,NUM_CONDITION);
edgeCount_shuffle_neg = NaN(NUM_ITER,NUM_CONDITION);

for nn = 1:NUM_ITER
  
  %initialize count matrix for this iter
  edgeCount_nn = NaN(NUM_EDGE_TYPE,NUM_CONDITION);
  
  for ii = 1:6 %number of rows / connection types
    
    edgeCount_nn(ii,:) = edgeCount_mat(ii,randperm(NUM_CONDITION));
    
  end% for : row (ii)
  
  %average across edge types, separately for +ive and -ive correlations
  edgeCount_shuffle_pos(nn,:) = mean(edgeCount_nn([1,3,5],:)); %+ive
  edgeCount_shuffle_neg(nn,:) = mean(edgeCount_nn([2,4,6],:)); %-ive
  
end % for : shuffle iteration (nn)

%compute the mean and s.d. of edge counts resulting from shuffling
mu_shuffle_pos = mean(edgeCount_shuffle_pos);
% sd_shuffle_pos = std(edgeCount_shuffle_pos);
sd_shuffle_pos = diff(quantile(edgeCount_shuffle_pos, [.05 .95], 1));
mu_shuffle_neg = mean(edgeCount_shuffle_neg);
% sd_shuffle_neg = std(edgeCount_shuffle_neg);
sd_shuffle_neg = diff(quantile(edgeCount_shuffle_neg, [.05 .95], 1));

%compute the average MEASURED number of edges
edgeCount_pos = mean(edgeCount_mat([1,3,5],:)); %+ive corr.
edgeCount_neg = mean(edgeCount_mat([2,4,6],:)); %-ive corr.

%% Plotting
figure()

subplot(2,1,1); hold on %+ive correlation
%plot shuffled counts
errorbar((1:3), mu_shuffle_pos(1:3), sd_shuffle_pos(1:3), '-', 'CapSize',0, 'Color',[0 .7 0])
errorbar((4:6), mu_shuffle_pos(4:6), sd_shuffle_pos(4:6), '-', 'CapSize',0, 'Color','r')
%plot measured counts
plot(1:3, edgeCount_pos(1:3), '.-', 'Color',[0 .7 0], 'MarkerSize',20)
plot(4:6, edgeCount_pos(4:6), '.-', 'Color','r', 'MarkerSize',20)
xlim([0 7]); xticklabels([])

subplot(2,1,2); hold on %-ive correlation
errorbar((1:3), mu_shuffle_neg(1:3), sd_shuffle_neg(1:3), '-', 'CapSize',0, 'Color',[0 .7 0])
errorbar((4:6), mu_shuffle_neg(4:6), sd_shuffle_neg(4:6), '-', 'CapSize',0, 'Color','r')
plot(1:3, edgeCount_neg(1:3), '.:', 'Color',[0 .7 0], 'MarkerSize',20)
plot(4:6, edgeCount_neg(4:6), '.:', 'Color','r', 'MarkerSize',20)
xlim([0 7]); xticklabels([])

ppretty([4,6.4], 'XMinorTick','off', 'YMinorTick','off')

end % fxn :: computeRandomShuffle_EdgeCount()

