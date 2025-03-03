% function [ ] = Fig2X_SingleTrialChange_Counts( behavData , unitData , spkCorr_ )
%Fig2X_SingleTrialChange_Simultaneous Summary of this function goes here
%   Detailed explanation goes here

DEBUG = false;
TLIM_COUNT = [+50,+400] + 3500;
tableSwitch = identify_condition_switch(behavData);

% pair = {[2 11], [77 85], [89 98]}; % X = FEF, Y = SC
pair = {[27 29], [93 98], [94 98], [106 111], [114 119], [117 119]}; % X = SEF, Y = SC
% pair = {[39 31], [40 35], [40 31], [39 35], [47 45], [93 89], [94 89]}; % X = SEF, Y = FEF
% pair = {[39 40], [93 94], [100 102], [100 103], [102 103], [114 117], [121 123], ...
%   [128 130], [133 134], [133 139], [134 139]}; % X = SEF, Y = SEF
% pair = {[31 35]}; % X = FEF, Y = FEF
nPair = numel(pair);

dA_X = NaN(nPair,2);  %mean single-trial modulation (A2F|F2A)
dA_Y = dA_X;          %FEF/SC

DA_X = cell(nPair,2); %single-trial data (A2F|F2A)
DA_Y = DA_X;

Quad_A2F = NaN(nPair,4);
Quad_F2A = Quad_A2F;

pval_rtest = NaN(nPair,2); % A2F|F2A

