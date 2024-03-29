%%draw a dummy graph
  objGr = getEmptyGraph();
%  objGr.Edges.Weight = randi(20,[size(objGr.Edges,1),1]);
% % 
%  h = plotGraph(objGr);

%% Read and trim data for network graph
% allSpkCorr = load('dataProcessed/satSefPaper/rscSubSampl1K_PostSaccade.mat');
allSpkCorr = load('dataProcessed/satSefPaper/rscSubSampl1K_PostSaccade_0_TrialsThresh.mat');
% output dir 
oPdfDir = 'dataProcessed/satSefPaper/Figures/fig08/networkGraph';
if ~exist(oPdfDir,'dir')
    mkdir(oPdfDir);
end
% significant spk corr values
allSpkCorr = allSpkCorr.spkCorr;
% recode error neurons
allSpkCorr.isSefErrorUnit = abs(allSpkCorr.X_errGrade) > 1 | abs(allSpkCorr.X_rewGrade) > 1;
% recode sat and outcome
allSpkCorr.satCondition = regexprep(allSpkCorr.condition,{'Correct','Error.*'},{'',''});
allSpkCorr.outcome = regexprep(allSpkCorr.condition,{'Fast','Accurate'},{'',''});
% spike count corr sign
allSpkCorr.plusRho(allSpkCorr.rhoRaw > 0) = 1;
allSpkCorr.minusRho(allSpkCorr.rhoRaw < 0) = 1;

%% Filter 
signifVals = [1 0];
for sv = 1:numel(signifVals)

signifVal = signifVals(sv);
if signifVal == 1
    signifStr = 'SignifRsc';
    spkCorr = allSpkCorr(allSpkCorr.signifRaw_05 == 1,:);
else
    signifStr = 'NonSignifRsc';
    spkCorr = allSpkCorr(allSpkCorr.signifRaw_05 == 0,:);
end

idxErr = spkCorr.isSefErrorUnit == 1 ...
      & ismember(spkCorr.outcome,{'Correct','ErrorChoice','ErrorTiming'}); 
spkCorr = spkCorr(idxErr,{'X_monkey','X_sess','satCondition','outcome','X_unitNum','Y_unitNum','Y_area','plusRho','minusRho'});
spkCorr = sortrows(spkCorr,{'X_unitNum','satCondition','outcome','Y_area','plusRho','minusRho'});

%% For each SEF error unit, find how many FEF or SC units they are connected to
[emptyGraph] = getEmptyGraph();
filterOptions = {'sessions','Da_Eu','Da','Eu'};
satConds = {'Fast','Accurate'};
outcomes = {'Correct','ErrorChoice','ErrorTiming'};

