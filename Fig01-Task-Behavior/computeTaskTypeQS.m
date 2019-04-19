function [ binfo ] = computeTaskTypeQS( binfo )
%computeTaskTypeQS Summary of this function goes here
%   Detailed explanation goes here

sessMonk = find(ismember({binfo.monkey}, 'S'));
NUM_SESSION = length(sessMonk);

errRateA = NaN(1,NUM_SESSION);
errRateF = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  kkBINFO = sessMonk(kk);
  
  idxAcc = (binfo(kkBINFO).condition == 1);
  idxFast = (binfo(kkBINFO).condition == 3);
  
  idxErr = (binfo(kkBINFO).err_dir);
  
  errRateA(kk) = sum(idxAcc & idxErr) / sum(idxAcc);
  errRateF(kk) = sum(idxFast & idxErr) / sum(idxFast);
  
end%for:session(kk)

%compute avg error rate across conditions
errRateAVG = mean([errRateA ; errRateF]);
fprintf('Error rate: %g +/- %g\n', mean(errRateAVG), std(errRateAVG)/sqrt(NUM_SESSION))

%split sessions on median avg error rate
errRateMED = median(errRateAVG);
fprintf('Median: %g\n', errRateMED)

sessTT1 = find(errRateAVG <= errRateMED);  numTT1 = length(sessTT1);
sessTT2 = find(errRateAVG > errRateMED);   numTT2 = length(sessTT2);

for kk = 1:numTT1
  binfo(sessMonk(sessTT1(kk))).taskType = 1;
end
for kk = 1:numTT2
  binfo(sessMonk(sessTT2(kk))).taskType = 2;
end

end%util:computeTaskTypeQS()

