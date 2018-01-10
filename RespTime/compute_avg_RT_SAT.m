function [ varargout ] = compute_avg_RT_SAT( )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Darwin
load('~/Documents/SAT/data_behavior_Da.mat', 'infoDa','movesDa')
infoDa = infoDa.SAT; movesDa = movesDa.SAT;
NUM_SESSIONS_Da = length(movesDa);

RT_Da = new_struct({'acc','fast'}, 'dim',[1,NUM_SESSIONS_Da]);

for kk = 1:NUM_SESSIONS_Da
  
  idx_acc = (infoDa(kk).condition == 1);
  idx_fast = (infoDa(kk).condition == 3);
  
  RT_Da(kk).acc = median(movesDa(kk).resptime(idx_acc));
  RT_Da(kk).fast = median(movesDa(kk).resptime(idx_fast));
  
end%for:sessions(kk)

fprintf('Da RT Acc: %g +/- %g ms\n', mean([RT_Da.acc]), std([RT_Da.acc])/sqrt(NUM_SESSIONS_Da))
fprintf('Da RT Fast: %g +/- %g ms\n', mean([RT_Da.fast]), std([RT_Da.fast])/sqrt(NUM_SESSIONS_Da))

%% Euler
load('~/Documents/SAT/data_behavior_Eu.mat', 'infoEu','movesEu')
infoEu = infoEu.SAT; movesEu = movesEu.SAT;
NUM_SESSIONS_Eu = length(movesEu);

RT_Eu = new_struct({'acc','fast'}, 'dim',[1,NUM_SESSIONS_Eu]);

for kk = 1:NUM_SESSIONS_Eu
  
  idx_acc = (infoEu(kk).condition == 1);
  idx_fast = (infoEu(kk).condition == 3);
  
  RT_Eu(kk).acc = median(movesEu(kk).resptime(idx_acc));
  RT_Eu(kk).fast = nanmedian(movesEu(kk).resptime(idx_fast));
  
end%for:sessions(kk)

fprintf('Eu RT Acc: %g +/- %g ms\n', mean([RT_Eu.acc]), std([RT_Eu.acc])/sqrt(NUM_SESSIONS_Eu))
fprintf('Eu RT Fast: %g +/- %g ms\n', mean([RT_Eu.fast]), std([RT_Eu.fast])/sqrt(NUM_SESSIONS_Eu))


%% Plotting

figure(); hold on

y_Da = [ mean([RT_Da.acc]) , mean([RT_Da.fast]) ];
y_Eu = [ mean([RT_Eu.acc]) , mean([RT_Eu.fast]) ];

err_Da = [ std([RT_Da.acc]) , std([RT_Da.fast]) ] / sqrt(NUM_SESSIONS_Da);
err_Eu = [ std([RT_Eu.acc]) , std([RT_Eu.fast]) ] / sqrt(NUM_SESSIONS_Eu);

errorbar_no_caps([.95 1.95],  y_Da, 'err',err_Da)
errorbar_no_caps([1.05 2.05], y_Eu, 'err',err_Eu, 'linestyle','--')

xticks([]); xlim([.90 2.10])
ppretty('image_size',[1.2,3])

if (nargout > 0)
  varargout{1} = struct('Da',RT_Da, 'Eu',RT_Eu);
end



end%function:compute_avg_RT_SAT()

