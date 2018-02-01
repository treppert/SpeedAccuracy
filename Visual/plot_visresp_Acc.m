function [  ] = plot_visresp_Acc( ninfo , spikes , binfo , monkey )
%plot_visresp_cond_switch Summary of this function goes here
%   Detailed explanation goes here

PLOT_ACROSS = true;

NUM_CELLS = length(ninfo);
MIN_GRADE = 3; %minimum grade for visual response

TRIAL_PLOT = ( 0 ) ;
NUM_TRIALS = length(TRIAL_PLOT);

COLOR_Begin = 0.4;%linspace(0.6, 0.4, NUM_TRIALS);
COLOR_End = 0.0;%linspace(0.2, 0.0, NUM_TRIALS);

TIME_STIM = 3500;
TIME_PLOT = ( 1 : 300 ) ;
NUM_SAMP = length(TIME_PLOT);

VR_Begin = cell(NUM_TRIALS,NUM_CELLS);
VR_End = cell(NUM_TRIALS,NUM_CELLS);

trial_switch = identify_condition_switch( binfo , monkey );

%% Initialize visual response

for kk = 1:NUM_CELLS
  if (ninfo(kk).vis < MIN_GRADE); continue; end
  
  sesh = ismember({binfo.session}, ninfo(kk).sesh);
  
  num_Begin = length(trial_switch(sesh).F2A);
  num_End = length(trial_switch(sesh).A2F);
  
  for jj = 1:NUM_TRIALS
    VR_Begin{jj,kk} = NaN(num_Begin,NUM_SAMP);
    VR_End{jj,kk} = NaN(num_End,NUM_SAMP);
  end
  
end%for:cells(kk)


%% Calculate visual response

VR_Acc_avg = NaN(1,NUM_CELLS); %normalization factor

for kk = 1:NUM_CELLS
  if (ninfo(kk).vis < MIN_GRADE); continue; end
  
  sesh = ismember({binfo.session}, ninfo(kk).sesh);
  
  %calculate normalization factor for VR (Accurate condition)
  sdf_Acc = compute_spike_density_fxn(spikes(kk).SAT(binfo(sesh).condition == 1));
  sdf_Acc = mean(sdf_Acc(:,TIME_STIM + TIME_PLOT));
  VR_Acc_avg(kk) = max(sdf_Acc);
  
  for jj = 1:NUM_TRIALS
    
    sdf_Begin = compute_spike_density_fxn(spikes(kk).SAT(trial_switch(sesh).F2A + TRIAL_PLOT(jj)));
    sdf_End = compute_spike_density_fxn(spikes(kk).SAT(trial_switch(sesh).A2F + TRIAL_PLOT(jj) - NUM_TRIALS));
    
    VR_Begin{jj,kk}(:,:) = sdf_Begin(:,TIME_STIM + TIME_PLOT);
    VR_End{jj,kk}(:,:) = sdf_End(:,TIME_STIM + TIME_PLOT);
    
  end%for:trials(jj)
  
end%for:cells(kk)


if (PLOT_ACROSS)
  
  %% Plotting - Across cells
  NUM_SEM = sum([ninfo.vis] >= MIN_GRADE);
  
  VR_Begin_All = NaN(NUM_CELLS,NUM_SAMP);
  VR_End_All = NaN(NUM_CELLS,NUM_SAMP);

  for kk = 1:NUM_CELLS
    if (ninfo(kk).vis < MIN_GRADE); continue; end

    VR_Begin_All(kk,:) = mean(VR_Begin{1,kk});
    VR_End_All(kk,:) = mean(VR_End{1,kk});

  end%for:cells(kk)

  %normalization
  VR_Begin_All = VR_Begin_All ./ VR_Acc_avg' ;
  VR_End_All = VR_End_All ./ VR_Acc_avg' ;
  
  %remove transient visual responses
  if strcmp(monkey, 'Darwin')
    VR_Begin_All([9,11],:) = [];
    VR_End_All([9,11],:) = [];
  end
  
  figure(); hold on
  
  shaded_error_bar(TIME_PLOT, nanmean(VR_End_All), nanstd(VR_End_All)/sqrt(NUM_SEM), {'k-', 'LineWidth',1.25})
  shaded_error_bar(TIME_PLOT, nanmean(VR_Begin_All), nanstd(VR_End_All)/sqrt(NUM_SEM), {'-', 'Color',[.4 .4 .4], 'LineWidth',1.25})
  
  ppretty('image_size',[4,4])
  
else
  
  %% Plotting - Individual cells

  for kk = 1:NUM_CELLS
    if (ninfo(kk).vis < MIN_GRADE); continue; end

    figure(); hold on

    for jj = 1:NUM_TRIALS
      plot(TIME_PLOT, mean(VR_Begin{jj,kk}), 'Color',COLOR_Begin(jj)*ones(1,3), 'LineWidth',1.25)
      pause(.5)
    end

    for jj = 1:NUM_TRIALS
      plot(TIME_PLOT, mean(VR_End{jj,kk}), 'Color',COLOR_End(jj)*ones(1,3), 'LineWidth',1.25)
      pause(.5)
    end

    xlim([TIME_PLOT(1)-10, TIME_PLOT(end)+10])
    print_session_unit(gca, ninfo(kk), 'horizontal')
    ppretty('image_size',[4.0,4.0])
  %     print(['~/Dropbox/tmp/',ninfo(kk).sesh,'-',ninfo(kk).unit,'.tif'], '-dtiff')

  end%for:cells(kk)
  
end%plot across or individual?

end%function:plot_visresp_Acc()

