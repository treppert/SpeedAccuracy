function [ ] = plot_raster_vs_direction_SAT( binfo , moves , ninfo , spikes , varargin )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SC'}, {'monkey=','D'}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

EVENT_ALIGN = 'stimulus';
% EVENT_ALIGN = 'response';
CONDITION = 'acc';
% CONDITION = 'fast';
SORT_BY_RT = true;

%% Initializations

NUM_CELLS = length(spikes);
NUM_DIR = 8;
MAX_TRIALS_RASTER = 500;

resptime = cell(NUM_DIR,NUM_CELLS);
spikes_x_dir = new_struct({'times'}, 'dim',[NUM_DIR,NUM_CELLS]);
num_trials_ = zeros(NUM_CELLS,NUM_DIR);

if strcmp(EVENT_ALIGN, 'stimulus')
  T_LIM = [-200,800];
elseif strcmp(EVENT_ALIGN, 'response')
  T_LIM = [-800,200];
end

%check that input "condition" is correct
if strcmp(CONDITION, 'fast')
  COLOR_RASTER = [.4 .7 .4];
elseif strcmp(CONDITION, 'acc')
  COLOR_RASTER = [1 .5 .5];
end

%% Collect spike times for each direction

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %check that the session number for input neuron is correct
  if (length(spikes(cc).SAT) ~= binfo(kk).num_trials)
    error('Number of trials for inputs "neuron" and "sacc" not the same')
  end
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_hold);
  
  %index by condition
  if strcmp(CONDITION, 'fast')
    idx_cond = (binfo(kk).condition == 3);
  elseif strcmp(CONDITION, 'acc')
    idx_cond = (binfo(kk).condition == 1);
  end
  
  for dd = 1:NUM_DIR
    
    if strcmp(EVENT_ALIGN, 'stimulus')
      idx_dd = (binfo(kk).tgt_octant == dd);
    elseif strcmp(EVENT_ALIGN, 'response')
      idx_dd = (moves(kk).octant == dd);
    end
    
    num_trials_(dd,cc) = sum(idx_corr & idx_cond & idx_dd);
%     spikes_x_dir(dd,cc).trials = find(idx_corr & idx_cond & idx_dd);
    resptime{dd,cc} = double(moves(kk).resptime(idx_corr & idx_cond & idx_dd));
    
    %collect the spike times for this direction
    if strcmp(EVENT_ALIGN, 'stimulus')
      spikes_x_dir(dd,cc).times = spikes(cc).SAT(idx_corr & idx_cond & idx_dd);
    elseif strcmp(EVENT_ALIGN, 'response')
      spikes_x_dir(dd,cc).times = cell(1,num_trials_(dd,cc));
      trials_dd = find(idx_dd);
      for tt = 1:num_trials_(dd,cc)
        spikes_x_dir(dd,cc).times{tt} = spikes(cc).SAT{trials_dd(tt)} - double(moves(kk).resptime(trials_dd(tt)));
        spikes_x_dir(dd,cc).times{tt}(spikes_x_dir(dd,cc).times{tt} < 1) = []; %remove points from trial beginning
      end
    end
    
  end%for:directions(dd)
  
end%for:cells(cc)

%limit the number of rasters per plot
num_trials_(num_trials_ > MAX_TRIALS_RASTER) = MAX_TRIALS_RASTER;


%% Plotting

PLOT_POS = [.1, .4, .7];
PLOT_SIZE = [.2, .2];

for cc = 1:NUM_CELLS
  
  subplot_pos = initialize_plot_x_dir(ninfo(cc), PLOT_POS, PLOT_SIZE);
  
  for dd = 1:NUM_DIR

    subplot('position', [subplot_pos{dd}, PLOT_SIZE]); hold on
    xlim(T_LIM); xticks(T_LIM(1) : 200 : T_LIM(2))

    %if desired, order trials for raster by response time
    if (SORT_BY_RT)
      [RT_dd,idx_dd] = sort(resptime{dd,cc}(1:num_trials_(dd,cc)));
    else
      idx_dd = (1:num_trials_(dd,cc));
      RT_dd = resptime{dd,cc};
    end
    
    %if zero-ed to saccade, then flip sign of RT
    if strcmp(EVENT_ALIGN, 'response'); RT_dd = -RT_dd; end

    [spikes, trials] = prepare_raster_spikes(spikes_x_dir(dd,cc).times(idx_dd), 'tlim',T_LIM);
    plot(spikes, trials, '.', 'Color',COLOR_RASTER, 'MarkerSize',4)

    %plot RT
    for jj = 1:num_trials_(dd,cc)
      plot(RT_dd(jj), jj, 'o', 'markersize',3, 'color','k')
    end

  end%for:directions(dd)

  ppretty('image_size',[10,8])
%   print(['~/Dropbox/tmp/',CONDITION,'-',ninfo(cc).session,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause()
  
end%for:cells(kk)

end%function:plot_raster_vs_direction_SAT()


function [ subplot_pos ] = initialize_plot_x_dir( ninfo , plot_pos , plot_size )

%initialize the figure
figure()
subplot('position', [plot_pos(2), plot_pos(2), plot_size]);
polarplot(0, 1)
set(gca, 'rtick',[])
set(gca, 'thetatick',[])
txt_ninfo = [ninfo.sess, '-', ninfo.unit];
text(0, 0, txt_ninfo, 'HorizontalAlignment','center', 'fontsize',8)

%order positions by target direction number
subplot_pos = {[plot_pos(3), plot_pos(2)], [plot_pos(3), plot_pos(3)], ...
               [plot_pos(2), plot_pos(3)], [plot_pos(1), plot_pos(3)], ...
               [plot_pos(1), plot_pos(2)], [plot_pos(1), plot_pos(1)], ...
               [plot_pos(2), plot_pos(1)], [plot_pos(3), plot_pos(1)]};

end%function:initialize_plot_x_dir()

function [ spikes , trials ] = prepare_raster_spikes( spike_times , varargin )
%prepare_raster_spikes Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'offset=',3500}, {'tlim=',[-3500,2500]}});

NUM_TRIALS = length(spike_times);

%organize spikes as 1-D arrays for plot
spikes = cell2mat(spike_times) - args.offset;

%get trials numbers corresponding to all spike times
trials = uint16(zeros(1,length(spikes)));

idx = 1;%index to track trial numbers
for jj = 1:NUM_TRIALS
  trials(idx:idx+length(spike_times{jj})-1) = jj;
  idx = idx + length(spike_times{jj});
end%for:trials(jj)

%remove spikes based on time constraints
idx_remove = ((spikes < args.tlim(1)) | (spikes > args.tlim(2)));
spikes(idx_remove) = [];
trials(idx_remove) = [];

end%function:prepare_raster_spikes()
