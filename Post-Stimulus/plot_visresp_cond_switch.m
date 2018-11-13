function [ varargout ] = plot_visresp_cond_switch( ninfo , spikes , binfo )
%plot_visresp_cond_switch Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(ninfo);
MIN_GRADE = 3; %minimum grade for visual response

TRIAL_PLOT = ( -2 : 1 ) ;
NUM_TRIALS = length(TRIAL_PLOT);
% COLOR_PLOT = [0.7 0.5 0.25 0.0];
COLOR_A2F = {[1 0 0], [1 .5 .5], [.4 .7 .4], [0 .7 0]};
COLOR_F2A = fliplr(COLOR_A2F);

TIME_STIM = 3500;
TIME_PLOT = ( -100 : 300 ) ;
NUM_SAMP = length(TIME_PLOT);

visresp_A2F = cell(NUM_TRIALS,NUM_CELLS);
visresp_F2A = cell(NUM_TRIALS,NUM_CELLS);

trial_switch = identify_condition_switch( binfo );


%% Initialize visual response

for cc = 1:NUM_CELLS
  
  sesh = find(ismember({binfo.session}, ninfo(cc).sesh));
  
  num_A2F = length(trial_switch(sesh).A2F);
  num_F2A = length(trial_switch(sesh).F2A);
  
  for jj = 1:NUM_TRIALS
    visresp_A2F{jj,cc} = NaN(num_A2F,NUM_SAMP);
    visresp_F2A{jj,cc} = NaN(num_F2A,NUM_SAMP);
  end
  
end%for:cells(kk)


%% Calculate visual response

for cc = 1:NUM_CELLS
  if (ninfo(cc).vis < MIN_GRADE); continue; end
  
  sesh = find(ismember({binfo.session}, ninfo(cc).sesh));
  
  for jj = 1:NUM_TRIALS
    
    trials_A2F = trial_switch(sesh).A2F + TRIAL_PLOT(jj);
    trials_F2A = trial_switch(sesh).F2A + TRIAL_PLOT(jj);
    
    sdf_A2F = compute_spike_density_fxn( spikes(cc).SAT(trials_A2F) );
    sdf_F2A = compute_spike_density_fxn( spikes(cc).SAT(trials_F2A) );
    
    visresp_A2F{jj,cc}(:,:) = sdf_A2F(:,TIME_STIM + TIME_PLOT);
    visresp_F2A{jj,cc}(:,:) = sdf_F2A(:,TIME_STIM + TIME_PLOT);
    
  end%for:trials(jj)
  
end%for:cells(kk)

if (nargout)
  
  varargout{1} = visresp_A2F;
  varargout{2} = visresp_F2A;
  
else
  
  %% Plotting
  
  for cc = 1:NUM_CELLS
    if (ninfo(cc).vis < MIN_GRADE); continue; end

    figure()
    
    % ACC 2 FAST
    Y_LIM = NaN(NUM_TRIALS,2);
    for jj = 1:NUM_TRIALS
      subplot(2,NUM_TRIALS,jj); hold on
      title(['Trial ', num2str(TRIAL_PLOT(jj))], 'FontSize',8)
      plot(TIME_PLOT, mean(visresp_A2F{jj,cc}), 'Color',COLOR_A2F{jj}, 'LineWidth',1.25)
      xlim([TIME_PLOT(1)-10, TIME_PLOT(end)+10])
      Y_LIM(jj,:) = get(gca, 'ylim');
    end
    
    %set y-axes
    Y_LIM = [min(Y_LIM(:,1)), max(Y_LIM(:,2))];
    for jj = 1:NUM_TRIALS
      subplot(2,NUM_TRIALS,jj); ylim(Y_LIM)
    end
    
    % FAST 2 ACC
    Y_LIM = NaN(NUM_TRIALS,2);
    for jj = 1:NUM_TRIALS
      subplot(2,NUM_TRIALS,NUM_TRIALS+jj); hold on
      title(['Trial ', num2str(TRIAL_PLOT(jj))], 'FontSize',8)
      plot(TIME_PLOT, mean(visresp_F2A{jj,cc}), 'Color',COLOR_F2A{jj}, 'LineWidth',1.25)
      xlim([TIME_PLOT(1)-10, TIME_PLOT(end)+10])
      Y_LIM(jj,:) = get(gca, 'ylim');
    end
    
    %set y-axes
    Y_LIM = [min(Y_LIM(:,1)), max(Y_LIM(:,2))];
    for jj = 1:NUM_TRIALS
      subplot(2,NUM_TRIALS,NUM_TRIALS+jj); ylim(Y_LIM)
    end
    
    ppretty('image_size',[8.5,10.0])
    pause(0.25); print(['~/Dropbox/tmp/', ninfo(cc).sesh,'-',ninfo(cc).unit,'.tif'], '-dtiff'); pause(0.25)

  end%for:cells(kk)
  
end%argout?

end%function:plot_visresp_cond_switch()

