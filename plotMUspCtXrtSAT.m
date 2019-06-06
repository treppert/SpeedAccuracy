function [ ] = plotMUspCtXrtSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotMUspCtXrtSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Figs\2-Baseline\';
NUM_SESSION = 3;%length(binfo);

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);
idxMove = ([ninfo.moveGrade] >= 2);
idxKeep = (idxArea & idxMonkey & (idxVis | idxMove));

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

T_BLINE = 3500 + [-600 20]; %from array
T_PRESACC = [-150, 0]; %from primary saccade

for kk = 1:NUM_SESSION
  fprintf('Session %s\n', binfo(kk).session)
  ccKK = find(ismember({ninfo.sess}, binfo(kk).session));  numCells = length(ccKK);
  RTkk = double(moves(kk).resptime);
  
  %make sure we have neurons from this session
  if (numCells == 0); continue; end
  %print units
  for cc = 1:numCells; fprintf('Unit %s - %s\n', ninfo(ccKK(cc)).sess, ninfo(ccKK(cc)).unit); end
  
  %session-specific initializations
  spkBaseline = NaN(numCells,binfo(kk).num_trials);
  spkVisResp = NaN(numCells,binfo(kk).num_trials);
  spkPreSacc = NaN(numCells,binfo(kk).num_trials);
  
  %loop over all neurons from this session
  for cc = 1:numCells
    ccNS = ninfo(ccKK(cc)).unitNum;
    spikesCC = spikes(ccKK(cc)).SAT;
    visRespLatency = nstats(ccNS).VRlatAcc; %latency equal for Acc/Fast
    T_VISRESP = 3500 + visRespLatency + [0 150];
    
    spkBaseline(cc,:) = cellfun(@(x) sum((x > T_BLINE(1)) & (x < T_BLINE(2))), spikesCC);
    spkVisResp(cc,:)  = cellfun(@(x) sum((x > T_VISRESP(1)) & (x < T_VISRESP(2))), spikesCC);
    
    %reference spikes to time of primary saccade
    for jj = 1:binfo(kk).num_trial
      spikesCC{jj} = spikesCC{jj} - (3500 + RTkk(jj));
    end
    
    spkPreSacc(cc,:) = cellfun(@(x) sum((x > T_PRESACC(1)) & (x < T_PRESACC(2))), spikesCC);
    
  end%for:cells(cc)
  
  %TODO - REMOVE ALL TRIALS WITH POOR ISOLATION QUALITY
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  
end%for:session(kk)

end%fxn:plotMUspCtXrtSAT()

