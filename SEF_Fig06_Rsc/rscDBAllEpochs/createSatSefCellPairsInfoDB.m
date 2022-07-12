function [ pairInfoDB , pairSummary ] = createSatSefCellPairsInfoDB( unitData )
% 
% Needs 'dataNeurophys_SAT.mat' created by Thomas(10/29/2019)
%       and '[monk]_SAT_colorRecode.xlsx' that are color recoded versions
%       of Rich's SAT summary excel files
% 
% Criteria for Pairs:
%      1. There has to be atleast 2 units in the session
%      2. The data for all units and their criteria is in file
%      'dataNeurophys_SAT.mat'  
% 
% After running this script, 
%       run createTrialTypesEventTimesDB 
% see also: CREATESATSEFTRIALTYPESEVENTTIMESDB, PARSESATEXCEL
%

datasetDir = 'C:\Users\thoma\Dropbox\Speed Accuracy\Data';
matAndPlxFiles = fullfile(datasetDir,'SessionFiles_SAT.mat'); %translated and original datafiles

%output files
pairInfoDBFile = fullfile(datasetDir,'PAIR_CellInfoDB.mat');
pairSummaryFile = fullfile(datasetDir,'PAIR_Summary.mat');
pairSummaryFileCsv = fullfile(datasetDir,'PAIR_Summary.csv');

%% Add matlab datafile and plx datafile  to the info table
sessMatPlxFiles = load(matAndPlxFiles);
sessMatPlxFiles = sessMatPlxFiles.sessionFiles;

%% Specify the units used for database
pairSummaryTbl = table();
pairSummaryTbl.sess = unique(unitData.Session);
pairSummaryTbl.nUnits = cell2mat(cellfun(@(x) sum(contains(unitData.Session,x)), ...
  pairSummaryTbl.sess, 'UniformOutput',false));

temp = innerjoin(sessMatPlxFiles,pairSummaryTbl);
pairSummaryTbl.matDatafile = temp.matDatafile;
pairSummaryTbl.plxDatafile = temp.plxDatafile;

cellsBySession = arrayfun(@(x) find(contains(unitData.Session,x)), pairSummaryTbl.sess, 'UniformOutput',false);
varNames = unitData.Properties.VariableNames;
nextPairId = 0;
JpsthPairCellInfoDB = table();

%% Ensure the following is true for area1 vs area2

% cross area pairs: always have SEF on x-axis
% pairXYarea = { {'SEF' 'SEF'}, {'SEF' 'FEF'}, {'SEF' 'SC'} };
pairXYarea = { {'SEF' 'FEF'}, {'SEF' 'SC'} };
pairXYarea = cellfun(@(x) [x{:}], pairXYarea, 'UniformOutput',false); %concatenated strings
          
for kk = 1:numel(cellsBySession)

    res = unitData(cellsBySession{kk},:);
    session = res.Session{1}; 
    fprintf('Processing session [%s]\n',session);
    tIdx = contains(pairSummaryTbl.sess,session);

    if (size(res,1) > 1) % we have more than 1 unit
        result.CellInfoTable = unitData(cellsBySession{kk},:);
        matDatafile = pairSummaryTbl.matDatafile{tIdx};
        plxDatafile = pairSummaryTbl.plxDatafile{tIdx};        
        
        pairRowIds = sortrows(combnk(1: size(result.CellInfoTable,1), 2),[1 2]);
        nPairs = size(pairRowIds,1);
        pairs = table();
        pairs.Pair_UID = cellstr(num2str(((1:nPairs)+ nextPairId)','PAIR_%04d'));
        
        pairSummaryTbl.nSEFUnits(tIdx) = size(res(strcmp(res.Area,'SEF'),1),1);
        pairSummaryTbl.nFEFUnits(tIdx) = size(res(strcmp(res.Area,'FEF'),1),1);
        pairSummaryTbl.nSCUnits(tIdx) = size(res(strcmp(res.Area,'SC'),1),1);
        pairSummaryTbl.nCellsForJpsth(tIdx) = size(result.CellInfoTable,1);
        pairSummaryTbl.nPairsJpsth(tIdx) = size(pairs,1);
               
        % swap order of areas if necessary
        pairRowIds(:,3) = arrayfun(@(x) ...
            sum(strcmp(pairXYarea,[result.CellInfoTable.Area{pairRowIds(x,:)}]))== 0, 1:nPairs)';
        pairRowIds(:,4:5) = pairRowIds(:,1:2);
        swapCols = find(pairRowIds(:,3));
        for zz = 1:numel(swapCols)
            pairRowIds(swapCols(zz),1:2) = fliplr(pairRowIds(swapCols(zz),1:2));
        end

        for vv = 1:numel(varNames)
          cName = varNames{vv};
          pairs.(['X_' cName]) = result.CellInfoTable.(cName)(pairRowIds(:,1));
          pairs.(['Y_' cName]) = result.CellInfoTable.(cName)(pairRowIds(:,2));
          if strcmp(cName,'Grade_Err')
             pairs.('X_isErrGrade') = abs(pairs.(['X_' cName]))>=2;
             pairs.('Y_isErrGrade') = abs(pairs.(['Y_' cName]))>=2;
          end
          if strcmp(cName,'Grade_TErr')
             pairs.('X_isRewGrade') = abs(pairs.(['X_' cName]))>=2;
             pairs.('Y_isRewGrade') = abs(pairs.(['Y_' cName]))>=2;
          end
          
        end

        pairs.matDatafile = repmat({matDatafile},nPairs,1);
        pairs.plxDatafile = repmat({plxDatafile},nPairs,1);

        JpsthPairCellInfoDB = [JpsthPairCellInfoDB; pairs];
        
        pairSummaryTbl.nSEF_SEF(tIdx) = fx_nArea1Area2Pairs(pairs,'SEF','SEF');
        pairSummaryTbl.nSEF_FEF(tIdx) = fx_nArea1Area2Pairs(pairs,'SEF','FEF');
        pairSummaryTbl.nSEF_SC(tIdx) = fx_nArea1Area2Pairs(pairs,'SEF','SC');

        nextPairId = nextPairId + nPairs;

    else % we don't have more than 1 unit
      fprintf(' ...  no pairs\n')
      pairSummaryTbl.nSEFUnits(tIdx) = size(res(strcmp(res.Area,'SEF'),1),1);
      pairSummaryTbl.nFEFUnits(tIdx) = size(res(strcmp(res.Area,'FEF'),1),1);
      pairSummaryTbl.nSCUnits(tIdx) = size(res(strcmp(res.Area,'SC'),1),1);
      pairSummaryTbl.nCellsForJpsth(tIdx) = 0;
      pairSummaryTbl.nPairsJpsth(tIdx) = 0;
      pairSummaryTbl.nSEF_SEF(tIdx) = 0;
      pairSummaryTbl.nSEF_FEF(tIdx) = 0;
      pairSummaryTbl.nSEF_SC(tIdx) = 0;
      continue

    end % if we have enough units

    result.PairInfoTable = pairs;

end % for : cell by session (s)

%% Save output files
pairInfoDB = JpsthPairCellInfoDB;
pairSummary= pairSummaryTbl;
% save(pairInfoDBFile,'pairInfoDB');
% save(pairSummaryFile, 'pairSummary');
writetable(pairSummary,pairSummaryFileCsv);

end % fxn : createSatSefCellPairsInfoDB()

%% Sub functions
function [nPairs] = fx_nArea1Area2Pairs(pairs,xArea,yArea)
  nPairs = sum(ismember(pairs.X_Area,xArea) & ismember(pairs.Y_Area,yArea));
end
