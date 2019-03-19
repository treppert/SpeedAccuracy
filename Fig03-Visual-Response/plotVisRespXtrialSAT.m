function [ ] = plotVisRespXtrialSAT( binfo , moves , ninfo , spikes )
%plotVisRespXtrialSAT Summary of this function goes here
%   Note - In order to use this function, first run plotVisRespSAT() in
%   order to obtain estimates of visual response latency and magnitude.
% 

if ~isfield(ninfo, 'latVRAcc')
  error('No field "latVRAcc". First run plotVisRespSAT() to quantify the VR')
end

NUM_CELLS = length(spikes);
T_STIM = 3500 + (-100 : 300);
WIN_COMP_MAG = 100; %amount of time (ms) used to estimate magnitude

%sort visual response by trial number
TRIAL = (-4 : 3); %from condition switch
NUM_TRIAL = length(TRIAL);

%output initializations
visResp = new_struct({'Acc','Fast'}, 'dim',[NUM_TRIAL,NUM_CELLS]);
visResp = populate_struct(visResp, {'Acc','Fast'}, NaN(length(T_STIM),1));
magAcc = NaN(1,NUM_CELLS);
magFast = NaN(1,NUM_CELLS);

trialSwitch = identify_condition_switch(binfo);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  sdfKKstim = compute_spike_density_fxn(spikes(cc).SAT);
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  %index by response dir re. response field
  idxRF = ismember(moves(kk).octant, ninfo(cc).visField);
  
  for jj = 1:NUM_TRIAL
    %index by trial number
    idxJJ = (0);
    %compute SDF
    VRAccCC = sdfKKstim(idxAcc & idxCorr & idxRF & idxJJ, T_STIM);
    VRFastCC = sdfKKstim(idxFast & idxCorr & idxRF & idxJJ, T_STIM);
    visResp(cc).Acc(:) = nanmean(VRAccCC);
    visResp(cc).Fast(:) = nanmean(VRFastCC);
  end%for:trial(jj)
  
end%for:cells(cc)


end%fxn:plotVisRespXtrialSAT()

