function [ ninfo ] = load_neuron_info_SEF( monkey )
%load_neuron_info_SAT Summary of this function goes here
%   Detailed explanation goes here

FILE_XLSX = '~/Dropbox/Speed Accuracy/SEF_SAT/Info/Session_Info_SAT.xlsx';
% FILE_XLSX = 'C:\Users\Tom\Dropbox\Speed Accuracy\SEF_SAT\Info\Session_Info_SAT.xlsx';

if strcmp(monkey(1), 'D')
  ninfo = load_info_xlsx_SAT([6, 41], FILE_XLSX, 'Darwin')';
elseif strcmp(monkey(1), 'E')
  ninfo = load_info_xlsx_SAT([6, 39], FILE_XLSX, 'Euler')';
else
  error('Unrecognized input "monkey"')
end

end%function:load_neuron_info_SAT()



%load raw info from Excel spreadsheet
function [ info ] = load_info_xlsx_SAT( index , file , monkey )

%session info
sess_num = num2cell(uint8(xlsread(file, monkey, build_col('C',index(1),index(2)))));
[~,sess] = xlsread(file, monkey, build_col('D',index(1),index(2)));
[~,unit] = xlsread(file, monkey, build_col('E',index(1),index(2)));

%visual response
% [~,visType] = xlsread(file, monkey, build_col('L',index(1),index(2)));
visGrade = num2cell(xlsread(file, monkey, build_col('L',index(1),index(2))));
[~,RF] = xlsread(file, monkey, build_col('M',index(1),index(2)));
visTestTS = num2cell(logical(xlsread(file, monkey, build_col('O',index(1),index(2)))));

for cc = 1:length(RF)
  RF{cc} = str2num(RF{cc});
end

%isolation
isolation = num2cell(uint8(xlsread(file, monkey, build_col('T',index(1),index(2)))));
iRem_1 = num2cell( uint16(xlsread(file, monkey, build_col('U',index(1),index(2)))) );
iRem_2 = num2cell( uint16(xlsread(file, monkey, build_col('V',index(1),index(2)))) );

%reward prediction error
RPE = num2cell(xlsread(file, monkey, build_col('W',index(1),index(2))));

%combine information into struct array
info = struct('sess',sess, 'snum',sess_num, 'unit',unit, ...
  'visGrade',visGrade, 'visTestTS',visTestTS, 'RF',RF, ...
  'isolation',isolation, 'iRem1',iRem_1, 'iRem2',iRem_2, ...
  'RPE',RPE);

info = orderfields(info);

end%util:load_data_xlsx_SAT()

%utility to specify cells in Excel spreadsheet
function [ col ] = build_col( letter , idx_1 , idx_2 )
  col = [upper(letter),num2str(idx_1),':',upper(letter),num2str(idx_2)];
end%util:build_col()

