function [  ] = plotSDFXdirMG( binfo , moves , ninfo , spikes , varargin )
%plotSDFXdirMG() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

MIN_RT = 550; %enforce hard minimum on MG RT

NUM_CELLS = length(spikes);
T_STIM = 3500 + (-400 : 800);
T_RESP = 3500 + (-800 : 400);

IDX_STIM_PLOT = [11, 5, 3, 1, 7, 13, 15, 17];
IDX_RESP_PLOT = IDX_STIM_PLOT + 1;

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RTkk = double(moves(kk).resptime);
  
  %compute spike density function and align on primary response
  sdfKKstim = compute_spike_density_fxn(spikes(cc).SAT);
  sdfKKresp = align_signal_on_response(sdfKKstim, RTkk); 
  
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_hold | binfo(kk).err_nosacc);
  %index by hard min RT
  idxRT = (RTkk >= MIN_RT);
  
  %initializations
  sdfStim = NaN(8,length(T_STIM));
  sdfResp = NaN(8,length(T_STIM));
  RT = NaN(1,8);
  for dd = 1:8 %loop over response directions
    idxDir = (moves(kk).octant == dd);
    sdfStim(dd,:) = nanmean(sdfKKstim(idxCorr & idxRT & idxDir, T_STIM));
    sdfResp(dd,:) = nanmean(sdfKKresp(idxCorr & idxRT & idxDir, T_RESP));
    RT(dd) = median(RTkk(idxCorr & idxRT & idxDir));
  end%for:direction(dd)
  
  %% Plotting
  figure();  yLim = [min(min([sdfStim sdfResp])) max(max([sdfStim sdfResp]))];
  
  for dd = 1:8 %loop over directions and plot
    
    %plot from array
    subplot(3,6,IDX_STIM_PLOT(dd)); hold on
    plot([0 0], yLim, 'k-')
    plot(RT(dd)*ones(1,2), yLim, 'k:')
    plot(T_STIM-3500, sdfStim(dd,:), 'k-');
    
    xlim([T_STIM(1) T_STIM(end)]-3500)
    xticks((T_STIM(1) : 200 : T_STIM(end)) - 3500)
    
    if (IDX_STIM_PLOT(dd) == 7)
      ylabel('Activity (sp/sec)');  xticklabels([])
    elseif (IDX_STIM_PLOT(dd) == 15)
      xlabel('Time from array (ms)');  yticklabels([])
      print_session_unit(gca , ninfo(cc), binfo(kk), 'horizontal')
    else
      xticklabels([]);  yticklabels([])
    end
    
    %plot from response
    subplot(3,6,IDX_RESP_PLOT(dd)); hold on
    plot([0 0], yLim, 'k-')
    plot(-RT(dd)*ones(1,2), yLim, 'k:')
    plot(T_RESP-3500, sdfResp(dd,:), 'k-');
    
    xlim([T_RESP(1) T_RESP(end)]-3500)
    xticks((T_RESP(1) : 200 : T_RESP(end)) - 3500)
    set(gca, 'YAxisLocation','right')
    
    if (IDX_RESP_PLOT(dd) == 16)
      xlabel('Time from response (ms)');  yticklabels([])
      print_session_unit(gca , ninfo(cc), binfo(kk), 'horizontal')
    else
      xticklabels([]);  yticklabels([])
    end
    
    pause(.05)
  end%for:direction(dd)
  
  ppretty('image_size',[14,8])
  pause(0.1); print(['C:\Users\thoma\Dropbox\Speed Accuracy\SEF_SAT\Figs\Memory-Guided\SDFXdir\', ...
    ninfo(cc).area,'-',ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(0.1); close()
  
end%for:cells(cc)

end%fxn:plotSDFXdirMG()
