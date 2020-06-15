function [ varargout ] = testTErrVSisi( binfo , moves , movesPP , ninfo , nstats , varargin )
%testTErrVSisi This function computes the ratio of the difference in time
%of error encoding vs. the difference in ISI, for two groups comprised of
%Short and Long ISI. If the ratio is above a pre-determined threshold, then
%neurons are deemed more "movement-related" than "error-related", and
%removed from further error analyses.
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxErrorGrade = ((abs([ninfo.errGrade]) >= 0.5) & ~isnan([nstats.A_ChcErr_tErr_ISIshort]));

idxKeep = (idxArea & idxMonkey & idxErrorGrade);

ninfo = ninfo(idxKeep);

NUM_CELLS = length(ninfo);
medISI_ISIsh = NaN(1,NUM_CELLS); %median ISI for short-ISI group
medISI_ISIlo = NaN(1,NUM_CELLS); %median ISI for long-ISI group

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RTkk = double(moves(kk).resptime);
  ISIkk = double(movesPP(kk).resptime) - RTkk;
  ISIkk(ISIkk < 0) = NaN;
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxFast = (binfo(kk).condition == 3 & ~idxIso);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %index by ISI
  ISI_FastErr = ISIkk(idxFast & idxErr);
  medISI_FastErr = nanmedian(ISI_FastErr);
  idxISIsh = (ISI_FastErr <= medISI_FastErr);
  idxISIlo = (ISI_FastErr >  medISI_FastErr);
  
  medISI_ISIsh(cc) = median(ISI_FastErr(idxISIsh));
  medISI_ISIlo(cc) = median(ISI_FastErr(idxISIlo));
  
  ccNS = ninfo(cc).unitNum;
  dtErr_ccNS = nstats(ccNS).A_ChcErr_tErr_ISIlong - nstats(ccNS).A_ChcErr_tErr_ISIshort;
  dtISI = medISI_ISIlo(cc) - medISI_ISIsh(cc);
  nstats(ccNS).A_ChcErr_dtErr_vs_dISI = dtErr_ccNS / dtISI;
  
end%for:neuron(cc)

dISI = medISI_ISIlo - medISI_ISIsh;
dTErr = [nstats(idxKeep).A_ChcErr_tErr_ISIlong] - [nstats(idxKeep).A_ChcErr_tErr_ISIshort];

if (nargout > 0)
  varargout{1} = nstats;
end
%% Plotting

figure(); hold on
histogram(dTErr./dISI, 'BinWidth',.1)
ppretty([6,5])

end%function:testTErrVSisi()

