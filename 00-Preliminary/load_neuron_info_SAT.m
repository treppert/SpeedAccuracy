function [ ninfoSAT ] = load_neuron_info_SAT( OS )
%load_neuron_info_SAT Summary of this function goes here
%   Detailed explanation goes here

if strcmp(OS, 'Linux')
  FILE = '~/Dropbox/Speed Accuracy/SEF_SAT/Info/Unit-Info-SAT.xlsx';
elseif strcmp(OS, 'Windows')
  FILE = 'C:\Users\Tom\Dropbox\Speed Accuracy\SEF_SAT\Info\Unit-Info-SAT.xlsx';
end
MONKEY = {'Darwin','Euler','Quincy','Seymour'};

NUM_UNIT = [98, 42, 160, 158]; %Da, Eu, Q, S
ROW_INIT = 6; %row of first unit for each monkey

COL_AREA_DE = 'F';

COL_UNIT_NUM = 'B';
COL_SESS_NUM = 'C';
COL_SESS = 'D';
COL_UNIT = 'E';

COL_VISTYPE_DE = 'R';
COL_VISGRADE_DE = 'L';
COL_VISFIELD_DE = 'O';

COL_MOVEGRADE_DE = 'M';
COL_MOVEFIELD_DE = 'P';
COL_MOVEFFIELD_QS = 'O';

COL_ERRGRADE_DE = 'N';
COL_ERRFIELD_DE = 'Q';

COL_REM_ISO_DE = 'S';

ninfoSAT = [];

for mm = 1:4
  
  idx_mm = [ROW_INIT, ROW_INIT+NUM_UNIT(mm)-1];
  
  unitNum = num2cell(uint16(xlsread(FILE, MONKEY{mm}, build_col(COL_UNIT_NUM,idx_mm))));
  sessNum = num2cell(uint16(xlsread(FILE, MONKEY{mm}, build_col(COL_SESS_NUM,idx_mm))));
  [~,sess] = xlsread(FILE, MONKEY{mm}, build_col(COL_SESS,idx_mm));
  [~,unit] = xlsread(FILE, MONKEY{mm}, build_col(COL_UNIT,idx_mm));
  
  if ismember(MONKEY{mm}, {'Darwin','Euler'})
    visGrade = num2cell(xlsread(FILE, MONKEY{mm}, build_col(COL_VISGRADE_DE,idx_mm)));
    moveGrade = num2cell(xlsread(FILE, MONKEY{mm}, build_col(COL_MOVEGRADE_DE,idx_mm)));
    errGrade = num2cell(xlsread(FILE, MONKEY{mm}, build_col(COL_ERRGRADE_DE,idx_mm)));
    [~,area] = xlsread(FILE, MONKEY{mm}, build_col(COL_AREA_DE,idx_mm));
    [~,visType] = xlsread(FILE, MONKEY{mm}, build_col(COL_VISTYPE_DE,idx_mm));
    [~,visField] = xlsread(FILE, MONKEY{mm}, build_col(COL_VISFIELD_DE,idx_mm));
    [~,moveField] = xlsread(FILE, MONKEY{mm}, build_col(COL_MOVEFIELD_DE,idx_mm));
    [~,errField] = xlsread(FILE, MONKEY{mm}, build_col(COL_ERRFIELD_DE,idx_mm));
    [~,tRemIso] = xlsread(FILE, MONKEY{mm}, build_col(COL_REM_ISO_DE,idx_mm));
    for cc = 1:NUM_UNIT(mm)
      visField{cc} = str2num(visField{cc});
      moveField{cc} = str2num(moveField{cc});
      errField{cc} = str2num(errField{cc});
      tRemIso{cc} = str2num(tRemIso{cc});
      if (visField{cc} == 9) %field is all directions
        visField{cc} = (1:8);
      end
      if (moveField{cc} == 9)
        moveField{cc} = (1:8);
      end
      if (errField{cc} == 9)
        errField{cc} = (1:8);
      end
    end
  elseif ismember(MONKEY{mm}, {'Quincy','Seymour'})
    visGrade = num2cell(zeros(NUM_UNIT(mm),1));
    moveGrade = num2cell(zeros(NUM_UNIT(mm),1));
    errGrade = num2cell(zeros(NUM_UNIT(mm),1));
    area = cell(NUM_UNIT(mm),1);
    visType = cell(NUM_UNIT(mm),1);
    visField = cell(NUM_UNIT(mm),1);
    [~,moveField] = xlsread(FILE, MONKEY{mm}, build_col(COL_MOVEFFIELD_QS,idx_mm));
    errField = cell(NUM_UNIT(mm),1);
    tRemIso = cell(NUM_UNIT(mm),1);
    for cc = 1:NUM_UNIT(mm)
      area{cc} = 'FEF';
      visType{cc} = 'none';
      visField{cc} = 0;
      moveField{cc} = 0;
      errField{cc} = 0;
      tRemIso{cc} = 0;
    end
  end
  
  ninfo_mm = struct('monkey',MONKEY{mm}(1), 'sessNum',sessNum, 'sess',sess, 'unitNum',unitNum, 'unit',unit, ...
    'area',area, 'visType',visType, 'visGrade',visGrade, 'moveGrade',moveGrade, 'errGrade',errGrade, ...
    'visField',visField, 'moveField',moveField, 'errField',errField, ...
    'tRemIso',tRemIso);
  
  ninfoSAT = cat(1, ninfoSAT, ninfo_mm);
  
end%for:monkey(mm)

ninfoSAT = transpose(ninfoSAT);

end%fxn:load_neuron_info_SAT_()

function [ col ] = build_col( letter , idx )
  col = [upper(letter),num2str(idx(1)),':',upper(letter),num2str(idx(2))];
end