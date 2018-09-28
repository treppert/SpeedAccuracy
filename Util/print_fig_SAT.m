function [  ] = print_fig_SAT( ninfo_cc , curr_fig , format )
%print_fig_SAT Summary of this function goes here
%   Detailed explanation goes here

if sum(ismember(format, '-dtiff'))
  file_ext = '.tif';
elseif sum(ismember(format, '-depsc2'))
  file_ext = '.eps';
else
  error('Input "format" must either be "-dtiff" or "-depsc2"')
end

print(curr_fig, ['~/Dropbox/tmp/',ninfo_cc.sesh,'-',ninfo_cc.unit,file_ext], format)

end%util:print_fig_SAT()

