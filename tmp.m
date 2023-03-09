%tmp.m

N_NEURON = 436;

iVis  = cellfun(@(x) logical(sum(ismember(x,'V'))), unitData.FxnType);
iMove = cellfun(@(x) logical(sum(ismember(x,'M'))), unitData.FxnType);
iCErr = cellfun(@(x) logical(sum(ismember(x,'C'))), unitData.FxnType);
iTErr = cellfun(@(x) logical(sum(ismember(x,'T'))), unitData.FxnType);

clearvars -except BehavData unitData pairData ROOTDIR*


%% March 9, 2023

% fxnType_Da = readtable('C:\Users\thoma\Dropbox\SAT-Local\Correlation-SAT-SEF.xlsx', ...
%   'Sheet','Da-Fast', 'Range','F7:F77');
% idxUnit_Da = readtable('C:\Users\thoma\Dropbox\SAT-Local\Correlation-SAT-SEF.xlsx', ...
%   'Sheet','Da-Fast', 'Range','B7:B77');
% fxnType_Eu = readtable('C:\Users\thoma\Dropbox\SAT-Local\Correlation-SAT-SEF.xlsx', ...
%   'Sheet','Eu-Fast', 'Range','F7:F40');
% idxUnit_Eu = readtable('C:\Users\thoma\Dropbox\SAT-Local\Correlation-SAT-SEF.xlsx', ...
%   'Sheet','Eu-Fast', 'Range','B7:B40');
% 
% N_Da = size(fxnType_Da,1);
% for nn = 1:N_Da
%   unitData.FxnType{idxUnit_Da.U_(nn)} = fxnType_Da.Fxn{nn};
% end
% 
% N_Eu = size(fxnType_Eu,1);
% for nn = 1:N_Eu
%   unitData.FxnType{idxUnit_Eu.U_(nn)} = fxnType_Eu.Fxn{nn};
% end


%% March 8, 2023

% N = 4368;
% 
% Condition = cell(N,1);
% Outcome = cell(N,1);
% 
% for nn = 1:N
%   if regexp(spkCorr.condition{nn}, 'Accurate')
%     Condition{nn} = 'Accurate';
%   elseif regexp(spkCorr.condition{nn}, 'Fast')
%     Condition{nn} = 'Fast';
%   end
% end
% 
% for nn = 1:N
%   if regexp(spkCorr.condition{nn}, 'Correct')
%     Outcome{nn} = 'Correct';
%   elseif regexp(spkCorr.condition{nn}, 'ErrorChoice')
%     Outcome{nn} = 'ErrorChoice';
%   elseif regexp(spkCorr.condition{nn}, 'ErrorTiming')
%     Outcome{nn} = 'ErrorTiming';
%   end
% end
