%explore_TaskParams_SAT.m

if (true)
MONKEY = 'Euler';
ROOT_DIR = ['T:\data\', MONKEY, '\SAT\Matlab\'];

[sessions,~] = identify_sessions_SAT(ROOT_DIR, MONKEY, 'SEARCH');
sessions = {sessions.SAT.name};
NUM_SESS = length(sessions);
end

tBell_Acc = [];
tBell_Fast = [];

for kk = 1:NUM_SESS
  
  fname_kk = [ROOT_DIR, '\', sessions{kk}(1:16), 'SEARCH.mat'];
  load(fname_kk, 'BellOn_','JuiceOn_','SAT_','Errors_')
  
  idxAcc = (SAT_(:,2) == 1)';
  idxFast = (SAT_(:,2) == 3)';
  
  idxErr_NoSacc = (Errors_(:,2) == 1)';
  idxErr_Hold = (Errors_(:,4) == 1)';
  idxErr_Chc = (Errors_(:,5) == 1)';
  idxErr_Time = ((Errors_(:,6) == 1) | (Errors_(:,7) == 1))';
  idxCorr = ~(idxErr_NoSacc | idxErr_Hold | idxErr_Chc | idxErr_Time);
  
  idxAcc = (idxAcc & idxCorr);
  idxFast = (idxFast & idxCorr);
  
  tBell_Acc = cat(2, tBell_Acc, JuiceOn_(idxAcc)' - BellOn_(idxAcc)');
  tBell_Fast = cat(2, tBell_Fast, JuiceOn_(idxFast)' - BellOn_(idxFast)');
  
  tBell_Acc(isnan(tBell_Acc)) = [];
  tBell_Fast(isnan(tBell_Fast)) = [];
  
end % for : session (kk)

figure(); hold on
histogram(tBell_Acc, 'FaceColor','r', 'BinWidth',1)
histogram(tBell_Fast, 'FaceColor','g', 'BinWidth',1)
xlabel('t_{Reward} - t_{Tone} (ms)')
ylabel('Frequency')
title('Eu - Correct')
box off
