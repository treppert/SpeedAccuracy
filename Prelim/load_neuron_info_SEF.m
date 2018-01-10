function [ ninfo ] = load_neuron_info_SEF( monkey )
%load_neuron_info_SAT Summary of this function goes here
%   Detailed explanation goes here

FILE_XLSX = '~/Dropbox/Speed Accuracy/SEF_SAT/Session_Info_SAT.xlsx';

if strcmp(monkey(1), 'D')
  ninfo = load_info_xlsx_SAT([3, 40], FILE_XLSX, 'Darwin')';
elseif strcmp(monkey(1), 'E')
  ninfo = load_info_xlsx_SAT([3, 36], FILE_XLSX, 'Euler')';
else
  error('Unrecognized input "monkey"')
end

end%function:load_neuron_info_SAT()



%load raw info from Excel spreadsheet
function [ info ] = load_info_xlsx_SAT( index , file , monkey )

[~,unit] = xlsread(file, monkey, build_col('C',index(1),index(2)));
[~,sesh] = xlsread(file, monkey, build_col('B',index(1),index(2)));
sesh_num = num2cell(uint8(xlsread(file, monkey, build_col('A',index(1),index(2)))));

err = num2cell( uint8(xlsread(file, monkey, build_col('O',index(1),index(2)))) );
fix = num2cell( uint8(xlsread(file, monkey, build_col('M',index(1),index(2)))) );
mov = num2cell( uint8(xlsread(file, monkey, build_col('L',index(1),index(2)))) );
rew = num2cell( uint8(xlsread(file, monkey, build_col('N',index(1),index(2)))) );
sat = num2cell( uint8(xlsread(file, monkey, build_col('R',index(1),index(2)))) );
vis = num2cell( uint8(xlsread(file, monkey, build_col('K',index(1),index(2)))) );

info = struct('sesh',sesh, 'snum',sesh_num, 'unit',unit, 'err',err, 'fix',fix, ...
  'mov',mov, 'rew',rew, 'sat',sat, 'vis',vis);

info = orderfields(info);

end%util:load_data_xlsx_SAT()

%utility to specify cells in Excel spreadsheet
function [ col ] = build_col( letter , idx_1 , idx_2 )
  col = [upper(letter),num2str(idx_1),':',upper(letter),num2str(idx_2)];
end%util:build_col()

