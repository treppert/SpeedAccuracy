function [  ] = compute_avg_err_pcent_SAT( infoDa , movesDa , infoEu , movesEu )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Darwin
% load('~/Documents/SAT/data_behavior_Da.mat', 'infoDa','movesDa')
% infoDa = infoDa.SAT; movesDa = movesDa.SAT;
NUM_SESSIONS_Da = length(movesDa);

%get error information
movesDa = determine_errors_SAT(movesDa, infoDa);

err_dir_Da = new_struct({'acc','fast'}, 'dim',[1,NUM_SESSIONS_Da]);
err_time_Da = err_dir_Da;
err_both_Da = err_dir_Da;

for kk = 1:NUM_SESSIONS_Da
  
  idx_acc = (infoDa(kk).condition == 1);
  idx_fast = (infoDa(kk).condition == 3);
  
  idx_err_dir = movesDa(kk).err_direction;
  idx_err_time = movesDa(kk).err_timing;
  
  err_dir_Da(kk).acc = sum(idx_acc & idx_err_dir) / sum(idx_acc);
  err_dir_Da(kk).fast = sum(idx_fast & idx_err_dir) / sum(idx_fast);
  
  err_time_Da(kk).acc = sum(idx_acc & idx_err_time) / sum(idx_acc);
  err_time_Da(kk).fast = sum(idx_fast & idx_err_time) / sum(idx_fast);
  
  err_both_Da(kk).acc = sum(idx_acc & idx_err_time & idx_err_dir) / sum(idx_acc);
  err_both_Da(kk).fast = sum(idx_fast & idx_err_time & idx_err_dir) / sum(idx_fast);
  
end%for:sessions(kk)

fprintf('Da direction err Acc/Fast: %g and %g\n', mean([err_dir_Da.acc]), mean([err_dir_Da.fast]))
fprintf('Da timing err Acc/Fast: %g and %g\n', mean([err_time_Da.acc]), mean([err_time_Da.fast]))
% fprintf('Da dir + time err Acc/Fast: %g and %g\n', mean([err_both_Da.acc]), mean([err_both_Da.fast]))


%% Euler
% load('~/Documents/SAT/data_behavior_Eu.mat', 'infoEu','movesEu')
% infoEu = infoEu.SAT; movesEu = movesEu.SAT;
NUM_SESSIONS_Eu = length(movesEu);

%get error information
movesEu = determine_errors_SAT(movesEu, infoEu);

err_dir_Eu = new_struct({'acc','fast'}, 'dim',[1,NUM_SESSIONS_Eu]);
err_time_Eu = err_dir_Eu;
err_both_Eu = err_dir_Eu;

for kk = 1:NUM_SESSIONS_Eu
  
  idx_acc = (infoEu(kk).condition == 1);
  idx_fast = (infoEu(kk).condition == 3);
  
  idx_err_dir = movesEu(kk).err_direction;
  idx_err_time = movesEu(kk).err_timing;
  
  err_dir_Eu(kk).acc = sum(idx_acc & idx_err_dir) / sum(idx_acc);
  err_dir_Eu(kk).fast = sum(idx_fast & idx_err_dir) / sum(idx_fast);
  
  err_time_Eu(kk).acc = sum(idx_acc & idx_err_time) / sum(idx_acc);
  err_time_Eu(kk).fast = sum(idx_fast & idx_err_time) / sum(idx_fast);
  
  err_both_Eu(kk).acc = sum(idx_acc & idx_err_time & idx_err_dir) / sum(idx_acc);
  err_both_Eu(kk).fast = sum(idx_fast & idx_err_time & idx_err_dir) / sum(idx_fast);
  
end%for:sessions(kk)

fprintf('Eu direction err Acc/Fast: %g and %g\n', mean([err_dir_Eu.acc]), mean([err_dir_Eu.fast]))
fprintf('Eu timing err Acc/Fast: %g and %g\n', mean([err_time_Eu.acc]), mean([err_time_Eu.fast]))
% fprintf('Eu dir + time err Acc/Fast: %g and %g\n', mean([err_both_Eu.acc]), mean([err_both_Eu.fast]))


%% Plotting

figure(); hold on

y_Da_dir = 100 * [ mean([err_dir_Da.acc]) , mean([err_dir_Da.fast]) ];
y_Eu_dir = 100 * [ mean([err_dir_Eu.acc]) , mean([err_dir_Eu.fast]) ];
y_Da_time = 100 * [ mean([err_time_Da.acc]) , mean([err_time_Da.fast]) ];
y_Eu_time = 100 * [ mean([err_time_Eu.acc]) , mean([err_time_Eu.fast]) ];

sem_Da_dir = 100 * [ std([err_dir_Da.acc]) , std([err_dir_Da.fast]) ] / sqrt(NUM_SESSIONS_Da);
sem_Eu_dir = 100 * [ std([err_dir_Eu.acc]) , std([err_dir_Eu.fast]) ] / sqrt(NUM_SESSIONS_Eu);
sem_Da_time = 100 * [ std([err_time_Da.acc]) , std([err_time_Da.fast]) ] / sqrt(NUM_SESSIONS_Da);
sem_Eu_time = 100 * [ std([err_time_Eu.acc]) , std([err_time_Eu.fast]) ] / sqrt(NUM_SESSIONS_Eu);

bar([1,2], [y_Da_dir(1), y_Eu_dir(1)], 'FaceColor','r')
bar([3,4], [y_Da_dir(2), y_Eu_dir(2)], 'FaceColor',[0 .7 0])
errorbar_no_caps([1,2], [y_Da_dir(1), y_Eu_dir(1)], 'err',[sem_Da_dir(1), sem_Eu_dir(1)], 'linestyle','none')
errorbar_no_caps([3,4], [y_Da_dir(2), y_Eu_dir(2)], 'err',[sem_Da_dir(2), sem_Eu_dir(2)], 'linestyle','none')

plot([5,5], [0,35], 'k-', 'LineWidth',1.25)

bar([6,7], [y_Da_time(1), y_Eu_time(1)], 'FaceColor','r')
bar([8,9], [y_Da_time(2), y_Eu_time(2)], 'FaceColor',[0 .7 0])
errorbar_no_caps([6,7], [y_Da_time(1), y_Eu_time(1)], 'err',[sem_Da_time(1), sem_Eu_time(1)], 'linestyle','none')
errorbar_no_caps([8,9], [y_Da_time(2), y_Eu_time(2)], 'err',[sem_Da_time(2), sem_Eu_time(2)], 'linestyle','none')

xticks([])
yticks(0:10:40)
ppretty('image_size',[1.5,3])

end%function:compute_avg_RT_SAT()
