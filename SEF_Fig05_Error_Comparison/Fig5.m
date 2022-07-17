%% Fig5.m -- Figure 5 header file

%Figure 5 - Spike density functions
% UNIT_PLOT = [38, 97, 133];
% for uu = 1:3
%   figure()
%   Fig5_SDF_ErrChoice_Fast(behavData, unitData, 'unitID',UNIT_PLOT(uu)); drawnow
%   Fig5_SDF_ErrTime_Accurate(behavData, unitData, 'unitID',UNIT_PLOT(uu)); drawnow
%   ppretty([10,1.4])
% end

%Figure S5A - Comparison of error signal magnitude
MONKEY = {'D','E'};
AREA = {'SEF'};
idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxCE = ismember(unitData.Grade_Err, [-1,+1]); %signals choice error
idxTE = ismember(unitData.Grade_TErr, [-1,+1]); % signals timing error

unitCE = unitData(idxArea & idxMonkey & idxCE,:);
unitTE = unitData(idxArea & idxMonkey & idxTE,:);

% A_CE = compute_Signal_CE(unitCE);
% A_TE = compute_Signal_TE(unitTE, behavData);

figure()
subplot(1,2,1); hold on
BINWIDTH = 0.05;
histogram(A_TE, 'FaceColor','r', 'BinWidth',BINWIDTH, 'Normalization','probability')
histogram(A_CE, 'FaceColor',[0 .7 0], 'BinWidth',BINWIDTH, 'Normalization','probability')
set(gca, 'YMinorTick','off'); ytickformat('%3.2f')
xlabel('Error signal magnitude')
ylabel('Probability')
subplot(1,2,2); hold on
muCE = mean(A_CE);  seCE = std(A_CE)/sqrt(size(unitCE,1));
muTE = mean(A_TE);  seTE = std(A_TE)/sqrt(size(unitTE,1));
bar(2, muCE, 'FaceColor',[0 .7 0]); errorbar(2, muCE, seCE, 'Color','k', 'Capsize',0, 'LineWidth',1.2)
bar(1, muTE, 'FaceColor','r');      errorbar(1, muTE, seTE, 'Color','k', 'CapSize',0, 'LineWidth',1.2)
xlim([-2 5]); xticks([1,2]); xticklabels({'TE','CE'}); ytickformat('%3.2f')
ylabel('Error signal magnitude')
ppretty([5,2]); set(gca, 'XMinorTick','off')

%Figure S5B - Distribution of error signaling
idxBoth   = idxArea & idxMonkey & idxCE &  idxTE; nBoth = sum(idxBoth);       %signals both types of error
idxCEOnly = idxArea & idxMonkey & idxCE & ~idxTE; nCEOnly = sum(idxCEOnly);   %signals choice errors only
idxTEOnly = idxArea & idxMonkey & idxTE & ~idxCE; nTEOnly = sum(idxTEOnly);   %signals timing errors only
nAll = sum([nBoth nCEOnly nTEOnly]);

binLim = cumsum([0, nTEOnly, nCEOnly, nBoth]') / nAll;
figure(); polaraxes
polarhistogram(linspace(0,2*pi,36), 'BinEdges',2*pi*binLim, 'FaceColor','k')
thetaticks([]); rticks([]); ppretty([2,2])

clear idx* UNIT_PLOT

function [ A_CE ] = compute_Signal_CE( unitCE )

NUM_UNIT = size(unitCE,1);
A_CE = NaN(NUM_UNIT,1);

for uu = 1:NUM_UNIT
  %time limits for error signal re. response
  tLim_uu = unitCE.SignalCE_Time_P(uu,[1,2]); %Fast condition
  tLim_uu = tLim_uu + 500; %take into account offset in SDF
  
  %SDF on error and correct trials
  sdfCorr = unitCE.sdfFC_CE{uu}(:,2);
  sdfErr  = unitCE.sdfFE_CE{uu}(:,2);

  %compute error signal magnitude
  A_CE(uu) = calc_ErrorSignalMag_SAT(sdfCorr, sdfErr, 'limTest',tLim_uu);
end % for : unit(uu)

%reverse sign for error-suppressed neurons
idxCENegative = (unitCE.Grade_Err == -1);
A_CE(idxCENegative,:) = -A_CE(idxCENegative,:);

end % fxn : compute_Signal_CE

function [ A_TE ] = compute_Signal_TE( unitTE , behavData )

NUM_UNIT = size(unitTE,1);
A_TE = NaN(NUM_UNIT,1); %initialize

[sdfTE,~] = compute_SDF_ErrTime(unitTE, behavData, 'nBin_dRT',1, 'minISI',1000);

for uu = 1:NUM_UNIT
  %start and finish of timing error signal
  tLim_uu = unitTE.SignalTE_Time(uu,:);
  tLim_uu = tLim_uu - sdfTE.Time(1,3); %take into account offset in SDF
  
  %SDF on error and correct trials
  sdfCorr = sdfTE.Corr(uu).Acc(:,3);
  sdfErr = sdfTE.Err(uu).Acc(:,3);

  %compute error signal magnitude
  A_TE(uu) = calc_ErrorSignalMag_SAT(sdfCorr, sdfErr, 'limTest',tLim_uu);
end % for : unit(uu)

%reverse sign for error-suppressed neurons
idxTENegative = (unitTE.Grade_TErr == -1);
A_TE(idxTENegative,:) = -A_TE(idxTENegative,:);

end % fxn : compute_Signal_TE
