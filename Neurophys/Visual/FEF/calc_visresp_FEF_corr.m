function [ visresp , varargout ] = calc_visresp_FEF_corr( spikes , ninfo , moves , binfo )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);

TYPE_PLOT = {'V','VM'};
MIN_NUM_TRIALS = 5;
REMOVE_SPIKES_POST_RESP = false;

moves = determine_errors_FEF(moves, binfo);

%% Initialize output information

VR_Tin = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
VR_Tin = populate_struct(VR_Tin, {'acc','fast'}, NaN(6001,1));
VR_Din = VR_Tin;

if (nargout > 1)
  TST = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
  TST = populate_struct(TST, {'acc','fast'}, NaN);
end

%% Compute the SDF corresponding to Target In RF vs. Distractor In RF

for kk = 1:NUM_CELLS
  %make sure we have vis- or vis-move cell
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).sesh);
  
  %index by response accuracy
  idx_corr = ~(moves(kk_moves).err_direction | moves(kk_moves).err_timing);
  %index by condition
  idx_fast = (binfo(kk_moves).condition == 3) & idx_corr;
  idx_acc = (binfo(kk_moves).condition == 1) & idx_corr;
  %index by singleton location re. RF
  idx_Tin = ismember(binfo(kk_moves).tgt_octant, ninfo(kk).resp_field);
  
  %% Compute spike density function
  
  sdf_kk = compute_spike_density_fxn(spikes(kk).SAT);
  
  if (REMOVE_SPIKES_POST_RESP)
    sdf_kk = remove_spikes_post_response(sdf_kk, moves(kk_moves).resptime);
  end
  
  %target in RF
  if ((sum(idx_Tin & idx_acc) >= MIN_NUM_TRIALS) && (sum(idx_Tin & idx_fast) >= MIN_NUM_TRIALS))
    VR_Tin(kk).acc(:) = transpose(nanmean(sdf_kk(idx_Tin & idx_acc,:)));
    VR_Tin(kk).fast(:) = transpose(nanmean(sdf_kk(idx_Tin & idx_fast,:)));
    if (nargout > 1)
      TST_acc = compute_TST_MannWhitney(sdf_kk(idx_Tin & idx_acc,:), sdf_kk(~idx_Tin & idx_acc,:), 'correct');
      TST_fast = compute_TST_MannWhitney(sdf_kk(idx_Tin & idx_fast,:), sdf_kk(~idx_Tin & idx_fast,:), 'correct');
      if ~(isnan(TST_acc) || isnan(TST_fast)) %make sure we have TST for both Acc and Fast conditions
        TST(kk).acc = TST_acc;
        TST(kk).fast = TST_fast;
      end
    end
  end

  %distractor in RF
  VR_Din(kk).acc(:) = transpose(nanmean(sdf_kk(~idx_Tin & idx_acc,:)));
  VR_Din(kk).fast(:) = transpose(nanmean(sdf_kk(~idx_Tin & idx_fast,:)));
  
end%for:cells(kk)

visresp = struct('Tin',VR_Tin, 'Din',VR_Din);

if (nargout > 1)
  varargout{1} = [TST.fast]';
end

end%function:calc_visresp_FEF_corr()
