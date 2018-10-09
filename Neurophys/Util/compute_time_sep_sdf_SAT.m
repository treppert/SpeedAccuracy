function [ T_SEP_SDF ] = compute_time_sep_sdf_SAT( sdf_1 , sdf_2 , varargin )
%compute_time_sep_sdf_SAT Summary of this function goes here
%   Detailed explanation goes here
%   args.alpha -- Alpha for the Mann-Whitney U-test
%   args.min_length -- Minimum number of consecutive samples with a
%       rejection of the null hypothesis

args = getopt(varargin, {{'alpha=',.05},{'min_length=',10}});

DEBUG = true;

[~,NUM_SAMP] = size(sdf_1);

H_MANNWHITNEY = false(1,NUM_SAMP);
for ii = 1:NUM_SAMP
  [~,H_MANNWHITNEY(ii)] = ranksum(sdf_1(:,ii), sdf_2(:,ii), 'alpha',args.alpha, 'tail','both');
end%for:samples(ii)

samp_H_1 = find(H_MANNWHITNEY);
dsamp_H_1 = diff(samp_H_1);
NUM_DSAMP = length(dsamp_H_1);

T_SEP_SDF = NaN;

if (NUM_DSAMP < args.min_length)
  fprintf('***Warning -- Very small number of samples with difference in SDFs\n')
  return
end

for ii = 1:(NUM_DSAMP-args.min_length+1)
  if (sum(dsamp_H_1(ii:ii+args.min_length-1)) == args.min_length)
    T_SEP_SDF = samp_H_1(ii);
    break
  end
end%for:num-dsamp-estimates(ii)

if isnan(T_SEP_SDF)
  fprintf('***Warning -- Did not find a suitable time of separation of SDFs\n')
elseif (DEBUG)
  figure(); hold on
  tmp = [nanmean(sdf_1),nanmean(sdf_2)]; ylim = [min(tmp), max(tmp)];
  plot(nanmean(sdf_1), 'b-')
  plot(nanmean(sdf_2), 'm-')
  plot(T_SEP_SDF*ones(1,2), ylim, 'k:')
end

end%util:compute_time_sep_sdf_SAT()

