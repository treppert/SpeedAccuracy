function [ trial_switch ] = identify_condition_switch( binfo )
%identify_condition_switch Summary of this function goes here

NUM_SESSIONS = length(binfo);

FLAG_ACC = 1;
FLAG_FAST = 3;

trial_switch = new_struct({'A2F','F2A'}, 'dim',[1,NUM_SESSIONS]);

for kk = 1:NUM_SESSIONS
  
  condition = int16(binfo(kk).condition);
  
  %identify all trials with condition switch
  tmp_F2A = find(diff(condition) == (FLAG_ACC - FLAG_FAST)) + 1 ;
  tmp_A2F = find(diff(condition) == (FLAG_FAST - FLAG_ACC)) + 1 ;
  
  %remove those trials closest to session end
  tmp_F2A(tmp_F2A > (binfo(kk).num_trials-9)) = [];
  tmp_A2F(tmp_A2F > (binfo(kk).num_trials-9)) = [];
  
  trial_switch(kk).F2A = tmp_F2A;
  trial_switch(kk).A2F = tmp_A2F;
  
end%for:sessions(kk)

end%function:identify_condition_switch()

