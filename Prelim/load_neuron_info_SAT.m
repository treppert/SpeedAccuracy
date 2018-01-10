function [ ninfo ] = load_neuron_info_SAT( area , varargin )
%load_neuron_info_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=','Da'}});

FILE_XLSX = '~/Dropbox/Speed Accuracy/__SC_SAT/Task_Info/Session_Info_SAT.xlsx';
% load('~/Documents/SAT/info_moves_SAT.mat', 'movesDa','movesEu','movesQ','movesS')

%% Initializations

%Excel spreadsheet column labels -- depth|unit|hemi|session|num|RF|MF|type
LETTER_SC = {'I','C','E','B','A','M','N','D'};
LETTER_Q = {'K','C','E','B','A','I','J','D'};
LETTER_S = {'L','C','E','B','A','H','I','D'};

%spreadsheet row limits
IDX_SC = [4, 10];
IDX_Q = [4, 163];
IDX_S = [4, 161];
IDX_Da_FEF = [14, 59];
IDX_Da_SEF = [63, 107];
IDX_Eu_SEF = [14, 48];

if strcmp(area, 'sc')
  
  info_Da_SC = load_info_xlsx_SAT(LETTER_SC, IDX_SC, FILE_XLSX, 'monkey','Darwin');
  info_Eu_SC = load_info_xlsx_SAT(LETTER_SC, IDX_SC, FILE_XLSX, 'monkey','Euler');
  
  ninfo = [info_Da_SC; info_Eu_SC]';
  
elseif strcmp(area, 'fef')
  
  info_Da_FEF = [];
  info_Q_FEF = [];
  info_S_FEF = [];
  
  if strcmp(args.monkey, 'Da')
    info_Da_FEF = load_info_xlsx_SAT(LETTER_SC, IDX_Da_FEF, FILE_XLSX, 'monkey','Darwin');
  elseif strcmp(args.monkey, 'Q')
    info_Q_FEF = load_info_xlsx_SAT(LETTER_Q, IDX_Q, FILE_XLSX, 'monkey','Quincy');
  elseif strcmp(args.monkey, 'S')
    info_S_FEF = load_info_xlsx_SAT(LETTER_S, IDX_S, FILE_XLSX, 'monkey','Seymour');
  else
    error('Input "monkey" not recognized')
  end
  
  ninfo = [info_Da_FEF; info_Q_FEF; info_S_FEF]';
  
elseif strcmp(area, 'sef')
  
  info_Da_SEF = [];
  info_Eu_SEF = [];
  
  if strcmp(args.monkey, 'Da')
    info_Da_SEF = load_info_xlsx_SAT(LETTER_SC, IDX_Da_SEF, FILE_XLSX, 'monkey','Darwin');
  elseif strcmp(args.monkey, 'Eu')
    info_Eu_SEF = load_info_xlsx_SAT(LETTER_SC, IDX_Eu_SEF, FILE_XLSX, 'monkey','Euler');
  else
    error('Input "monkey" not recognized')
  end
  
  ninfo = [info_Da_SEF; info_Eu_SEF];
  
end

end%function:load_neuron_info_SAT()



%load raw info from Excel spreadsheet
function [ info ] = load_info_xlsx_SAT( col_header , index , file , varargin )

args = getopt(varargin, {{'monkey=','Darwin'}});

%collect relevant information from Excel spreadsheet
[~,unit] = xlsread(file, args.monkey, build_col(col_header{2},index(1),index(2)));
[~,hemi] = xlsread(file, args.monkey, build_col(col_header{3},index(1),index(2)));
[~,session] = xlsread(file, args.monkey, build_col(col_header{4},index(1),index(2)));
session_num = uint8(xlsread(file, args.monkey, build_col(col_header{5},index(1),index(2))));
[~,RF] = xlsread(file, args.monkey, build_col(col_header{6},index(1),index(2)));
[~,MF] = xlsread(file, args.monkey, build_col(col_header{7},index(1),index(2)));
[~,type] = xlsread(file, args.monkey, build_col(col_header{8},index(1),index(2)));

NUM_NEURONS = length(session_num);

monkey = cell(NUM_NEURONS,1);

for kk = 1:NUM_NEURONS
  RF{kk} = str2num(RF{kk}) + 1;
  MF{kk} = str2num(MF{kk}) + 1;
  monkey{kk} = args.monkey(1);
end

info = struct('session',session, 'session_num',num2cell(session_num), 'unit',unit, ...
  'type',type, 'hemi',hemi, 'move_field',MF, 'resp_field',RF, 'monkey',monkey);

info = orderfields(info);

end%function:load_data_xlsx_SAT()

%utility to specify cells in Excel spreadsheet
function [ col ] = build_col( letter , idx_1 , idx_2 )
  col = [upper(letter),num2str(idx_1),':',upper(letter),num2str(idx_2)];
end%function:build_col()

