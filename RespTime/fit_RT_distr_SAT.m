function [  ] = fit_RT_distr_SAT( moves , info )
%fit_RT_distr_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

RT_Acc = [];
RT_Fast = [];

for kk = 1:NUM_SESSION
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  RT_Acc = [RT_Acc, moves(kk).resptime(idx_acc)];
  RT_Fast = [RT_Fast, moves(kk).resptime(idx_fast)];
  
end%for:sessions(kk)

distr_Acc = fitdist(RT_Acc', 'Normal');
distr_Fast = fitdist(RT_Fast', 'Gamma');


RT_MODEL = linspace(-250, 350, 2e3);
y_Model_Acc = pdf(distr_Acc, RT_MODEL);
y_Model_Fast = pdf(distr_Fast, RT_MODEL);

EV_dRT_Acc = distr_Acc.mu - RT_MODEL;
EV_dRT_Fast = distr_Fast.a / distr_Fast.b - RT_MODEL;

figure(); hold on
plot(RT_MODEL, EV_dRT_Acc, 'k:', 'LineWidth',1.5)
plot(RT_MODEL, EV_dRT_Fast, 'k:', 'LineWidth',1.5)
ppretty()

% figure(); hold on
% histogram(RT_Acc, 'Normalization','pdf', 'BinWidth',50, 'FaceColor','r', 'EdgeColor','none')
% plot(RT_MODEL, y_Model_Acc, 'k-', 'LineWidth',1.5)
% ppretty('image_size',[4,4])
% 
% figure(); hold on
% histogram(RT_Fast, 'Normalization','pdf', 'BinWidth',50, 'FaceColor',[0 .7 0], 'EdgeColor','none')
% plot(RT_MODEL, y_Model_Fast, 'k-', 'LineWidth',1.5)
% ppretty('image_size',[4,4])

end%function:fit_RT_distr_SAT()