for fo = 1:numel(filterOptions)    
    filterOption = filterOptions{fo};
    switch filterOption
        case 'Da_Eu'
            figTitleStr = 'Da_Eu All Sessions';
            spkCorrCellArr = {spkCorr};
        case 'Da'
            figTitleStr = 'Da All Sessions';
            spkCorrCellArr = {spkCorr(ismember(spkCorr.X_monkey,'D'),:)};
        case 'Eu'
            figTitleStr = 'Eu All Sessions';
            spkCorrCellArr = {spkCorr(ismember(spkCorr.X_monkey,'E'),:)};
        case 'sessions'
            figTitleStr = [];
            sessions = unique(spkCorr.X_sess);
            spkCorrCellArr = cellfun(@(x) spkCorr(ismember(spkCorr.X_sess,x),:),...
                sessions,'UniformOutput',false);
    end
    
    for ca = 1:numel(spkCorrCellArr)
        
        spkCorr2Use = spkCorrCellArr{ca};
        sessName = unique(spkCorr2Use.X_sess);
        sessName = sessName{1};
        if isempty(figTitleStr)
            figTitle = sprintf('Session-%s',sessName);
        else
            figTitle = figTitleStr;
        end
        fprintf('Doing network graph for %s\n',figTitle);
        
        outStruct = struct();
        for sc = 1:numel(satConds)
            satCondition = satConds{sc};
            for oc = 1:numel(outcomes)
                connGraph = emptyGraph;
                outcome = outcomes{oc};
                idxSat = ismember(spkCorr2Use.satCondition,satCondition);
                if strcmp(outcome,'ErrorChoice_ErrorTiming')
                    idxOutcome = ones(size(spkCorr2Use,1),1);
                else
                    idxOutcome = ismember(spkCorr2Use.outcome,outcome);
                end
                countTbl = spkCorr2Use(idxSat & idxOutcome,{'X_unitNum','Y_unitNum','Y_area','plusRho','minusRho'});
                sumTbl = grpstats(countTbl,{'X_unitNum','Y_unitNum','Y_area'},{'sum'});
                
                sefErrUnits = unique(sumTbl.X_unitNum,'stable');
                for un = 1:numel(sefErrUnits)
                    unitNum = sefErrUnits(un);
                    unitTbl = sumTbl(sumTbl.X_unitNum == unitNum,:);
                    if numel(unique(unitTbl.Y_area)) == 2 % unit is connected to both FEF and SC
                        srcNodeP = 'SEF2FEF_SC_P';
                        srcNodeM = 'SEF2FEF_SC_M';
                        % FEF target
                        idxSrcPlus = connGraph.findedge(srcNodeP,'FEF_Plus');
                        idxTargPlus =  find(ismember(unitTbl.Y_area,'FEF') & unitTbl.sum_plusRho > 0);
                        if idxTargPlus
                            connGraph.Edges.Weight(idxSrcPlus) = connGraph.Edges.Weight(idxSrcPlus) + sum(unitTbl.sum_plusRho(idxTargPlus));
                            connGraph.Edges.fefUnitNum{idxSrcPlus} = unique([connGraph.Edges.fefUnitNum{idxSrcPlus}; unitTbl.Y_unitNum(idxTargPlus)]);
                            connGraph.Edges.sefUnitNum{idxSrcPlus} = unique([connGraph.Edges.sefUnitNum{idxSrcPlus}; unitNum]);
                        end
                        idxSrcMinus = connGraph.findedge(srcNodeM,'FEF_Minus');
                        idxTargMinus =  find(ismember(unitTbl.Y_area,'FEF') & unitTbl.sum_minusRho > 0);
                        if idxTargMinus
                            connGraph.Edges.Weight(idxSrcMinus) = connGraph.Edges.Weight(idxSrcMinus) + sum(unitTbl.sum_minusRho(idxTargMinus));
                            connGraph.Edges.fefUnitNum{idxSrcMinus} = unique([connGraph.Edges.fefUnitNum{idxSrcMinus}; unitTbl.Y_unitNum(idxTargMinus)]);
                            connGraph.Edges.sefUnitNum{idxSrcMinus} = unique([connGraph.Edges.sefUnitNum{idxSrcMinus}; unitNum]);
                        end
                        % SC target
                        idxSrcPlus = connGraph.findedge(srcNodeP,'SC_Plus');
                        idxTargPlus =  find(ismember(unitTbl.Y_area,'SC') & unitTbl.sum_plusRho > 0);
                        if idxTargPlus
                            connGraph.Edges.Weight(idxSrcPlus) = connGraph.Edges.Weight(idxSrcPlus) + sum(unitTbl.sum_plusRho(idxTargPlus));
                            connGraph.Edges.scUnitNum{idxSrcPlus} = unique([connGraph.Edges.scUnitNum{idxSrcPlus}; unitTbl.Y_unitNum(idxTargPlus)]);
                            connGraph.Edges.sefUnitNum{idxSrcPlus} = unique([connGraph.Edges.sefUnitNum{idxSrcPlus}; unitNum]);
                        end
                        idxSrcMinus = connGraph.findedge(srcNodeM,'SC_Minus');
                        idxTargMinus =  find(ismember(unitTbl.Y_area,'SC') & unitTbl.sum_minusRho > 0);
                        if idxTargMinus
                            connGraph.Edges.Weight(idxSrcMinus) = connGraph.Edges.Weight(idxSrcMinus) + sum(unitTbl.sum_minusRho(idxTargMinus));
                            connGraph.Edges.scUnitNum{idxSrcMinus} = unique([connGraph.Edges.scUnitNum{idxSrcMinus}; unitTbl.Y_unitNum(idxTargMinus)]);
                            connGraph.Edges.sefUnitNum{idxSrcMinus} = unique([connGraph.Edges.sefUnitNum{idxSrcMinus}; unitNum]);
                        end
                    else % unit is connected to either FEF or SC
                        targNodePre = unitTbl.Y_area{1};
                        srcNodeP = ['SEF2' targNodePre '_P'];
                        srcNodeM = ['SEF2' targNodePre '_M'];
                        % FEF or SC target
                        idxSrcPlus = connGraph.findedge(srcNodeP,[targNodePre '_Plus']);
                        idxTargPlus =  find(ismember(unitTbl.Y_area,targNodePre) & unitTbl.sum_plusRho > 0);
                        if idxTargPlus
                            connGraph.Edges.Weight(idxSrcPlus) = connGraph.Edges.Weight(idxSrcPlus) + sum(unitTbl.sum_plusRho(idxTargPlus));
                            if strcmp(targNodePre,'FEF')
                                connGraph.Edges.fefUnitNum{idxSrcPlus} = unique([connGraph.Edges.scUnitNum{idxSrcPlus}; unitTbl.Y_unitNum(idxTargPlus)]);
                            elseif strcmp(targNodePre,'SC')
                                connGraph.Edges.scUnitNum{idxSrcPlus} = unique([connGraph.Edges.scUnitNum{idxSrcPlus}; unitTbl.Y_unitNum(idxTargPlus)]);
                            end
                            connGraph.Edges.sefUnitNum{idxSrcPlus} = unique([connGraph.Edges.sefUnitNum{idxSrcPlus}; unitNum]);
                        end
                        idxSrcMinus = connGraph.findedge(srcNodeM,[targNodePre '_Minus']);
                        idxTargMinus =  find(ismember(unitTbl.Y_area,targNodePre) & unitTbl.sum_minusRho > 0);
                        if idxTargMinus
                            connGraph.Edges.Weight(idxSrcMinus) = connGraph.Edges.Weight(idxSrcMinus) + sum(unitTbl.sum_minusRho(idxTargMinus));
                            if strcmp(targNodePre,'FEF')
                                connGraph.Edges.fefUnitNum{idxSrcMinus} = unique([connGraph.Edges.scUnitNum{idxSrcMinus}; unitTbl.Y_unitNum(idxTargMinus)]);
                            elseif strcmp(targNodePre,'SC')
                                connGraph.Edges.scUnitNum{idxSrcMinus} = unique([connGraph.Edges.scUnitNum{idxSrcMinus}; unitTbl.Y_unitNum(idxTargMinus)]);
                            end
                            connGraph.Edges.sefUnitNum{idxSrcMinus} = unique([connGraph.Edges.sefUnitNum{idxSrcMinus}; unitNum]);
                        end
                        
                    end
                    
                end
                outStruct.(satCondition).(outcome).connGraph = connGraph;
                outStruct.(satCondition).(outcome).countTbl = countTbl;
            end % outcomes
        end % satConds
        
        %% plot network graph for [all, ErrorChoice, ErrorTiming] for fast and accurate
        plotAllObjectGraphs(outStruct,satConds,outcomes);
        % TODO Figure title
        titleSuffix = 'Pairs where pval for Rsc is **significant**';
        if contains(signifStr,'Non')
         titleSuffix = 'Pairs where pval for Rsc is NOT significant';
        end
        annotation('textbox','String',[figTitle ' - ' titleSuffix],'Interpreter','none',...
            'FontSize',18,'FontWeight','bold','LineStyle','none',...
            'Position', [0.2 0.9 0.8 0.1]);
        
        fname =  [regexprep(figTitle,' ', '-') '_NetworkPlot_' signifStr '.pdf'];
        fn = fullfile(oPdfDir,fname);
        %print(fn,'-fillpage','-dpdf','-painters')
        h_fig = saveFigPdf(fn);
        delete(h_fig);
    end % for each spkCorrCellArr
