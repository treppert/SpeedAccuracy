function [ tst ] = compute_TST_MannWhitney( sdf_Tin , sdf_Din , type )
%[ tst ] = compute_TST_MannWhitney( sdf , inTrials , outTrials )
%   Note that we use a one-tailed test to determine if SDF_Tin is greater
%   than SDF_Din

if ~ismember(type, {'correct','error'})
  error('Input "type" not recognized')
end

DEBUG = false;

%time-point to begin assessment
OFFSET_TEST = 100;
% OFFSET_TEST = 80;

if strcmp(type, 'correct')
  ALPHA = 0.01; %Fig. 7 -- correct responses
%   ALPHA = 0.02; %Fig. 8 -- error responses -- comparison
  IDX_TEST = OFFSET_TEST + (1:550);
else
  ALPHA = 0.10; %Fig. 8 -- error responses
  IDX_TEST = OFFSET_TEST + (1:550);
end

NUM_TEST = length(IDX_TEST);

FILT_HALFWIN = 4; %one-sided number of samples to smooth average
MIN_NUM_TRIALS = 2; %minimum number of trials per condition (Tin, Din)
MIN_LENGTH_RUNS = 10;

%% Loop over test points and find those with sig. difference in SDF

h_test = false(1,NUM_TEST);
for jj = 1:NUM_TEST
  
  idx_jj = 3500 + ((IDX_TEST(jj) - FILT_HALFWIN) : (IDX_TEST(jj) + FILT_HALFWIN));
  
  sdf_Tin_jj = mean(sdf_Tin(:,idx_jj),2);
  sdf_Din_jj = mean(sdf_Din(:,idx_jj),2);
  
  if (sum(~isnan(sdf_Tin_jj)) < MIN_NUM_TRIALS); continue; end
  if (sum(~isnan(sdf_Din_jj)) < MIN_NUM_TRIALS); continue; end
  
  [~, h_test(jj)] = ranksum(sdf_Tin_jj, sdf_Din_jj, 'alpha',ALPHA, 'tail','right');
  
end%for:samples(jj)

tst = OFFSET_TEST + min(findRuns(h_test,MIN_LENGTH_RUNS)) - 1;

if isempty(tst); tst = NaN; end

if (DEBUG)
  figure(); hold on
  plot(nanmean(sdf_Tin(:,3500+IDX_TEST-OFFSET_TEST)), 'k-')
  plot(nanmean(sdf_Din(:,3500+IDX_TEST-OFFSET_TEST)), 'k--')
  idx_signif = find(h_test == 1) + OFFSET_TEST;
  plot(idx_signif, 1*ones(1,length(idx_signif)), 'b*')
  plot(tst*ones(1,2), [0 1], '-', 'Color',.4*ones(1,3))
  ppretty()
end

end%function:compute_TST_MannWhitney()

function runIndices = findRuns(runVector,runLength,runValue)

if nargin < 2
  runLength = 10;
  runValue = 1;
end

if nargin < 3
  runValue = 1;
end

block_index = 1;
start_ = 1;
runIndices = [];

while start_ < length(runVector)
  for trl = start_:length(runVector)
    if runVector(trl) == runValue
      start_index = trl;
      while (trl < length(runVector) & runVector(trl) == runValue && runVector(trl + 1) == runValue)
        trl = trl + 1;

        %make sure we do not run out of bounds
        if trl >= length(runVector)
            break
        end
      end
      end_index = trl;

      start_ = end_index + 1;

      if length(start_index:end_index) >= runLength
        runIndices = [runIndices start_index:end_index];
        block_index = block_index + 1;
        break
      end
    end
  end
  %terminate while loop when we hit the end
  if trl == length(runVector)
      %return transpose
      runIndices = runIndices';
      return
  end
end%while()

end%util:findRuns()
