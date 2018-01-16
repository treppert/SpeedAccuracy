function [ varargout ] = plot_visresp_cond_switch( ninfo , spikes , binfo , monkey )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(ninfo);
MIN_GRADE = 3; %minimum grade for visual response

TRIAL_PLOT = ( -1 : 1 ) ;
NUM_TRIALS = length(TRIAL_PLOT);
COLOR_PLOT = linspace(0.6, 0.0, NUM_TRIALS);

TIME_STIM = 3500;
TIME_PLOT = ( -100 : 300 ) ;
NUM_SAMP = length(TIME_PLOT);

visresp_A2F = cell(NUM_TRIALS,NUM_CELLS);
visresp_F2A = cell(NUM_TRIALS,NUM_CELLS);

trial_switch = identify_condition_switch( binfo , monkey );


%% Initialize visual response

for kk = 1:NUM_CELLS
  
  sesh = find(ismember({binfo.session}, ninfo(kk).sesh));
  
  num_A2F = length(trial_switch(sesh).A2F);
  num_F2A = length(trial_switch(sesh).F2A);
  
  for jj = 1:NUM_TRIALS
    visresp_A2F{jj,kk} = NaN(num_A2F,NUM_SAMP);
    visresp_F2A{jj,kk} = NaN(num_F2A,NUM_SAMP);
  end
  
end%for:cells(kk)


%% Calculate visual response

for kk = 1:NUM_CELLS
  if (ninfo(kk).vis < MIN_GRADE); continue; end
  
  sesh = find(ismember({binfo.session}, ninfo(kk).sesh));
  
  for jj = 1:NUM_TRIALS
    
    trials_A2F = trial_switch(sesh).A2F + TRIAL_PLOT(jj);
    trials_F2A = trial_switch(sesh).F2A + TRIAL_PLOT(jj);
    
    sdf_A2F = compute_spike_density_fxn( spikes(kk).SAT(trials_A2F) );
    sdf_F2A = compute_spike_density_fxn( spikes(kk).SAT(trials_F2A) );
    
    visresp_A2F{jj,kk}(:,:) = sdf_A2F(:,TIME_STIM + TIME_PLOT);
    visresp_F2A{jj,kk}(:,:) = sdf_F2A(:,TIME_STIM + TIME_PLOT);
    
  end%for:trials(jj)
  
end%for:cells(kk)

if (nargout)
  
  varargout{1} = visresp_A2F;
  varargout{2} = visresp_F2A;
  
else
  
  %% Plotting
  for kk = 1:NUM_CELLS
    if (ninfo(kk).vis < MIN_GRADE); continue; end

    figure()

    subplot(1,2,1); hold on % ACC 2 FAST
    xlim([TIME_PLOT(1)-10, TIME_PLOT(end)+10])

    for jj = 1:NUM_TRIALS
      plot(TIME_PLOT, mean(visresp_A2F{jj,kk}), 'Color',COLOR_PLOT(jj)*ones(1,3), 'LineWidth',1.25)
    end
    print_session_unit(gca, ninfo(kk), 'horizontal')


    subplot(1,2,2); hold on % FAST 2 ACC
    xlim([TIME_PLOT(1)-10, TIME_PLOT(end)+10])

    for jj = 1:NUM_TRIALS
      plot(TIME_PLOT, mean(visresp_F2A{jj,kk}), 'Color',COLOR_PLOT(jj)*ones(1,3), 'LineWidth',1.25)
    end
    yticks([])
    print_session_unit(gca, ninfo(kk), 'horizontal')

    ppretty('image_size',[4.0,2.0])
  %   print(['~/Dropbox/tmp/',ninfo(kk).sesh,'-',ninfo(kk).unit,'.tif'], '-dtiff')

  end%for:cells(kk)
  
end%argout?

end%function:plot_visresp_cond_switch()

