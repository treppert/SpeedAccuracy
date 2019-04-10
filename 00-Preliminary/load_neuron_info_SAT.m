function [ ninfoSAT ] = load_neuron_info_SAT( OS )
%load_neuron_info_SAT Summary of this function goes here
%   Detailed explanation goes here

if strcmp(OS, 'Linux')
  FILE = '~/Dropbox/Speed Accuracy/SEF_SAT/Info/Unit-Info-SAT.xlsx';
elseif strcmp(OS, 'Windows')
  FILE = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Info\Unit-Info-SAT.xlsx';
end
MONKEY = {'Darwin','Euler','Quincy','Seymour'};

NUM_UNIT = [98, 42, 145, 151]; %Da, Eu, Q, S
ROW_INIT = 6; %row of first unit for each monkey

COL_UNIT_NUM = 'B';
COL_SESS_NUM = 'C';
COL_SESS = 'D';
COL_UNIT = 'E';
COL_AREA = 'F';
COL_GRID = 'G';
COL_VISGRADE = 'H';
COL_VISFIELD = 'I';
COL_MOVEGRADE = 'J';
COL_MOVEFIELD = 'K';
COL_ERRGRADE = 'L';
COL_ERRFIELD = 'M';
COL_VISTYPE = 'N';
COL_REM_ISO = 'O';

ninfoSAT = [];

for mm = 1:4
  
  idx_mm = [ROW_INIT, ROW_INIT+NUM_UNIT(mm)-1];
  
  unitNum = num2cell(uint16(xlsread(FILE, MONKEY{mm}, build_col(COL_UNIT_NUM,idx_mm))));
  sessNum = num2cell(uint16(xlsread(FILE, MONKEY{mm}, build_col(COL_SESS_NUM,idx_mm))));
  [~,sess] = xlsread(FILE, MONKEY{mm}, build_col(COL_SESS,idx_mm));
  [~,unit] = xlsread(FILE, MONKEY{mm}, build_col(COL_UNIT,idx_mm));
  [~,area] = xlsread(FILE, MONKEY{mm}, build_col(COL_AREA,idx_mm));
  [~,tRemIso] = xlsread(FILE, MONKEY{mm}, build_col(COL_REM_ISO,idx_mm));
  
  visGrade = num2cell(xlsread(FILE, MONKEY{mm}, build_col(COL_VISGRADE,idx_mm)));
  [~,visField] = xlsread(FILE, MONKEY{mm}, build_col(COL_VISFIELD,idx_mm));
  [~,visType] = xlsread(FILE, MONKEY{mm}, build_col(COL_VISTYPE,idx_mm));
  
  moveGrade = num2cell(xlsread(FILE, MONKEY{mm}, build_col(COL_MOVEGRADE,idx_mm)));
  [~,moveField] = xlsread(FILE, MONKEY{mm}, build_col(COL_MOVEFIELD,idx_mm));
  
  errGrade = num2cell(xlsread(FILE, MONKEY{mm}, build_col(COL_ERRGRADE,idx_mm)));
  [~,errField] = xlsread(FILE, MONKEY{mm}, build_col(COL_ERRFIELD,idx_mm));
  
  for cc = 1:NUM_UNIT(mm)
    
    tRemIso{cc} = str2num(tRemIso{cc});
    
    visField{cc} = str2num(visField{cc});
    if (visField{cc} == 9); visField{cc} = (1:8); end
    
    moveField{cc} = str2num(moveField{cc});
    if (moveField{cc} == 9); moveField{cc} = (1:8); end
    
    errField{cc} = str2num(errField{cc});
    if (errField{cc} == 9); errField{cc} = (1:8); end
    
    if ismember(area{cc}, {'FEF','SC'})
      %increment RF from 0-7 (Rich) to 1-8 (Thomas) convention
      visField{cc} = visField{cc} + 1;
      moveField{cc} = moveField{cc} + 1;
      
      if (visField{cc} == 9); visField{cc} = (1:8); end
      if (moveField{cc} == 9); moveField{cc} = (1:8); end
      if (errField{cc} == 9); errField{cc} = (1:8); end
      
    end
    
  end%for:unit(cc)
  
  ninfo_mm = struct('monkey',MONKEY{mm}(1), ...
    'sessNum',sessNum, 'sess',sess, ...
    'unitNum',unitNum, 'unit',unit, ...
    'area',area, 'tRemIso',tRemIso, ...
    'visGrade',visGrade, 'visField',visField, 'visType',visType, ...
    'moveGrade',moveGrade, 'moveField',moveField, ...
    'errGrade',errGrade, 'errField',errField);
  
  ninfoSAT = cat(1, ninfoSAT, ninfo_mm);
  
end%for:monkey(mm)

ninfoSAT = transpose(ninfoSAT);

end%fxn:load_neuron_info_SAT()

function [ col ] = build_col( letter , idx )
  col = [upper(letter),num2str(idx(1)),':',upper(letter),num2str(idx(2))];
end