end % filterOptions
end % for pval signif = 1 or 0

%%
function [] = plotAllObjectGraphs(outStruct,satConds,outcomes)
    H_axes = figTemplate(2,3);
    plotNo = 0;
    for sc = 1:numel(satConds)
        satCondition = satConds{sc};
        for oc = 1:numel(outcomes)
            outcome = outcomes{oc};
            objGraph = outStruct.(satCondition).(outcome).connGraph;
            plotNo = plotNo + 1;
            axes(H_axes(plotNo)); %#ok<*LAXES>
            plotGraph(objGraph);
            title([satCondition ' - ' outcome],'FontSize',12,'FontWeight','bold','Interpreter','none');
        end
    end
end


function [h_graph] = plotGraph(objGr)
%lw = scaleVector(objGr.Edges.Weight,1,10);
% remoce all edges with 0 weight (ie no connections)
inValidEdgeIdx = find(objGr.Edges.Weight == 0);
objGr = objGr.rmedge(inValidEdgeIdx); %
h_graph = plot(objGr,'XData',objGr.Nodes.xPos,'YData',objGr.Nodes.yPos,....
    'Interpreter','None','NodeLabel',{});
%set(h_graph,'Marker','s','MarkerSize',20,'NodeColor',[0.5 0.5 0.5])
bgColor = get(gcf,'Color');
set(get(h_graph,'Parent'),'XColor',bgColor,'YColor',bgColor)
set(get(h_graph,'Parent'),'XTick',[],'YTick',[]);

