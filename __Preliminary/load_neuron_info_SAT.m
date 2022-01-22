function [ unitDataSAT ] = load_neuron_info_SAT( behavData )
%load_neuron_info_SAT Summary of this function goes here
%   Detailed explanation goes here

FILE = 'C:\Users\Thomas Reppert\Dropbox\SAT\Unit-Info-SAT.xlsx';
MONKEY = {'Darwin','Euler','Quincy','Seymour'};

NUM_UNIT = [98, 42, 145, 151]; %Da, Eu, Q, S
ROW_INIT = 6; %row of first unit for each monkey

%prepare unit ID's with unacceptable isolation quality
ID_UNIT_POOR_ISO = ...
  [8, 49, 61, 69, 71, 72, 73, 83, 90, ... %Da
  108, 116, 122, 127, 128, 129, 131, 132, 138, 140]; %Eu
poorIso = false(1,sum(NUM_UNIT));
poorIso(ID_UNIT_POOR_ISO) = true;

COL_UNIT_NUM = 'B';
COL_SESS_NUM = 'C';
COL_SESS = 'D';
COL_UNIT = 'E';
COL_AREA = 'F';
COL_GRID = 'G';
COL_VISGRADE = 'H';
COL_MOVEGRADE = 'I';
COL_ERRGRADE = 'J';
COL_REWGRADE = 'K';
COL_VISFIELD = 'L';
COL_MOVEFIELD = 'M';
COL_ERRFIELD = 'N';
COL_VISTYPE = 'O';
COL_TR_REM_SAT = 'P';
COL_TR_REM_MG = 'Q';

unitDataSAT = [];

for mm = 1:4
  
  idx_mm = [ROW_INIT, ROW_INIT+NUM_UNIT(mm)-1];
  
  unitNum = num2cell(uint16(xlsread(FILE, MONKEY{mm}, build_col(COL_UNIT_NUM,idx_mm))));
  sessNum = num2cell(uint16(xlsread(FILE, MONKEY{mm}, build_col(COL_SESS_NUM,idx_mm))));
  [~,sess] = xlsread(FILE, MONKEY{mm}, build_col(COL_SESS,idx_mm));
  [~,unit] = xlsread(FILE, MONKEY{mm}, build_col(COL_UNIT,idx_mm));
  [~,area] = xlsread(FILE, MONKEY{mm}, build_col(COL_AREA,idx_mm));
  [~,trRemSAT] = xlsread(FILE, MONKEY{mm}, build_col(COL_TR_REM_SAT,idx_mm));
  [~,trRemMG] = xlsread(FILE, MONKEY{mm}, build_col(COL_TR_REM_MG,idx_mm));
  
  visGrade = num2cell(xlsread(FILE, MONKEY{mm}, build_col(COL_VISGRADE,idx_mm)));
  [~,visField] = xlsread(FILE, MONKEY{mm}, build_col(COL_VISFIELD,idx_mm));
  [~,visType] = xlsread(FILE, MONKEY{mm}, build_col(COL_VISTYPE,idx_mm));
  
  moveGrade = num2cell(xlsread(FILE, MONKEY{mm}, build_col(COL_MOVEGRADE,idx_mm)));
  [~,moveField] = xlsread(FILE, MONKEY{mm}, build_col(COL_MOVEFIELD,idx_mm));
  
  errGrade = num2cell(xlsread(FILE, MONKEY{mm}, build_col(COL_ERRGRADE,idx_mm)));
  [~,errField] = xlsread(FILE, MONKEY{mm}, build_col(COL_ERRFIELD,idx_mm));
  
  rewGrade = num2cell(xlsread(FILE, MONKEY{mm}, build_col(COL_REWGRADE,idx_mm)));
  
  for uu = 1:NUM_UNIT(mm)
    
    trRemSAT{uu} = str2num(trRemSAT{uu});
    trRemMG{uu} = str2num(trRemMG{uu});
    
    visField{uu} = str2num(visField{uu});
    moveField{uu} = str2num(moveField{uu});
    errField{uu} = str2num(errField{uu});
    
    if ismember(area{uu}, {'FEF','SC'})
      %increment RF from 0-7 (Rich) to 1-8 (Thomas) convention
      visField{uu} = visField{uu} + 1;
      moveField{uu} = moveField{uu} + 1;
    end
    
  end%for:unit(uu)
  
  unitData_mm = struct('monkey',MONKEY{mm}(1), ...
    'sessNum',sessNum, 'sess',sess, ...
    'unitNum',unitNum, 'unit',unit, ...
    'area',area, 'trRemSAT',trRemSAT, 'trRemMG',trRemMG, ...
    'visGrade',visGrade, 'visField',visField, 'visType',visType, ...
    'moveGrade',moveGrade, 'moveField',moveField, ...
    'errGrade',errGrade, 'errField',errField, ...
    'rewGrade',rewGrade);
  
  unitDataSAT = cat(1, unitDataSAT, unitData_mm);
  
end%for:monkey(mm)

%mark all units with unacceptable isolation quality
for uu = 1:sum(NUM_UNIT)
  unitDataSAT(uu).poorIso = poorIso(uu);
end

%label neurons by session type: more efficient or less efficient
for uu = 1:sum(NUM_UNIT)
  kk = ismember(behavData.Task_Session, unitDataSAT(uu).sess);
  unitDataSAT(uu).taskType = behavData.Task_LevelDifficulty{kk};
end

unitDataSAT = transpose(unitDataSAT);

end%fxn:load_neuron_info_SAT()

function [ col ] = build_col( letter , idx )
  col = [upper(letter),num2str(idx(1)),':',upper(letter),num2str(idx(2))];
end
