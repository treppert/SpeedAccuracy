function [ moves ] = determine_errors_FEF( moves , info )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSIONS = length(moves);

%initialize error fields
for kk = 1:NUM_SESSIONS
  moves(kk).err_direction = false(1,info(kk).num_trials);
  moves(kk).err_timing = false(1,info(kk).num_trials);
  moves(kk).err_x = NaN(1,info(kk).num_trials);
  moves(kk).err_y = NaN(1,info(kk).num_trials);
  moves(kk).err = NaN(1,info(kk).num_trials);
end%for:sessions(kk)


%determine trials on which direction errors occurred
for kk = 1:NUM_SESSIONS
  
  %get target location info
  tgt_octant_kk = info(kk).tgt_octant;
  tgt_angle_kk = convert_tgt_octant_to_angle( info(kk).tgt_octant );
  
  %get saccade location info
  sacc_octant_kk = moves(kk).octant;
  
  moves(kk).err_direction(sacc_octant_kk ~= tgt_octant_kk) = true;
  
  x_tgt = info(kk).tgt_eccen .* cos(tgt_angle_kk);
  y_tgt = info(kk).tgt_eccen .* sin(tgt_angle_kk);
  
  x_err = moves(kk).x_fin - x_tgt;
  y_err = moves(kk).y_fin - y_tgt;
  
  moves(kk).err_x(:) = x_err;
  moves(kk).err_y(:) = y_err;
  
  moves(kk).err(:) = sqrt(x_err.^2 + y_err.^2);
  
end%for:sessions(kk)


%determine trials on which timing errors occurred
for kk = 1:NUM_SESSIONS
  
  idx_acc_kk = (info(kk).condition == 1);
  idx_fast_kk = (info(kk).condition == 3);
  
  RT_kk = moves(kk).resptime;
  
  idx_err_acc  = ( idx_acc_kk & (RT_kk < info(kk).tgt_dline) );
  idx_err_fast = ( idx_fast_kk & (RT_kk > info(kk).tgt_dline) );
  
  moves(kk).err_timing( idx_err_acc | idx_err_fast ) = true;
  
end%for:sessions(kk)

end%function:determine_errors_SAT()

