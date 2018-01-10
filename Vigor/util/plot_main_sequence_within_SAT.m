function [ ] = plot_main_sequence_within_SAT( moves , info , varargin )
%plot_main_sequence_SAT
% 
global MIN_PER_BIN

args = getopt(varargin, {'split_error'});

MIN_PER_BIN = 25;

NUM_SESSIONS = length(moves);
Y_LIM = [200,800];

%set up the amplitude bins for plotting
BIN_STEP = 0.5;
BIN_LIM = (3 : BIN_STEP : 12);
NUM_BIN = length(BIN_LIM) - 1;

if (args.split_error)
  peakvel = new_struct({'corr','err'}, 'dim',[1,NUM_SESSIONS]);
  peakvel = populate_struct(peakvel, {'corr','err'}, NaN(2,NUM_BIN));
  peakvel = struct('acc',peakvel, 'fast',peakvel);
else
  peakvel = new_struct({'acc','fast'}, 'dim',[1,NUM_SESSIONS]);
  peakvel = populate_struct(peakvel, {'acc','fast'}, NaN(2,NUM_BIN));
end

%% Get data corresponding to each session

for kk = 1:NUM_SESSIONS
  
  idx_nan = isnan(moves(kk).disp);
  idx_fast = (info(kk).condition == 3);
  idx_acc  = (info(kk).condition == 1);
  
  if (args.split_error)
    idx_err = (moves(kk).direction_err);
    peakvel.fast(kk).err = bin_saccades(BIN_LIM, moves(kk).disp(idx_fast & ~idx_nan & idx_err), moves(kk).peakvel(idx_fast & ~idx_nan & idx_err));
    peakvel.fast(kk).corr = bin_saccades(BIN_LIM, moves(kk).disp(idx_fast & ~idx_nan & ~idx_err), moves(kk).peakvel(idx_fast & ~idx_nan & ~idx_err));
    peakvel.acc(kk).err = bin_saccades(BIN_LIM, moves(kk).disp(idx_acc & ~idx_nan & idx_err), moves(kk).peakvel(idx_acc & ~idx_nan & idx_err));
    peakvel.acc(kk).corr = bin_saccades(BIN_LIM, moves(kk).disp(idx_acc & ~idx_nan & ~idx_err), moves(kk).peakvel(idx_acc & ~idx_nan & ~idx_err));
  else
    peakvel(kk).fast = bin_saccades(BIN_LIM, moves(kk).disp(idx_fast & ~idx_nan), moves(kk).peakvel(idx_fast & ~idx_nan));
    peakvel(kk).acc  = bin_saccades(BIN_LIM, moves(kk).disp(idx_acc & ~idx_nan), moves(kk).peakvel(idx_acc & ~idx_nan));
  end
  
end%for:sessions(kk)


%% Plotting - Individual sessions
DISP_PLOT = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

figure()

for kk = 1:NUM_SESSIONS
  
  subplot(5,5,kk); hold on
  
  if (args.split_error)
    errorbar_no_caps(DISP_PLOT, peakvel.acc(kk).err(1,:), 'err',peakvel.acc(kk).err(2,:), 'color',[1 .5 .5], 'linewidth',1.5)
    errorbar_no_caps(DISP_PLOT, peakvel.acc(kk).corr(1,:), 'err',peakvel.acc(kk).corr(2,:), 'color','r', 'linewidth',1.5)
    errorbar_no_caps(DISP_PLOT, peakvel.fast(kk).err(1,:), 'err',peakvel.fast(kk).err(2,:), 'color',[.4 .7 .4], 'linewidth',1.5)
    errorbar_no_caps(DISP_PLOT, peakvel.fast(kk).corr(1,:), 'err',peakvel.fast(kk).corr(2,:), 'color',[0 .7 0], 'linewidth',1.5)
  else
    errorbar_no_caps(DISP_PLOT, peakvel(kk).acc(1,:), 'err',peakvel(kk).acc(2,:), 'color','r', 'linewidth',1.5)
    errorbar_no_caps(DISP_PLOT, peakvel(kk).fast(1,:),'err',peakvel(kk).fast(2,:), 'color',[0 .7 0], 'linewidth',1.5)
  end
  
  ylim(Y_LIM)
  x_lim = get(gca, 'xlim');
  text(x_lim(1)+diff(x_lim)/20,Y_LIM(1), info(kk).session, 'Rotation',90, 'HorizontalAlignment','left', 'FontSize',8)
  
  if (kk <=12) %remove xtick labels from all rows except bottom
    xticklabels(cell(1,length(get(gca,'xtick'))))
  end
  if (mod(kk,4) ~= 1) %remove ytick labels from all cols except first
    yticklabels(cell(1,length(get(gca,'ytick'))))
  end
  
  pause(.1)
  
end%for:sessions(kk)

ppretty('image_size',[8,6])


end%function:plot_main_sequence_SAT()


function [ param_bin ] = bin_saccades( bin_lim , disp , param )
global MIN_PER_BIN

%initialize output
NUM_BIN = length(bin_lim) - 1;
param_bin = NaN(2,NUM_BIN); %mean|sd

%loop over displacement bins
for jj = 1:NUM_BIN
  idx_jj = (disp > bin_lim(jj)) & (disp <= bin_lim(jj+1));
  if (sum(idx_jj) >= MIN_PER_BIN)
    param_bin(:,jj) = [mean(param(idx_jj)) ; std(param(idx_jj))];
  end
end

end%function:bin_saccades()
