function [ movesPostErr ] = parse_PostErr_sacc_SAT( movesAll , binfo )
%parse_PostErr_sacc_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(binfo);


fields_moves = fieldnames(movesAll);
NUM_FIELDS = length(fields_moves);

movesPostErr = new_struct(fields_moves, 'dim',[1,NUM_SESSION]);

for kk = 1:NUM_SESSION
  
  %index trials by outcome (choice error)
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  for ff = 1:NUM_FIELDS
    
    movesPostErr.(fields_moves{ff}) = movesAll.(fields_moves{ff})(idx_errdir);
    
  end%for:fields(ff)
  
  %index trials by condition
  idx_fast = (binfo(kk).condition == 3);
  idx_acc = (binfo(kk).condition == 1);
  
  
end%for:sessions(kk)

end%fxn:parse_PostErr_sacc_SAT()

