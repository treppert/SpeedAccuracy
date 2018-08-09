function [  ] = plot_endpt_distr_resp_SAT( moves , info )
%plot_endpt_distr_resp_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

endpt_oct_corr = cell(1,NUM_SESSION);
endpt_oct_err = cell(1,NUM_SESSION);

info = index_timing_errors_SAT( info , moves );

for kk = 1:NUM_SESSION
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  idx_errdir_F = (info(kk).err_dir & ~info(kk).err_time & idx_fast);
  idx_errtime_A = (~info(kk).err_dir & info(kk).err_time & idx_acc);
  idx_corr_F = (~(info(kk).err_dir | info(kk).err_time | info(kk).err_hold) & idx_fast);
  idx_corr_A = (~(info(kk).err_dir | info(kk).err_time | info(kk).err_hold) & idx_acc);
  
  %control for direction of error movements
  %****************************************
  [idx_errdir_F, idx_corr_F] = equate_respdir_err_vs_corr(idx_errdir_F, idx_corr_F, moves(kk).octant);
  [idx_errtime_A, idx_corr_A] = equate_respdir_err_vs_corr(idx_errtime_A, idx_corr_A, moves(kk).octant);
  %****************************************
  
  endpt_oct_corr{kk} = convert_tgt_octant_to_angle(moves(kk).octant(idx_corr_F));
  endpt_oct_err{kk} = convert_tgt_octant_to_angle(moves(kk).octant(idx_errdir_F));
%   endpt_oct_err{kk} = convert_tgt_octant_to_angle(moves(kk).octant(idx_errtime_A));
  
  figure(); polaraxes(); hold on;
  polarhistogram(endpt_oct_corr{kk}, pi/32:pi/16:2*pi+pi/32, 'FaceColor','k')
  ppretty('image_size',[4,5])
  
  pause(0.25)
  
  figure(); polaraxes(); hold on;
  polarhistogram(endpt_oct_err{kk}, pi/64:pi/32:2*pi+pi/64, 'FaceColor','m')
  ppretty('image_size',[4,5])
  
  pause(0.25)
  
end%for:session(kk)

end%util:plot_endpt_distr_resp_SAT()

