function [ ninfoSAT ] = load_neuron_info_SAT( OS , binfo )
%load_neuron_info_SAT Summary of this function goes here
%   Detailed explanation goes here

if strcmp(OS, 'Linux')
  FILE = '~/Dropbox/Speed Accuracy/SEF_SAT/Info/Unit-Info-SAT.xlsx';
elseif strcmp(OS, 'Windows')
  FILE = 'C:\Users\Tom\Dropbox\Speed Accuracy\SEF_SAT\Info\Unit-Info-SAT.xlsx';
end
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

ninfoSAT = [];

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
  
  for cc = 1:NUM_UNIT(mm)
    
    trRemSAT{cc} = str2num(trRemSAT{cc});
    trRemMG{cc} = str2num(trRemMG{cc});
    
    visField{cc} = str2num(visField{cc});
%     if (visField{cc} == 9); visField{cc} = (1:8); end
    
    moveField{cc} = str2num(moveField{cc});
%     if (moveField{cc} == 9); moveField{cc} = (1:8); end
    
    errField{cc} = str2num(errField{cc});
%     if (errField{cc} == 9); errField{cc} = (1:8); end
    
    if ismember(area{cc}, {'FEF','SC'})
      %increment RF from 0-7 (Rich) to 1-8 (Thomas) convention
      visField{cc} = visField{cc} + 1;
      moveField{cc} = moveField{cc} + 1;
      
%       if (visField{cc} == 9); visField{cc} = (1:8); end
%       if (moveField{cc} == 9); moveField{cc} = (1:8); end
%       if (errField{cc} == 9); errField{cc} = (1:8); end
      
    end
    
  end%for:unit(cc)
  
  ninfo_mm = struct('monkey',MONKEY{mm}(1), ...
    'sessNum',sessNum, 'sess',sess, ...
    'unitNum',unitNum, 'unit',unit, ...
    'area',area, 'trRemSAT',trRemSAT, 'trRemMG',trRemMG, ...
    'visGrade',visGrade, 'visField',visField, 'visType',visType, ...
    'moveGrade',moveGrade, 'moveField',moveField, ...
    'errGrade',errGrade, 'errField',errField, ...
    'rewGrade',rewGrade);
  
  ninfoSAT = cat(1, ninfoSAT, ninfo_mm);
  
end%for:monkey(mm)

%mark all units with unacceptable isolation quality
for cc = 1:sum(NUM_UNIT)
  ninfoSAT(cc).poorIso = poorIso(cc);
end

%label neurons by session type: more efficient or less efficient
for cc = 1:sum(NUM_UNIT)
  kk = ismember({binfo.session}, ninfoSAT(cc).sess);
  ninfoSAT(cc).taskType = binfo(kk).taskType;
end

ninfoSAT = transpose(ninfoSAT);

end%fxn:load_neuron_info_SAT()

function [ col ] = build_col( letter , idx )
  col = [upper(letter),num2str(idx(1)),':',upper(letter),num2str(idx(2))];
end
