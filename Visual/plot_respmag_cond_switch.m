function [ varargout ] = plot_respmag_cond_switch( visresp_A2F , visresp_F2A , latency , ninfo )
%plot_respmag_cond_switch Summary of this function goes here
%   Inputs are outputs from fxn plot_visresp_cond_switch()

NORMALIZE = false;

[NUM_TRIALS, NUM_CELLS] = size(visresp_A2F);
MIN_GRADE = 3; %minimum grade for visual response

TIME_OFFSET = 100; %offset for inputs VR_A2F and VR_F2A
TIME_ASSESS = (1 : 100); %time for avg resp magnitude (re. latency)

respmag_A2F = NaN(NUM_TRIALS,NUM_CELLS);
respmag_F2A = NaN(NUM_TRIALS,NUM_CELLS);

%% Compute response magnitude vs trial

for kk = 1:NUM_CELLS
  if (ninfo(kk).vis < MIN_GRADE); continue; end
  
  for jj = 1:NUM_TRIALS
    
    sdf_A2F = mean(visresp_A2F{jj,kk});
    sdf_F2A = mean(visresp_F2A{jj,kk});
    
    respmag_A2F(jj,kk) = mean(sdf_A2F(TIME_OFFSET + TIME_ASSESS + latency(kk)));
    respmag_F2A(jj,kk) = mean(sdf_F2A(TIME_OFFSET + TIME_ASSESS + latency(kk)));
    
  end%for:trials(jj)
  
end%for:cells(kk)

%normalize response magnitude for each cell to mean response for F2A
if (NORMALIZE)
  respmag_A2F = respmag_A2F ./ mean(respmag_F2A);
  respmag_F2A = respmag_F2A ./ mean(respmag_F2A);
end

if (nargout > 0) %return trial-to-trial modulation of vis response
  
  modulation = struct('A2F',[], 'F2A',[]);
  
  modulation.A2F = diff(respmag_A2F([2,3],:));
  modulation.F2A = diff(respmag_F2A([2,3],:));
  
  varargout{1} = modulation;
  
else
  %% Plot response magnitude vs trial

  NUM_SEM = sum([ninfo.vis] >= MIN_GRADE);

  X_F2A = (-NUM_TRIALS:-1);
  X_A2F = (0:NUM_TRIALS-1);

  figure(); hold on

%   plot(X_F2A, respmag_F2A, 'k-')
%   plot(X_A2F, respmag_A2F, 'k-')
  errorbar_no_caps(X_A2F, nanmean(respmag_A2F,2), 'err',nanstd(respmag_A2F,0,2)/sqrt(NUM_SEM), 'color','k')
  errorbar_no_caps(X_F2A, nanmean(respmag_F2A,2), 'err',nanstd(respmag_F2A,0,2)/sqrt(NUM_SEM), 'color','k')

  xlim([-4.2 , 3.2])
  xticks(-4 : 3)
  xticklabels({'-2','-1','0','+1','-2','-1','0','+1'})

  ppretty('image_size',[3.2,2])
  
end%plot or return

end%function:plot_respmag_cond_switch()

