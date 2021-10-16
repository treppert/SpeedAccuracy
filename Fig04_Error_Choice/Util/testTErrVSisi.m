function [ varargout ] = testTErrVSisi( behavData , moves , movesPP , unitData , unitData , varargin )
%testTErrVSisi This function computes the ratio of the difference in time
%of error encoding vs. the difference in ISI, for two groups comprised of
%Short and Long ISI. If the ratio is above a pre-determined threshold, then
%neurons are deemed more "movement-related" than "error-related", and
%removed from further error analyses.
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember(unitData.aArea, args.area);
idxMonkey = ismember(unitData.aMonkey, args.monkey);
idxErrorGrade = ((abs(unitData.Basic_ErrGrade) >= 0.5) & ~isnan([unitData.A_ChcErr_tErr_ISIshort]));

idxKeep = (idxArea & idxMonkey & idxErrorGrade);

unitData = unitData(idxKeep);

NUM_CELLS = length(unitData);
medISI_ISIsh = NaN(1,NUM_CELLS); %median ISI for short-ISI group
medISI_ISIlo = NaN(1,NUM_CELLS); %median ISI for long-ISI group

for uu = 1:NUM_CELLS
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  RTkk = double(moves(kk).resptime);
  ISIkk = double(movesPP(kk).resptime) - RTkk;
  ISIkk(ISIkk < 0) = NaN;
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData(uu,:), behavData.Task_NumTrials{kk});
  %index by condition
  idxFast = (behavData.Task_SATCondition{kk} == 3 & ~idxIso);
  %index by trial outcome
  idxErr = (behavData.Task_ErrChoice{kk} & ~behavData.Task_ErrTime{kk});
  
  %index by ISI
  ISI_FastErr = ISIkk(idxFast & idxErr);
  medISI_FastErr = nanmedian(ISI_FastErr);
  idxISIsh = (ISI_FastErr <= medISI_FastErr);
  idxISIlo = (ISI_FastErr >  medISI_FastErr);
  
  medISI_ISIsh(uu) = median(ISI_FastErr(idxISIsh));
  medISI_ISIlo(uu) = median(ISI_FastErr(idxISIlo));
  
  uuNS = unitData.aIndex(uu);
  dtErr_uuNS = unitData(uuNS).A_ChcErr_tErr_ISIlong - unitData(uuNS).A_ChcErr_tErr_ISIshort;
  dtISI = medISI_ISIlo(uu) - medISI_ISIsh(uu);
  unitData(uuNS).A_ChcErr_dtErr_vs_dISI = dtErr_uuNS / dtISI;
  
end%for:neuron(uu)

dISI = medISI_ISIlo - medISI_ISIsh;
dTErr = [unitData(idxKeep).A_ChcErr_tErr_ISIlong] - [unitData(idxKeep).A_ChcErr_tErr_ISIshort];

if (nargout > 0)
  varargout{1} = unitData;
end
%% Plotting

figure(); hold on
histogram(dTErr./dISI, 'BinWidth',.1)
ppretty([6,5])

end%function:testTErrVSisi()