for p = 1:nPair
  uX = unitData.Index(pair{p}(1)); %X unit no.
  uY = unitData.Index(pair{p}(2)); %Y unit no.
  xArea = unitData.Area{uX};
  yArea = unitData.Area{uY};
  k = unitData.SessionIndex(uX); %Session no.
  kstr = unitData.Session{uX};
  
  %index by isolation quality
  %index by condition
  idxAcc = (behavData.Condition{k} == 1);
  idxFast = (behavData.Condition{k} == 3);
  %index by trial number
  jjA2F = tableSwitch.A2F; %trials with switch Acc to Fast
  jjF2A = tableSwitch.F2A; %trials with switch Fast to Acc
  jjA2F_pre  = jjA2F{k} - 1; %Acc->Fast pre-change
  jjA2F_post = jjA2F{k} + 0; %Acc->Fast post-change
  jjF2A_pre  = jjF2A{k} - 1;
  jjF2A_post = jjF2A{k} + 0;

  %compute spike count for all trials
  spikes_X = load_spikes_SAT(unitData.Index(uX));
  spikes_Y = load_spikes_SAT(unitData.Index(uY));
  spkCt_X = cellfun(@(x) sum((x > TLIM_COUNT(1)) & (x < TLIM_COUNT(2))), spikes_X);
  spkCt_Y = cellfun(@(x) sum((x > TLIM_COUNT(1)) & (x < TLIM_COUNT(2))), spikes_Y);

  %z-score spike counts
  spkCt_X(idxAcc | idxFast) = zscore(spkCt_X(idxAcc | idxFast));
  spkCt_Y(idxAcc | idxFast) = zscore(spkCt_Y(idxAcc | idxFast));
  
  %TODO - Fix this issue (single trial with incorrect spike count)
  spkCt_X(abs(spkCt_X) > 10) = NaN;
  spkCt_Y(abs(spkCt_Y) > 10) = NaN;

  %compute change in spike count at condition switch
  dA_X_p_A2F = spkCt_X(jjA2F_post) - spkCt_X(jjA2F_pre); nA2F = numel(jjA2F_pre);
  dA_Y_p_A2F = spkCt_Y(jjA2F_post) - spkCt_Y(jjA2F_pre);
  dA_X_p_F2A = spkCt_X(jjF2A_post) - spkCt_X(jjF2A_pre); nF2A = numel(jjF2A_pre);
  dA_Y_p_F2A = spkCt_Y(jjF2A_post) - spkCt_Y(jjF2A_pre);
  
  %COUNTS PER QUADRANT
  quadA2F = false(nA2F,4);
  jjQ1 = (dA_X_p_A2F > 0) & (dA_Y_p_A2F > 0); quadA2F(jjQ1,1) = true;
  jjQ2 = (dA_X_p_A2F < 0) & (dA_Y_p_A2F > 0); quadA2F(jjQ2,2) = true;
  jjQ3 = (dA_X_p_A2F < 0) & (dA_Y_p_A2F < 0); quadA2F(jjQ3,3) = true;
  jjQ4 = (dA_X_p_A2F > 0) & (dA_Y_p_A2F < 0); quadA2F(jjQ4,4) = true;
  quadA2F = sum(quadA2F);
  Quad_A2F(p,:) = quadA2F;
  
  quadF2A = false(nF2A,4);
  jjQ1 = (dA_X_p_F2A > 0) & (dA_Y_p_F2A > 0); quadF2A(jjQ1,1) = true;
  jjQ2 = (dA_X_p_F2A < 0) & (dA_Y_p_F2A > 0); quadF2A(jjQ2,2) = true;
  jjQ3 = (dA_X_p_F2A < 0) & (dA_Y_p_F2A < 0); quadF2A(jjQ3,3) = true;
  jjQ4 = (dA_X_p_F2A > 0) & (dA_Y_p_F2A < 0); quadF2A(jjQ4,4) = true;
  quadF2A = sum(quadF2A);
  Quad_F2A(p,:) = quadF2A;
  
  if (DEBUG)
    figure(); hold on; title([kstr,'-',xArea,'-',yArea])
    scatter(dA_X_p_A2F, dA_Y_p_A2F, 20, [0 .6 0], 'filled', 'o', 'MarkerFaceAlpha',.5)
    scatter(dA_X_p_F2A, dA_Y_p_F2A, 20, 'r', 'filled', 'o', 'MarkerFaceAlpha',.5)
    scatter(mean(dA_X_p_A2F), mean(dA_Y_p_A2F), 40, [0 .3 0], 'filled', 'o')
    scatter(mean(dA_X_p_F2A), mean(dA_Y_p_F2A), 40, [.5 0 0], 'filled', 'o')
    plot([-5 +5],[0 0], 'k--'); plot([0 0],[-5 +5], 'k--')
    xlabel([xArea,' change (z)'])
    ylabel([yArea,' change (z)'])
    ppretty([3.5,3]); set(gca, 'yminortick','off'); drawnow
    
    figure(); hold on; title([kstr,'-',xArea,'-',yArea])
    bar([quadA2F;quadF2A], 1.0)
    xticks([1,2]); xticklabels({'A2F','F2A'})
    ylabel('Trial count')
    legend({'Q1','Q2','Q3','Q4'}, 'location','north')
    ppretty([2,2]); drawnow
  end

  DA_X{p,1} = dA_X_p_A2F;
  DA_X{p,2} = dA_X_p_F2A;
  DA_Y{p,1} = dA_Y_p_A2F;
  DA_Y{p,2} = dA_Y_p_F2A;

  dA_X(p,:) = [mean(dA_X_p_A2F) , mean(dA_X_p_F2A)]; %A2F|F2A
  dA_Y(p,:) = [mean(dA_Y_p_A2F) , mean(dA_Y_p_F2A)];
  
  %compute vector angles for Rayleigh (circular) test
  theta_A2F_p = atan2(dA_Y_p_A2F,dA_X_p_A2F);
  theta_F2A_p = atan2(dA_Y_p_F2A,dA_X_p_F2A);
  pval_rtest(p,1) = circ_rtest(theta_A2F_p);
  pval_rtest(p,2) = circ_rtest(theta_F2A_p);

end % for : pair(p)

%normalize counts for each pair by total trial counts
Quad_A2F = Quad_A2F ./ sum(Quad_A2F,2);
Quad_F2A = Quad_F2A ./ sum(Quad_F2A,2);

