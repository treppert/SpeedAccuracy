function [ ] = plot_main_sequence_across_SAT( moves , info )
%plot_main_sequence_SAT
% 

%set up the amplitude bins for plotting
BIN_STEP = 0.5;
BIN_LIM = (4 : BIN_STEP : 8);
NUM_BIN = length(BIN_LIM) - 1;
DISP_PLOT = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

[pv_fast_Da , pv_acc_Da] = get_peakvel_monkey(moves(1:9), info(1:9), BIN_LIM);
[pv_fast_Eu , pv_acc_Eu] = get_peakvel_monkey(moves(10:16), info(10:16), BIN_LIM);

%% Plotting

figure(); hold on
errorbar_no_caps(DISP_PLOT, pv_acc_Da(1,:), 'err',pv_acc_Da(2,:), 'color','r', 'linewidth',1.5)
errorbar_no_caps(DISP_PLOT, pv_fast_Da(1,:),'err',pv_fast_Da(2,:), 'color',[0 .7 0], 'linewidth',1.5)
ppretty(); pause(.2)

figure(); hold on
errorbar_no_caps(DISP_PLOT, pv_acc_Eu(1,:), 'err',pv_acc_Eu(2,:), 'color','r', 'linewidth',1.5)
errorbar_no_caps(DISP_PLOT, pv_fast_Eu(1,:),'err',pv_fast_Eu(2,:), 'color',[0 .7 0], 'linewidth',1.5)
ppretty()

end%function:plot_main_sequence_SAT()


function [ pv_fast , pv_acc ] = get_peakvel_monkey( moves_monkey , info_monkey , bin_lim )

disp = [moves_monkey.disp];
% disp = [moves_monkey.r_fin] - [moves_monkey.r_init];
condition = [info_monkey.condition];
peakvel = [moves_monkey.peakvel];

idx_fast = (condition == 3);
idx_acc =  (condition == 1);
idx_nan = isnan(disp);

pv_fast = bin_saccades(bin_lim, disp(idx_fast & ~idx_nan), peakvel(idx_fast & ~idx_nan));
pv_acc = bin_saccades(bin_lim, disp(idx_acc & ~idx_nan), peakvel(idx_acc & ~idx_nan));

end%function:get_peakvel_monkey()

function [ param_bin ] = bin_saccades( bin_lim , disp , param )

%initialize output
NUM_BIN = length(bin_lim) - 1;
param_bin = NaN(2,NUM_BIN); %mean|sd

%loop over displacement bins
for jj = 1:NUM_BIN
  idx_jj = (disp > bin_lim(jj)) & (disp <= bin_lim(jj+1));
  param_bin(:,jj) = [mean(param(idx_jj)) ; std(param(idx_jj))];
end

end%function:bin_saccades()
