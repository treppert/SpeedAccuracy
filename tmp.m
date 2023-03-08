%tmp.m

N = 4368;

Condition = cell(N,1);
Outcome = cell(N,1);

for nn = 1:N
  if regexp(spkCorr.condition{nn}, 'Accurate')
    Condition{nn} = 'Accurate';
  elseif regexp(spkCorr.condition{nn}, 'Fast')
    Condition{nn} = 'Fast';
  end
end

for nn = 1:N
  if regexp(spkCorr.condition{nn}, 'Correct')
    Outcome{nn} = 'Correct';
  elseif regexp(spkCorr.condition{nn}, 'ErrorChoice')
    Outcome{nn} = 'ErrorChoice';
  elseif regexp(spkCorr.condition{nn}, 'ErrorTiming')
    Outcome{nn} = 'ErrorTiming';
  end
end

fxnType_Da = readtable('C:\Users\Thomas Reppert\Dropbox\SAT-Local\Correlation-SAT-SEF.xlsx', ...
  'Sheet','Da-Fast', 'Range','F8:F77');
