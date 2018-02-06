function [ visresp , varargout ] = calc_visresp_FEF_err( spikes , ninfo , moves , binfo )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);

TYPE_PLOT = {'V','VM'};
MIN_NUM_TRIALS = 2;
REMOVE_SPIKES_POST_RESP = false;

moves = determine_errors_FEF(moves, binfo);

%% Initialize output information

VR_Tin_Sout = new_struct({'acc','fast'}, 'dim',[1,NUM_CELLS]);
VR_Tin_Sout = populate_struct(VR_Tin_Sout, {'acc','fast'}, NaN(6001,1));
VR_Tout_Sin = VR_Tin_Sout;

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
  
  %index by response accuracy -- only responses with *correct* timing
  idx_err = moves(kk_moves).err_direction & ~moves(kk_moves).err_timing;
  %index by condition
  idx_fast = (binfo(kk_moves).condition == 3) & idx_err;
  idx_acc = (binfo(kk_moves).condition == 1) & idx_err;
  %index by singleton location re. RF
  idx_Tin = ismember(binfo(kk_moves).tgt_octant, ninfo(kk).resp_field);
  %index by response location re. RF
  idx_Sin = ismember(moves(kk_moves).octant, ninfo(kk).resp_field);
  
  %combine and create composite indexes
  idx_Tout_Sin = (~idx_Tin & idx_Sin);
  idx_Tin_Sout = (idx_Tin & ~idx_Sin);
  
  %% Compute spike density function
  
  sdf_kk = compute_spike_density_fxn(spikes(kk).SAT);
  
  if (REMOVE_SPIKES_POST_RESP)
    sdf_kk = remove_spikes_post_response(sdf_kk, moves(kk_moves).resptime);
  end
  
  %singleton out RF + response in RF - ACC
  if (sum(idx_Tout_Sin & idx_acc) >= MIN_NUM_TRIALS)
    VR_Tout_Sin(kk).acc(:) = transpose(nanmean(sdf_kk(idx_Tout_Sin & idx_acc,:)));
    if (nargout > 1)
      TST(kk).acc = compute_TST_MannWhitney(sdf_kk(idx_Tout_Sin & idx_acc,:), sdf_kk(idx_Tin_Sout & idx_acc,:));
    end
  end
  %singleton out RF + response in RF - FAST
  if (sum(idx_Tout_Sin & idx_fast) >= MIN_NUM_TRIALS)
    VR_Tout_Sin(kk).fast(:) = transpose(nanmean(sdf_kk(idx_Tout_Sin & idx_fast,:)));
    if (nargout > 1)
      TST(kk).fast = compute_TST_MannWhitney(sdf_kk(idx_Tout_Sin & idx_fast,:), sdf_kk(idx_Tin_Sout & idx_fast,:));
    end
  end
  
  %singleton in RF + response out RF
  VR_Tin_Sout(kk).acc(:) = transpose(nanmean(sdf_kk(idx_Tin_Sout & idx_acc,:)));
  VR_Tin_Sout(kk).fast(:) = transpose(nanmean(sdf_kk(idx_Tin_Sout & idx_fast,:)));
  
end%for:cells(kk)

visresp = struct('Tin_Sout',VR_Tin_Sout, 'Tout_Sin',VR_Tout_Sin);

if (nargout > 1)
  varargout{1} = TST;
end

end%function:calc_visresp_FEF_err()
