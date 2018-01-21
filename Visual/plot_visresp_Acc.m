function [  ] = plot_visresp_Acc( ninfo , spikes , binfo , monkey )
%plot_visresp_cond_switch Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(ninfo);
MIN_GRADE = 3; %minimum grade for visual response

TRIAL_PLOT = ( 0 : 1 ) ;
NUM_TRIALS = length(TRIAL_PLOT);

COLOR_Begin = linspace(0.6, 0.4, NUM_TRIALS);
COLOR_End = linspace(0.2, 0.0, NUM_TRIALS);

TIME_STIM = 3500;
TIME_PLOT = ( 1 : 300 ) ;
NUM_SAMP = length(TIME_PLOT);

VR_Begin = cell(NUM_TRIALS,NUM_CELLS);
VR_End = cell(NUM_TRIALS,NUM_CELLS);

trial_switch = identify_condition_switch( binfo , monkey );

%% Initialize visual response

for kk = 1:NUM_CELLS
  
  sesh = ismember({binfo.session}, ninfo(kk).sesh);
  
  num_Begin = length(trial_switch(sesh).F2A);
  num_End = length(trial_switch(sesh).A2F);
  
  for jj = 1:NUM_TRIALS
    VR_Begin{jj,kk} = NaN(num_Begin,NUM_SAMP);
    VR_End{jj,kk} = NaN(num_End,NUM_SAMP);
  end
  
end%for:cells(kk)


%% Calculate visual response

for kk = 1:NUM_CELLS
  if (ninfo(kk).vis < MIN_GRADE); continue; end
  
  sesh = ismember({binfo.session}, ninfo(kk).sesh);
  
  for jj = 1:NUM_TRIALS
    
    sdf_Begin = compute_spike_density_fxn(spikes(kk).SAT(trial_switch(sesh).F2A + TRIAL_PLOT(jj)));
    sdf_End = compute_spike_density_fxn(spikes(kk).SAT(trial_switch(sesh).A2F + TRIAL_PLOT(jj) - NUM_TRIALS));
    
    VR_Begin{jj,kk}(:,:) = sdf_Begin(:,TIME_STIM + TIME_PLOT);
    VR_End{jj,kk}(:,:) = sdf_End(:,TIME_STIM + TIME_PLOT);
    
  end%for:trials(jj)
  
end%for:cells(kk)

  %% Plotting
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
    ppretty('image_size',[2.0,2.0])
%     print(['~/Dropbox/tmp/',ninfo(kk).sesh,'-',ninfo(kk).unit,'.tif'], '-dtiff')

  end%for:cells(kk)

end%function:plot_visresp_Acc()

