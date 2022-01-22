function [ parm_ms , varargout ] = def_mainseq_SAT( moves_all , moves_tr , info )
%[ varargout ] = def_mainseq_SAT( )
global LIM_VIGOR

LIM_VIGOR = [0.6, 1.4];

PLOT_INDIV_SESSION = false;
FXN_DEF_MS = fittype({'x'}); %linear fit

tasks = fieldnames(moves_all);
NUM_TASKS = length(tasks);
NUM_SESSION = length(moves_all.(tasks{1}));


%% **** First round ****

%% Gather main sequence data from all tasks
displacement = [];
peakvel = [];
for jj = 1:NUM_TASKS
  displacement = [displacement, [moves_all.(tasks{jj}).displacement]];
  peakvel = [peakvel, [moves_all.(tasks{jj}).peakvel]];
end

%% Perform first fit of the main sequence
parm_ms = fit(displacement', peakvel', FXN_DEF_MS);

%% Determine vigor of saccades (for cutting)
moves_all = compute_vigor_SAT(moves_all, parm_ms);
moves_tr = compute_vigor_SAT(moves_tr, parm_ms);

%% Remove saccades with vigor outside bounds
for jj = 1:NUM_TASKS
  moves_all.(tasks{jj}) = remove_saccades_x_vigor(moves_all.(tasks{jj}));
  moves_tr.(tasks{jj}) = remove_saccades_x_vigor(moves_tr.(tasks{jj}));
end%for:tasks(jj)


%% **** Second round ****

%% Re-gather main sequence data from all tasks
displacement = [];
peakvel = [];
for jj = 1:NUM_TASKS
  displacement = [displacement, [moves_all.(tasks{jj}).displacement]];
  peakvel = [peakvel, [moves_all.(tasks{jj}).peakvel]];
end

idx_nan = isnan(displacement);
displacement(idx_nan) = [];
peakvel(idx_nan) = [];

%% Re-fit of the main sequence
parm_ms = fit(displacement', peakvel', FXN_DEF_MS);

%% Re-determine vigor of saccades
moves_all = compute_vigor_SAT(moves_all, parm_ms);

%% Plotting

if (PLOT_INDIV_SESSION)
  figure()
  for jj = 1:NUM_TASKS
    for kk = 1:NUM_SESSION
      subplot(4,5,kk); hold on
      plot_mainseq_session(moves_all.(tasks{jj})(kk).displacement, moves_all.(tasks{jj})(kk).peakvel, ...
        parm_ms, FXN_DEF_MS, info.(tasks{jj})(kk)); pause(.2)
    end
  end
  ppretty('image_size',[8,10])
end

%% Output

if (nargout > 1)
  varargout{1} = moves_all;
  if (nargout > 2)
    varargout{2} = moves_tr;
    if (nargout > 3)
      R_ms = corrcoef(peakvel, parm_ms(displacement));
      varargout{3} = R_ms(1,2);
    end
  end
end

end%function:def_mainseq_SAT()

function moves = remove_saccades_x_vigor( moves )
global LIM_VIGOR

NUM_SESSION = length(moves);

for kk = 1:NUM_SESSION
  
  idx_remove = ((moves(kk).vigor < LIM_VIGOR(1)) | (moves(kk).vigor > LIM_VIGOR(2)));
  moves(kk).vigor(idx_remove) = NaN;
  moves(kk).displacement(idx_remove) = NaN;
  moves(kk).peakvel(idx_remove) = NaN;
  
end%for:sessions(kk)

end%util:remove_saccades_x_vigor()

function [] = plot_mainseq_session( disp , peakvel , p_ms , FXN_DEF_MS , info )

xx_plot = [3 12];
plot(disp, peakvel, '.', 'MarkerSize',10, 'Color',.4*ones(1,3))
plot(xx_plot, FXN_DEF_MS(p_ms.a, xx_plot), 'k--', 'LineWidth',1.5)

xlim([0 15]); xticks(0:3:15)
ylim([0 1000]); yticks(0:200:1000)

title(info.session, 'fontsize',8, 'position',[7,25])

end%function:plot_mainseq_session()
