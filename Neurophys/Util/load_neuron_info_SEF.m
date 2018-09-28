function [ ninfo ] = load_neuron_info_SEF( monkey )
%load_neuron_info_SAT Summary of this function goes here
%   Detailed explanation goes here

FILE_XLSX = '~/Dropbox/Speed Accuracy/SEF_SAT/Info/Session_Info_SAT.xlsx';
% FILE_XLSX = 'C:\Users\Tom\Dropbox\Speed Accuracy\SEF_SAT\Info\Session_Info_SAT.xlsx';

if strcmp(monkey(1), 'D')
  ninfo = load_info_xlsx_SAT([6, 43], FILE_XLSX, 'Darwin')';
elseif strcmp(monkey(1), 'E')
  ninfo = load_info_xlsx_SAT([6, 39], FILE_XLSX, 'Euler')';
else
  error('Unrecognized input "monkey"')
end

end%function:load_neuron_info_SAT()



%load raw info from Excel spreadsheet
function [ info ] = load_info_xlsx_SAT( index , file , monkey )

%session info
sess_num = num2cell(uint8(xlsread(file, monkey, build_col('A',index(1),index(2)))));
[~,sess] = xlsread(file, monkey, build_col('B',index(1),index(2)));
[~,unit] = xlsread(file, monkey, build_col('C',index(1),index(2)));

%neuron type
vis = num2cell(uint8(xlsread(file, monkey, build_col('J',index(1),index(2)))));
mov = num2cell(uint8(xlsread(file, monkey, build_col('K',index(1),index(2)))));

%isolation
isolation = num2cell(uint8(xlsread(file, monkey, build_col('M',index(1),index(2)))));
iRem_1 = num2cell( uint16(xlsread(file, monkey, build_col('N',index(1),index(2)))) );
iRem_2 = num2cell( uint16(xlsread(file, monkey, build_col('O',index(1),index(2)))) );

%event-related modulation
[~,bline] = xlsread(file, monkey, build_col('P',index(1),index(2)));
rewAcc = num2cell( (xlsread(file, monkey, build_col('X',index(1),index(2)))) );
rewFast = num2cell( (xlsread(file, monkey, build_col('Y',index(1),index(2)))) );

%combine information into struct array
info = struct('sess',sess, 'snum',sess_num, 'unit',unit, ...
  'vis',vis, 'mov',mov, ...
  'isolation',isolation, 'iRem1',iRem_1, 'iRem2',iRem_2, ...
  'bline',bline, 'rewAcc',rewAcc, 'rewFast',rewFast);

info = orderfields(info);

end%util:load_data_xlsx_SAT()

%utility to specify cells in Excel spreadsheet
function [ col ] = build_col( letter , idx_1 , idx_2 )
  col = [upper(letter),num2str(idx_1),':',upper(letter),num2str(idx_2)];
end%util:build_col()