if size(objGr.Edges,1) == 0
    objGr = getEmptyGraph();
else
    set(h_graph,...
        'LineStyle',objGr.Edges.lineStyle,...
        'LineWidth',objGr.Edges.Weight,...
        'EdgeColor',cell2mat(objGr.Edges.edgeColor),...
        'EdgeLabel',objGr.Edges.Weight);
end

%% annotation of nodes
edgesTbl = objGr.Edges;
%% SEF to FEF
uniqUnits = [];
% sef to fef Plus
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2FEF_P'));
unitNos = [];
if sum(idx) > 0
    unitNos = edgesTbl.sefUnitNum{idx}; %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txt = sprintf('+Rsc FEF -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
text(0.85,3.4,txt,'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8);
% sef to fef Minus
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2FEF_M'));
unitNos = [];
if sum(idx) > 0
    unitNos = edgesTbl.sefUnitNum{idx};
end
uniqUnits = [uniqUnits;unitNos(:)];
txt = sprintf('-Rsc FEF -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
text(0.85,2.8,txt,'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8);
% Label node with number of unique units
text(0.85,3.05,{'SEF to FEF';sprintf('(%d)',numel(unique(uniqUnits)))},'Rotation',90,'HorizontalAlignment','center','VerticalAlignment','top','FontWeight','bold');

%% SEF to FEF and SC
% + RSC for FEF
uniqUnits = [];
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2FEF_SC_P') & contains(edgesTbl.EndNodes(:,2),'FEF_P'));
unitNos = [];
if sum(idx) > 0
    unitNos = edgesTbl.sefUnitNum{idx}; %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txtf = sprintf('+Rsc FEF -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2FEF_SC_P') & contains(edgesTbl.EndNodes(:,2),'SC_P'));
unitNos = [];
if sum(idx) > 0
    unitNos = edgesTbl.sefUnitNum{idx}; %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txts = sprintf('+Rsc SC -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
txt = {txtf;txts};
text(0.85,2.5,txt,'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8);

% SEF to FEF and SC Minus
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2FEF_SC_M') & contains(edgesTbl.EndNodes(:,2),'FEF_M'));
unitNos = [];
if sum(idx) > 0
    unitNos = edgesTbl.sefUnitNum{idx}; %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txtf = sprintf('-Rsc FEF -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2FEF_SC_M') & contains(edgesTbl.EndNodes(:,2),'SC_M'));
unitNos = [];
if sum(idx) > 0
    unitNos = edgesTbl.sefUnitNum{idx}; %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txts = sprintf('-Rsc SC -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
txt = {txtf;txts};
text(0.85,1.8,txt,'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8);
% Label node with number of unique units
text(0.85,2.05,{'SEF to FEF';sprintf('& SC (%d)',numel(unique(uniqUnits)))},'Rotation',90,'HorizontalAlignment','center','VerticalAlignment','top','FontWeight','bold');

%% SEF to SC
uniqUnits = [];
% sef to SC Plus
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2SC_P'));
unitNos = [];
if sum(idx) > 0
    unitNos = edgesTbl.sefUnitNum{idx}; %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txt = sprintf('+Rsc SC -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
text(0.85,1.4,txt,'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8);
% sef to SC Minus
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2SC_M'));
unitNos = [];
if sum(idx) > 0
    unitNos = edgesTbl.sefUnitNum{idx};
end
uniqUnits = [uniqUnits;unitNos(:)];
txt = sprintf('-Rsc SC -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
text(0.85,0.8,txt,'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8);
% Label node with number of unique units
text(0.85,1.05,{'SEF to SC';sprintf('(%d)',numel(unique(uniqUnits)))},'Rotation',90,'HorizontalAlignment','center','VerticalAlignment','top','FontWeight','bold');

%% FEF connections to SEF
uniqUnits = [];
% Plus Rsc
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2FEF_P') & contains(edgesTbl.EndNodes(:,2),'FEF_P'));
unitNos = []; %#ok<*NASGU>
if sum(idx) > 0
    unitNos = vertcat(edgesTbl.fefUnitNum{idx}); %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txt1 = sprintf('+Rsc to FEF -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2FEF_SC_P') & contains(edgesTbl.EndNodes(:,2),'FEF_P'));
unitNos = [];
if sum(idx) > 0
    unitNos = vertcat(edgesTbl.fefUnitNum{idx}); %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txt2 = sprintf('+Rsc to FEF & SC -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
text(1.6,2.9,{txt1;txt2},'Rotation',0,'HorizontalAlignment','left','VerticalAlignment','bottom','FontSize',8);
% Minus Rsc
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2FEF_M') & contains(edgesTbl.EndNodes(:,2),'FEF_M'));
unitNos = [];
if sum(idx) > 0
    unitNos = vertcat(edgesTbl.fefUnitNum{idx}); %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txt1 = sprintf('-Rsc to FEF -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2FEF_SC_M') & contains(edgesTbl.EndNodes(:,2),'FEF_M'));
unitNos = [];
if sum(idx) > 0
    unitNos = vertcat(edgesTbl.fefUnitNum{idx}); %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txt2 = sprintf('-Rsc to FEF & SC -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
text(1.6,2.25,{txt1;txt2},'Rotation',0,'HorizontalAlignment','left','VerticalAlignment','top','FontSize',8);
% Label node with number of unique units
text(2.15,2.55,{'FEF';sprintf('(%d)',numel(unique(uniqUnits)))},'Rotation',90,'HorizontalAlignment','center','VerticalAlignment','bottom','FontWeight','bold');

%% SC connections to SEF
uniqUnits = [];
% Plus Rsc
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2SC_P') & contains(edgesTbl.EndNodes(:,2),'SC_P'));
unitNos = [];
if sum(idx) > 0
    unitNos = vertcat(edgesTbl.scUnitNum{idx}); %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txt1 = sprintf('+Rsc to SC -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2FEF_SC_P') & contains(edgesTbl.EndNodes(:,2),'SC_P'));
unitNos = [];
if sum(idx) > 0
    unitNos = vertcat(edgesTbl.scUnitNum{idx}); %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txt2 = sprintf('+Rsc to FEF & SC -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
text(1.7,1.8,{txt2;txt1},'Rotation',0,'HorizontalAlignment','left','VerticalAlignment','bottom','FontSize',8);
% Minus Rsc
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2SC_M') & contains(edgesTbl.EndNodes(:,2),'SC_M'));
unitNos = [];
if sum(idx) > 0
    unitNos = vertcat(edgesTbl.scUnitNum{idx}); %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txt1 = sprintf('-Rsc to SC -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
idx = (contains(edgesTbl.EndNodes(:,1),'SEF2FEF_SC_M') & contains(edgesTbl.EndNodes(:,2),'SC_M'));
unitNos = [];
if sum(idx) > 0
    unitNos = vertcat(edgesTbl.scUnitNum{idx}); %#ok<*FNDSB>
end
uniqUnits = [uniqUnits;unitNos(:)];
txt2 = sprintf('-Rsc to FEF & SC -> %s (%d)', getUnitNosTxt(unitNos),numel(unitNos));
text(1.7,1.1,{txt2;txt1},'Rotation',0,'HorizontalAlignment','left','VerticalAlignment','bottom','FontSize',8);
% Label node with number of unique units
text(2.15,1.55,{'SC';sprintf('(%d)',numel(unique(uniqUnits)))},'Rotation',90,'HorizontalAlignment','center','VerticalAlignment','bottom','FontWeight','bold');

end

function [str] = getUnitNosTxt(unitNos)
   str = '[]';
   if ~isempty(unitNos)
     str = num2str(unitNos(:)','%d,');
     str = ['[' str(1:end-1) ']'];
   end
   
end

%%
function [hA] = figTemplate(ros,cols)
    figure;
    set(gcf,'Color',[1 1 1],'Position',[50 50 1500 900],'PaperOrientation','landscape');
    hA = tight_subplot(ros, cols, [.1 .1],[0.07 0.07],[0.07 0.07]);
    for ii = 1:numel(hA)
        axes(hA(ii))
        title(sprintf('Plot %d',ii));
    end
end

%%
function [emptyGraph] = getEmptyGraph()
nodeNames = {
     'SEF2FEF_P'   
     'SEF2FEF_M'      
     'SEF2FEF_SC_P'
     'SEF2FEF_SC_M'
     'SEF2SC_P'    
     'SEF2SC_M'    
     'FEF_Plus'  
     'FEF_Minus'
     'SC_Plus' 
     'SC_Minus' 
    };
nodePositions = [
    1,3.1
    1,3.0
    1,2.1
    1,2.0
    1,1.1
    1,1.0
    2,2.6
    2,2.5
    2,1.6
    2,1.5];
nodesTbl = cell2table(nodeNames,'VariableNames',{'nodeName'});
nodesTbl.nodeId = (1:size(nodesTbl,1))';
srcNodeIds = [1 2 3 4 3 4 5 6];% lookup into node Ids
targNodeIds = [7 8 7 8 9 10 9 10];% lookup into nodeIds
weights = [0 0 0 0 0 0 0 0]; % counts 
tempArr = {
    'SEF2FEF_P','FEF_Plus','SEF error unit to FEF: positive Rsc';
    'SEF2FEF_M','FEF_Minus','SEF error unit to FEF: negative Rsc';
    'SEF2FEF_SC_P','FEF_Plus','SEF error unit to FEF and SC: FEF-positive Rsc';
    'SEF2FEF_SC_M','FEF_Minus','SEF error unit to FEF and SC: FEF-negative Rsc';
    'SEF2FEF_SC_P','SC_Plus','SEF error unit to FEF and SC: SC-positive Rsc';
    'SEF2FEF_SC_M','SC_Minus','SEF error unit to FEF and SC: SC-negative Rsc';
    'SEF2SC_P','SC_Plus','SEF error unit to SC: positive Rsc';
    'SEF2SC_M','SC_Minus','SEF error unit to SC: negative Rsc';
    };
emptyGraph = graph(srcNodeIds,targNodeIds,weights,nodesTbl.nodeName);
% count of nodes
emptyGraph.Edges.sefUnitNum = repmat({[]},numel(weights),1);
emptyGraph.Edges.fefUnitNum = repmat({[]},numel(weights),1);
emptyGraph.Edges.scUnitNum = repmat({[]},numel(weights),1);

% linestyle
emptyGraph.Edges.lineStyle = repmat({'-'},numel(weights),1);
idxMinus = contains(emptyGraph.Edges.EndNodes(:,2),'Minus');
emptyGraph.Edges.lineStyle(idxMinus) = repmat({'-'},sum(idxMinus),1);
% edgecolor
emptyGraph.Edges.edgeColor = repmat({[0 0 1]},numel(weights),1);
emptyGraph.Edges.edgeColor(idxMinus) = repmat({[1 0 1]},sum(idxMinus),1);
% comments
emptyGraph.Edges.Comment = tempArr(:,3);
% node positions on graph
emptyGraph.Nodes.xPos = nodePositions(:,1);
emptyGraph.Nodes.yPos = nodePositions(:,2);

% % emptyGraph = 
% % 
% %   graph with properties:
% % 
% %     Edges: [8�5 table]
% %     Nodes: [10�3 table]
% % 
% % emptyGraph.Nodes
% % 
% % ans =
% % 
% %   10�3 table
% % 
% %          Name         xPos    yPos
% %     ______________    ____    ____
% % 
% %     'SEF2FEF_P'        1      3.1 
% %     'SEF2FEF_M'        1        3 
% %     'SEF2FEF_SC_P'     1      2.1 
% %     'SEF2FEF_SC_M'     1        2 
% %     'SEF2SC_P'         1      1.1 
% %     'SEF2SC_M'         1        1 
% %     'FEF_Plus'         2      2.6 
% %     'FEF_Minus'        2      2.5 
% %     'SC_Plus'          2      1.6 
% %     'SC_Minus'         2      1.5 
% % 
% % emptyGraph.Edges
% % 
% % ans =
% % 
% %   8�5 table
% % 
% %               EndNodes               Weight    lineStyle     edgeColor                          Comment                     
% %     _____________________________    ______    _________    ____________    ________________________________________________
% % 
% %     'SEF2FEF_P'       'FEF_Plus'       0          '-'       [1�3 double]    'SEF error unit to FEF: positive Rsc'           
% %     'SEF2FEF_M'       'FEF_Minus'      0          ':'       [1�3 double]    'SEF error unit to FEF: negative Rsc'           
% %     'SEF2FEF_SC_P'    'FEF_Plus'       0          '-'       [1�3 double]    'SEF error unit to FEF and SC: FEF-positive Rsc'
% %     'SEF2FEF_SC_P'    'SC_Plus'        0          '-'       [1�3 double]    'SEF error unit to FEF and SC: FEF-negative Rsc'
% %     'SEF2FEF_SC_M'    'FEF_Minus'      0          ':'       [1�3 double]    'SEF error unit to FEF and SC: SC-positive Rsc' 
% %     'SEF2FEF_SC_M'    'SC_Minus'       0          ':'       [1�3 double]    'SEF error unit to FEF and SC: SC-negative Rsc' 
% %     'SEF2SC_P'        'SC_Plus'        0          '-'       [1�3 double]    'SEF error unit to SC: positive Rsc'            
% %     'SEF2SC_M'        'SC_Minus'       0          ':'       [1�3 double]    'SEF error unit to SC: negative Rsc'   
% %
end


function [vecScaled] = scaleVector(vec,minLim, maxLim)    %#ok<*DEFNU>
     minVec = min(vec);
     maxVec = max(vec);
     vecScaled = (vec - minVec)./(maxVec-minVec);
     vecScaled = (maxLim-minLim) * vecScaled + minLim;
end