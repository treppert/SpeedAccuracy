% computeCorrelation_X_FxnClass.m
% This script computes signal and noise correlations for all pairs of
% neurons with specified functional properties (e.g., visually-responsive
% or error-signaling).
% 
% Correlation data are combined across recording sessions and organized by
% functional properties of neurons.
% 

%index recording sessions
sessTest = find(ismember(behavData.Monkey, {'D'}));
nSess = numel(sessTest);

%index unit data
idxArea = ismember(unitData.Area, {'SEF','FEF','SC'});
% idxFxn  = ismember(unitData.VR, +1) | ismember(unitData.MV, +1) | ismember(unitData.PS, +1) | ismember(unitData.REW, +1);

%% Initialize pairData output table
nPair = 0;

%initialize table fields
Monkey = [];
Session = [];
SID = [];
XUnit = [];   YUnit = [];
XUID = [];    YUID = [];
XArea = [];   YArea = [];
XHemi = [];   YHemi = [];
X_VR = [];    Y_VR = [];
X_MV = [];    Y_MV = [];
X_PS = [];    Y_PS = [];
X_REW = [];   Y_REW = [];

for kk = 1:nSess
  idxSess = ismember(unitData.SessionID, sessTest(kk));
  unitSess = unitData(idxSess & idxArea, :);

  %compute number of pairs for this session
  nUnit = sum(idxSess & idxArea);
  if (nUnit < 2); continue; end
  nPair_kk = nUnit*(nUnit-1)/2;
  nPair = nPair + nPair_kk;

  %identify individual pairs
  XUnit_kk = [];  YUnit_kk = [];
  XUID_kk = [];   YUID_kk = [];
  XArea_kk = [];  YArea_kk = [];
  XHemi_kk = [];  YHemi_kk = [];
  X_VR_kk = [];   Y_VR_kk = [];
  X_MV_kk = [];   Y_MV_kk = [];
  X_PS_kk = [];   Y_PS_kk = [];
  X_REW_kk = [];  Y_REW_kk = [];

  iPair = 0;
  for xx = 1:nUnit-1
    for yy = xx+1:nUnit
      iPair = iPair + 1;
  
      XUnit_kk = cat(1, XUnit_kk, unitSess.Unit(xx));
      YUnit_kk = cat(1, YUnit_kk, unitSess.Unit(yy));
      XUID_kk = cat(1, XUID_kk, unitSess.UnitID(xx));
      YUID_kk = cat(1, YUID_kk, unitSess.UnitID(yy));

      XArea_kk = cat(1, XArea_kk, unitSess.Area(xx));
      YArea_kk = cat(1, YArea_kk, unitSess.Area(yy));
      XHemi_kk = cat(1, XHemi_kk, unitSess.Hemi(xx));
      YHemi_kk = cat(1, YHemi_kk, unitSess.Hemi(yy));
      
      X_VR_kk = cat(1, X_VR_kk, unitSess.VR(xx));
      Y_VR_kk = cat(1, Y_VR_kk, unitSess.VR(yy));
      X_MV_kk = cat(1, X_MV_kk, unitSess.MV(xx));
      Y_MV_kk = cat(1, Y_MV_kk, unitSess.MV(yy));
      X_PS_kk = cat(1, X_PS_kk, unitSess.PS(xx));
      Y_PS_kk = cat(1, Y_PS_kk, unitSess.PS(yy));
      X_REW_kk = cat(1, X_REW_kk, unitSess.REW(xx));
      Y_REW_kk = cat(1, Y_REW_kk, unitSess.REW(yy));
      
    end % for : unit(yy)
  end % for : unit(xx)

  Monkey  = cat(1, Monkey, repelem(unitSess.Monkey(1), nPair_kk,1));
  Session = cat(1, Session, repelem(unitSess.Session(1), nPair_kk,1));
  SID     = cat(1, SID, repelem(unitSess.SessionID(1), nPair_kk,1));

  XUnit   = cat(1, XUnit, XUnit_kk);
  YUnit   = cat(1, YUnit, YUnit_kk);
  XUID    = cat(1, XUID, XUID_kk);
  YUID    = cat(1, YUID, YUID_kk);
  XArea   = cat(1, XArea, XArea_kk);
  YArea   = cat(1, YArea, YArea_kk);
  XHemi   = cat(1, XHemi, XHemi_kk);
  YHemi   = cat(1, YHemi, YHemi_kk);

  X_VR    = cat(1, X_VR, X_VR_kk);
  Y_VR    = cat(1, Y_VR, Y_VR_kk);
  X_MV    = cat(1, X_MV, X_MV_kk);
  Y_MV    = cat(1, Y_MV, Y_MV_kk);
  X_PS    = cat(1, X_PS, X_PS_kk);
  Y_PS    = cat(1, Y_PS, Y_PS_kk);
  X_REW   = cat(1, X_REW, X_REW_kk);
  Y_REW   = cat(1, Y_REW, Y_REW_kk);

