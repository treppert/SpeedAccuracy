function [ movesPP ] = parse_PostPrimary_sacc_SAT( movesAll , binfo )
%parse_PostPrimary_sacc_SAT Summary of this function goes here
%   Detailed explanation goes here

INDEX = 2; %index of the saccade re. stimulus appearance
NUM_SESSION = length(binfo);

fields_ = fieldnames(movesAll);
NUM_FIELDS = length(fields_);

movesPP = new_struct(fields_, 'dim',[1,NUM_SESSION]);

for kk = 1:NUM_SESSION
  
  %initialize output struct for this session
  for ff = 1:NUM_FIELDS
    if isa(movesAll(kk).(fields_{ff})(1), 'single')
      movesPP(kk).(fields_{ff}) = single(NaN(1,binfo(kk).num_trials));
    elseif isa(movesAll(kk).(fields_{ff})(1), 'uint16')
      movesPP(kk).(fields_{ff}) = uint16(zeros(1,binfo(kk).num_trials));
    elseif isa(movesAll(kk).(fields_{ff})(1), 'logical')
      movesPP(kk).(fields_{ff}) = false(1,binfo(kk).num_trials);
    else
      error('Data type of field %s not recognized', fields_{ff});
    end
  end
  
  num_noPP = 0; %keep track of number of trials with no post-primary
  for jj = 1:binfo(kk).num_trials
    
    %isolate saccade from trial jj with index INDEX
    idxPPjj = ( (movesAll(kk).trial == jj) & (movesAll(kk).index == INDEX) );
    
    %save post-primary saccade parameters
    if (sum(idxPPjj) == 1)
      
      for ff = 1:NUM_FIELDS
        movesPP(kk).(fields_{ff})(jj) = movesAll(kk).(fields_{ff})(idxPPjj);
      end%for:fields(ff)
      
    else
      num_noPP = num_noPP + 1;
    end
    
  end%for:trials(jj)
  
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  fprintf('**** Sess %d -- %d/%d trials (%d/%d err-dir) no post-primary\n', ...
    kk, num_noPP, binfo(kk).num_trials, sum(isnan(movesPP(kk).amplitude(idx_errdir))), sum(idx_errdir))
  
end%for:sessions(kk)

end%fxn:parse_PostPrimary_sacc_SAT()

