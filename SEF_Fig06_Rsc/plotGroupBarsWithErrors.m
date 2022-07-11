function [ barCenters ] = plotGroupBarsWithErrors( yMean , yErr , varargin )


argParser = inputParser();
argParser.addParameter('groupColors',{[255 0 0];[0 180 0]});
argParser.addParameter('yLim',[]);

argParser.parse(varargin{:});
args = argParser.Results;

grpColors = args.groupColors;% mustbe between 0-1
yLim = args.yLim;

x = (1:3);
hBar = bar(x,yMean,'FaceAlpha',0.6,'BarWidth',0.9);
if ~isempty(grpColors)
    set(hBar(1),'FaceColor',grpColors{1}./255);
    set(hBar(2),'FaceColor',grpColors{2}./255);
end
xticks([])
ylabel('R_{sc}');
if ~isempty(yLim); set(gca,'Ylim',yLim); end

set(gca,'FontWeight','bold','FontSize',8);
hold on
for k1 = 1:size(yMean,2)
    barCenters(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
end
errorbar(barCenters,yMean',yErr','Marker','none', 'Color','k', 'CapSize',0, 'LineStyle','none');

end % fxn : plotGroupBarsWithErrors()