end % for : session (kk)

pairData = table(Monkey, Session, SID, XUnit, YUnit, XUID, YUID, XArea, YArea, ...
  X_VR, Y_VR, X_MV, Y_MV, X_PS, Y_PS, X_REW, Y_REW);

%% Initialize noise correlation values for pairData
epoch = {'BL','VR','PS','PR'};
nEpoch = 4;
nDir = 8;

%initialize noise correlations
rAC  = NaN(nPair,nEpoch); %noise corr Accurate Correct
rAET = rAC; %Accurate error timing
rFC  = rAC; %Fast correct
rFEC = rAC; %Fast error choice

%initialize signal correlations
sigAC  = NaN(nPair,1);
sigAET = sigAC;
sigFC  = sigAC;
sigFEC = sigAC;

%% Loop over pairs and compute noise correlations
for pp = 1:nPair
  fprintf('Pair %d of %d ...\n', pp,nPair)

  kk = pairData.SID(pp);
  uX = pairData.XUnit(pp);
  uY = pairData.YUnit(pp);

  %compute single-trial spike counts
  [~,~,scX_Corr] = computeSpikeCount_Search(unitData(uX,:), behavData(kk,:), 'Outcome','Correct');
  [~,~,scY_Corr] = computeSpikeCount_Search(unitData(uY,:), behavData(kk,:), 'Outcome','Correct');
  [~,~,scX_ErrC] = computeSpikeCount_Search(unitData(uX,:), behavData(kk,:), 'Outcome','ErrChoice');
  [~,~,scY_ErrC] = computeSpikeCount_Search(unitData(uY,:), behavData(kk,:), 'Outcome','ErrChoice');
  [~,~,scX_ErrT] = computeSpikeCount_Search(unitData(uX,:), behavData(kk,:), 'Outcome','ErrTime');
  [~,~,scY_ErrT] = computeSpikeCount_Search(unitData(uY,:), behavData(kk,:), 'Outcome','ErrTime');


  %compute mean spike count for each stimulus direction
  CONDITION = {'Acc','Fast'};
  INDEX_VR = 2; %index for visual response epoch
  for cc = 1:2
    scmuX_Corr.(CONDITION{cc}) = cellfun(  @(x) mean(x(:,INDEX_VR),1,"omitnan") , scX_Corr.(CONDITION{cc}) );
    scmuY_Corr.(CONDITION{cc}) = cellfun(  @(x) mean(x(:,INDEX_VR),1,"omitnan") , scY_Corr.(CONDITION{cc}) );
    scmuX_ErrC.(CONDITION{cc}) = cellfun(  @(x) mean(x(:,INDEX_VR),1,"omitnan") , scX_ErrC.(CONDITION{cc}) );
    scmuY_ErrC.(CONDITION{cc}) = cellfun(  @(x) mean(x(:,INDEX_VR),1,"omitnan") , scY_ErrC.(CONDITION{cc}) );
    scmuX_ErrT.(CONDITION{cc}) = cellfun(  @(x) mean(x(:,INDEX_VR),1,"omitnan") , scX_ErrT.(CONDITION{cc}) );
    scmuY_ErrT.(CONDITION{cc}) = cellfun(  @(x) mean(x(:,INDEX_VR),1,"omitnan") , scY_ErrT.(CONDITION{cc}) );
  end

  %compute signal correlation across stimulus directions
  tmpAC  = corr([scmuX_Corr.Acc  scmuY_Corr.Acc],  "type","Pearson", "Rows","pairwise");
  tmpAET = corr([scmuX_ErrT.Acc  scmuY_ErrT.Acc],  "type","Pearson", "Rows","pairwise");
  tmpFC  = corr([scmuX_Corr.Fast scmuY_Corr.Fast], "type","Pearson", "Rows","pairwise");
  tmpFEC = corr([scmuX_ErrC.Fast scmuY_ErrC.Fast], "type","Pearson", "Rows","pairwise");
  sigAC(pp)  = tmpAC(1,2);
  sigAET(pp) = tmpAET(1,2);
  sigFC(pp)  = tmpFC(1,2);
  sigFEC(pp) = tmpFEC(1,2);

  % %subtract direction-specific mean activity (i.e., the signal)
  % CONDITION = {'Acc','Fast'};
  % for cc = 1:2
  %   scX_Corr.(CONDITION{cc}) = cellfun(  @(x) x - mean(x,1,"omitnan") , scX_Corr.(CONDITION{cc}) , "UniformOutput",false );
  %   scY_Corr.(CONDITION{cc}) = cellfun(  @(x) x - mean(x,1,"omitnan") , scY_Corr.(CONDITION{cc}) , "UniformOutput",false );
  %   scX_ErrC.(CONDITION{cc}) = cellfun(  @(x) x - mean(x,1,"omitnan") , scX_ErrC.(CONDITION{cc}) , "UniformOutput",false );
  %   scY_ErrC.(CONDITION{cc}) = cellfun(  @(x) x - mean(x,1,"omitnan") , scY_ErrC.(CONDITION{cc}) , "UniformOutput",false );
  %   scX_ErrT.(CONDITION{cc}) = cellfun(  @(x) x - mean(x,1,"omitnan") , scX_ErrT.(CONDITION{cc}) , "UniformOutput",false );
  %   scY_ErrT.(CONDITION{cc}) = cellfun(  @(x) x - mean(x,1,"omitnan") , scY_ErrT.(CONDITION{cc}) , "UniformOutput",false );
  % end
  % 
  % %organize single-trial counts by direction and epoch
  % sc_AC  = cell(nDir,nEpoch); %Accurate correct
  % sc_FC  = sc_AC;             %Fast correct
  % sc_AET = sc_AC;             %Accurate error timing
  % sc_FEC = sc_AC;             %Fast error choice
  % for dd = 1:nDir
  %   for ep = 1:nEpoch
  %     sc_AC{dd,ep} = [ scX_Corr.Acc{dd}(:,ep)  , scY_Corr.Acc{dd}(:,ep)  ];
  %     sc_FC{dd,ep} = [ scX_Corr.Fast{dd}(:,ep) , scY_Corr.Fast{dd}(:,ep) ];
  %     sc_AET{dd,ep} = [ scX_ErrT.Acc{dd}(:,ep)  , scY_ErrT.Acc{dd}(:,ep)  ];
  %     sc_FEC{dd,ep} = [ scX_ErrC.Fast{dd}(:,ep) , scY_ErrC.Fast{dd}(:,ep) ];
  %   end
  % end
  % 
  % %compute noise correlation X direction X epoch
  % %use the "pairwise" option to skip over trials with poor isolation 
  % rAC_X_Dir = cellfun(@(x) corr(x, "type","Pearson", "Rows","pairwise"), sc_AC, "UniformOutput",false);
  % rFC_X_Dir = cellfun(@(x) corr(x, "type","Pearson", "Rows","pairwise"), sc_FC, "UniformOutput",false);
  % rAET_X_Dir = cellfun(@(x) corr(x, "type","Pearson", "Rows","pairwise"), sc_AET, "UniformOutput",false);
  % rFEC_X_Dir = cellfun(@(x) corr(x, "type","Pearson", "Rows","pairwise"), sc_FEC, "UniformOutput",false);
  % 
  % rAC_X_Dir = cellfun(@(x) x(1,2), rAC_X_Dir);
  % rFC_X_Dir = cellfun(@(x) x(1,2), rFC_X_Dir);
  % rAET_X_Dir = cellfun(@(x) x(1,2), rAET_X_Dir);
  % rFEC_X_Dir = cellfun(@(x) x(1,2), rFEC_X_Dir);
  % 
  % %compute mean correlation across directions
  % rAC(pp,:)   = mean(rAC_X_Dir,1, "omitnan");
  % rFC(pp,:)   = mean(rFC_X_Dir,1, "omitnan");
  % rAET(pp,:)  = mean(rAET_X_Dir,1, "omitnan");
  % rFEC(pp,:)  = mean(rFEC_X_Dir,1, "omitnan");

end % for : pair (pp)

%% Save correlation values in pairData
%noise correlations
pairData.rAC  = rAC;
pairData.rAET = rAET;
pairData.rFC  = rFC;
pairData.rFEC = rFEC;

%signal correlations
pairData.sigAC  = sigAC;
pairData.sigAET = sigAET;
pairData.sigFC  = sigFC;
pairData.sigFEC = sigFEC;

clearvars -except ROOTDIR* behavData* unitData* pairData*
