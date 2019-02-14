function [ ninfoSAT ] = load_neuron_info_SAT( )
%load_neuron_info_SAT Summary of this function goes here
%   Detailed explanation goes here


FILE = '~/Dropbox/Speed Accuracy/SEF_SAT/Info/Unit-Info-SAT.xlsx';
MONKEY = {'Darwin','Euler','Quincy','Seymour'};

NUM_UNIT = [98, 42, 160, 158]; %Da, Eu, Q, S
ROW_INIT = 6; %row of first unit for each monkey

COL_AREA_DE = 'F';

COL_UNIT_NUM = 'B';
COL_SESS_NUM = 'C';
COL_SESS = 'D';
COL_UNIT = 'E';

COL_REM_ISO_DE = 'T';

COL_MF_DE = 'S';
COL_MF_QS = 'O';

ninfoSAT = [];
for mm = 1:4
  
  idx_mm = [ROW_INIT, ROW_INIT+NUM_UNIT(mm)-1];
  
  unitNum = num2cell(uint16(xlsread(FILE, MONKEY{mm}, build_col(COL_UNIT_NUM,idx_mm))));
  sessNum = num2cell(uint16(xlsread(FILE, MONKEY{mm}, build_col(COL_SESS_NUM,idx_mm))));
  [~,sess] = xlsread(FILE, MONKEY{mm}, build_col(COL_SESS,idx_mm));
  [~,unit] = xlsread(FILE, MONKEY{mm}, build_col(COL_UNIT,idx_mm));
  
  if ismember(MONKEY{mm}, {'Darwin','Euler'})
    [~,area] = xlsread(FILE, MONKEY{mm}, build_col(COL_AREA_DE,idx_mm));
    [~,tRemIso] = xlsread(FILE, MONKEY{mm}, build_col(COL_REM_ISO_DE,idx_mm));
    [~,MF] = xlsread(FILE, MONKEY{mm}, build_col(COL_MF_DE,idx_mm));
    for cc = 1:NUM_UNIT(mm)
      tRemIso{cc} = str2num(tRemIso{cc});
      MF{cc} = str2num(MF{cc}) + 1;
    end
  elseif ismember(MONKEY{mm}, {'Quincy','Seymour'})
    area = cell(NUM_UNIT(mm),1);
    tRemIso = cell(NUM_UNIT(mm),1);
    [~,MF] = xlsread(FILE, MONKEY{mm}, build_col(COL_MF_QS,idx_mm));
    for cc = 1:NUM_UNIT(mm)
      area{cc} = 'FEF';
      tRemIso{cc} = 0;
      MF{cc} = str2num(MF{cc}) + 1;
    end
  end
  
  ninfo_mm = struct('monkey',MONKEY{mm}(1), 'sessNum',sessNum, 'sess',sess, 'unitNum',unitNum, 'unit',unit, ...
    'area',area, 'tRemIso',tRemIso, 'MF',MF);
  
  ninfoSAT = cat(1, ninfoSAT, ninfo_mm);
  
end%for:monkey(mm)

end%fxn:load_neuron_info_SAT_()

function [ col ] = build_col( letter , idx )
  col = [upper(letter),num2str(idx(1)),':',upper(letter),num2str(idx(2))];
end
