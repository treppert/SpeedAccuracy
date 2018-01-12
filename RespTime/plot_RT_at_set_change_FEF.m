function [] = plot_RT_at_set_change( info , moves )

%find the trials with condition switch
trial_switch = identify_condition_switch(info);

NUM_SESSION = length(info);

resptime = new_struct({'acc2fast','fast2acc'}, 'dim',[1,NUM_SESSION]);
resptime = populate_struct(resptime, {'acc2fast','fast2acc'}, NaN(6,1));

for kk = 1:NUM_SESSION
  
  NUM_A2F = length(trial_switch(kk).A2F);
  RT_A2F = NaN(6,NUM_A2F);
  
  for jj = 1:NUM_A2F
    RT_A2F(:,jj) = moves(kk).resptime(trial_switch(kk).A2F(jj)-3 : trial_switch(kk).A2F(jj)+2);
  end
  resptime(kk).acc2fast(:) = nanmean(RT_A2F,2);
  
  NUM_F2A = length(trial_switch(kk).F2A);
  RT_F2A = NaN(6,NUM_F2A);
  
  for jj = 1:NUM_F2A
    RT_F2A(:,jj) = moves(kk).resptime(trial_switch(kk).F2A(jj)-3 : trial_switch(kk).F2A(jj)+2);
  end
  resptime(kk).fast2acc(:) = nanmean(RT_F2A,2);
  
end%for:sessions(kk)

%average across sessions
RT_A2F = [resptime.acc2fast];
RT_F2A = [resptime.fast2acc];

%% Plotting
X_LEFT = [-3, -2, -1];
X_RIGHT = [1, 2, 3];

figure(); hold on

plot([0 0], [350 550], 'k--')
errorbar_no_caps(X_LEFT, mean(RT_A2F(1:3,:),2), 'err',std(RT_A2F(1:3,:),0,2)/sqrt(NUM_SESSION), 'color','r')
errorbar_no_caps(X_RIGHT, mean(RT_A2F(4:6,:),2), 'err',std(RT_A2F(4:6,:),0,2)/sqrt(NUM_SESSION), 'color',[0 .7 0])
errorbar_no_caps(X_LEFT, mean(RT_F2A(1:3,:),2), 'err',std(RT_F2A(1:3,:),0,2)/sqrt(NUM_SESSION), 'color',[0 .7 0])
errorbar_no_caps(X_RIGHT, mean(RT_F2A(4:6,:),2), 'err',std(RT_F2A(4:6,:),0,2)/sqrt(NUM_SESSION), 'color','r')

xlim([-3.1 3.1])
ppretty()

end%function:plot_param_at_set_change()
