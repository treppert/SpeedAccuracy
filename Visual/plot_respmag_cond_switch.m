function [  ] = plot_respmag_cond_switch( visresp_A2F , visresp_F2A , ninfo )
%plot_respmag_cond_switch Summary of this function goes here
%   Inputs are outputs from fxn plot_visresp_cond_switch()

[NUM_TRIALS, NUM_CELLS] = size(visresp_A2F);
% COLOR_PLOT = linspace(0.6, 0.0, NUM_TRIALS);
MIN_GRADE = 3; %minimum grade for visual response

respmag_A2F = NaN(NUM_TRIALS,NUM_CELLS);
respmag_F2A = NaN(NUM_TRIALS,NUM_CELLS);

%% Compute response magnitude vs trial

for kk = 1:NUM_CELLS
  if (ninfo(kk).vis < MIN_GRADE); continue; end
  
  for jj = 1:NUM_TRIALS
    
    sdf_A2F = mean(visresp_A2F{jj,kk});
    sdf_F2A = mean(visresp_F2A{jj,kk});
    
    respmag_A2F(jj,kk) = mean(sdf_A2F(200:300));
    respmag_F2A(jj,kk) = mean(sdf_F2A(200:300));
    
  end%for:trials(jj)
  
  %normalization
  respmag_F2A(:,kk) = respmag_F2A(:,kk) / mean(respmag_A2F(:,kk));
  respmag_A2F(:,kk) = respmag_A2F(:,kk) / mean(respmag_A2F(:,kk));
  
end%for:cells(kk)

%% Plot response magnitude vs trial

NUM_SEM = sum([ninfo.vis] >= MIN_GRADE);

X_A2F = (-NUM_TRIALS:-1);
X_F2A = (0:NUM_TRIALS-1);

figure(); hold on

% plot(X_A2F, respmag_A2F, 'k-')
% plot(X_F2A, respmag_F2A, 'k-')
errorbar_no_caps(X_A2F, nanmean(respmag_A2F,2), 'err',nanstd(respmag_A2F,0,2)/sqrt(NUM_SEM), 'color','k')
errorbar_no_caps(X_F2A, nanmean(respmag_F2A,2), 'err',nanstd(respmag_F2A,0,2)/sqrt(NUM_SEM), 'color','k')

ppretty('image_size',[3.2,2])

end%function:plot_respmag_cond_switch()

