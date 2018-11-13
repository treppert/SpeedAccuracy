function [ ] = plot_distr_t_error( t_sep , sign )
%plot_distr_t_error Summary of this function goes here
%   Detailed explanation goes here

idx_sacc_facilitated = ismember({sign.sacc}, {'E'});
idx_sacc_suppressed = ismember({sign.sacc}, {'C'});

idx_rew_facilitated = ismember({sign.rew}, {'E'});
idx_rew_suppressed = ismember({sign.rew}, {'C'});

tsep_facil_sacc = sort(t_sep.sacc(idx_sacc_facilitated));
tsep_facil_rew  = sort(t_sep.rew(idx_rew_facilitated));
tsep_supp_sacc = sort(t_sep.sacc(idx_sacc_suppressed));
tsep_supp_rew  = sort(t_sep.rew(idx_rew_suppressed));

yy_facil_rew = (1:sum(idx_rew_facilitated)) / sum(idx_rew_facilitated);
yy_supp_rew = (1:sum(idx_rew_suppressed)) / sum(idx_rew_suppressed);
yy_facil_sacc = (1:sum(idx_sacc_facilitated)) / sum(idx_sacc_facilitated);
yy_supp_sacc = (1:sum(idx_sacc_suppressed)) / sum(idx_sacc_suppressed);

%% Plotting

figure(); hold on %modulation from primary saccade
plot(tsep_supp_sacc, yy_supp_sacc, '--', 'Color',[0 .7 0])
plot(tsep_facil_sacc, yy_facil_sacc, '-', 'Color',[0 .7 0])
ppretty()

pause(0.25)

figure(); hold on %modulation from reward
plot(tsep_supp_rew, yy_supp_rew, '--', 'Color','r')
plot(tsep_facil_rew, yy_facil_rew, '-', 'Color','r')
ppretty()

end%fxn:plot_distr_t_error()