%prepare single-trial data for scatter plot
DA_X_A2F = cell2mat(DA_X(:,1));
DA_X_F2A = cell2mat(DA_X(:,2));
DA_Y_A2F = cell2mat(DA_Y(:,1));
DA_Y_F2A = cell2mat(DA_Y(:,2));

%% Stats - chi-square categorical test
[chi2_A2F,chi2_F2A] = chi2_test(DA_X_A2F, DA_X_F2A, DA_Y_A2F, DA_Y_F2A);

%% Plotting - Scatterplot
GREEN = [0 .7 0];

figure()

subplot(1,3,1); hold on %scatterplot of means (FEF/SC vs SEF)
AXLIM = [-1.5,+1.5];
scatter(dA_X(:,1), dA_Y(:,1), 30, GREEN, 'd') %A2F
scatter(dA_X(:,2), dA_Y(:,2), 30, 'r', 'd') %F2A
plot(AXLIM,[0 0], 'k--'); plot([0 0],AXLIM, 'k--')
xlabel('SEF single-trial change (z)')
ylabel('FEF single-trial change (z)')
xlim(AXLIM); ylim(AXLIM); ytickformat('%2.1f'); xtickformat('%2.1f')

subplot(1,3,2); hold on %scatterplot of single-trial data - A2F
AXLIM = [-5,+5];
scatter(DA_X_A2F, DA_Y_A2F, 10, GREEN, 'filled', 'o', 'MarkerFaceAlpha',.4)
plot(AXLIM,[0 0], 'k--'); plot([0 0],AXLIM, 'k--')
xlim(AXLIM); ylim(AXLIM)

subplot(1,3,3); hold on %scatterplot of single-trial data - F2A
AXLIM = [-5,+5];
scatter(DA_X_F2A, DA_Y_F2A, 10,   'r', 'filled', 'o', 'MarkerFaceAlpha',.4)
plot(AXLIM,[0 0], 'k--'); plot([0 0],AXLIM, 'k--')
xlim(AXLIM); ylim(AXLIM)

ppretty([8,1.6]); drawnow


%% Plotting - Bar plot

figure(); hold on
bar((1:4), mean(Quad_A2F), 1.0, 'grouped', 'green')
errorbar((1:4), mean(Quad_A2F), std(Quad_A2F)/sqrt(nPair), 'CapSize',0, 'Color','k')
bar((6:9), mean(Quad_F2A), 1.0, 'grouped', 'red')
errorbar((6:9), mean(Quad_F2A), std(Quad_F2A)/sqrt(nPair), 'CapSize',0, 'Color','k')
ylabel('Probability')
xticks([(1:4),(6:9)]); xticklabels({'+/+','-/+','-/-','+/-','+/+','-/+','-/-','+/-'})
ppretty([3,2]); drawnow
set(gca, 'xminortick','off')


clearvars -except behavData unitData spkCorr ROOTDIR_DATA_SAT chi2_*
% end % fxn : Fig2X_SingleTrialChange_Counts()


function [ chi2_A2F , chi2_F2A ] = chi2_test(DA_X_A2F, DA_X_F2A, DA_Y_A2F, DA_Y_F2A)

%% Accurate to Fast
X_A2F = (DA_X_A2F > 0); %was modulation (+) or (-)?
Y_A2F = (DA_Y_A2F > 0);

%chi-square test
[tbl,chi2stat,pval] = crosstab(X_A2F,Y_A2F);
chi2_A2F = struct('tbl',tbl, 'chi2stat',chi2stat, 'pval',pval);


%% Fast to Accurate
X_F2A = (DA_X_F2A > 0); %was modulation (+) or (-)?
Y_F2A = (DA_Y_F2A > 0);

%chi-square test
[tbl,chi2stat,pval] = crosstab(X_F2A,Y_F2A);
chi2_F2A = struct('tbl',tbl, 'chi2stat',chi2stat, 'pval',pval);


end % util : chi2_test_SAT()
