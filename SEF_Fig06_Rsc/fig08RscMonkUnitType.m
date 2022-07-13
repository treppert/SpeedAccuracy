function [ ] = fig08RscMonkUnitType( rscData , monkeys , unitTypes )

nSubplots = numel(unitTypes);
plotNo = 0;

idxMonkey = ismember(rscData.monkey, monkeys);

for ut = 1:numel(unitTypes)
  useNeuronType = unitTypes{ut};
  monkData = rscData(idxMonkey,:);

  plotNo = plotNo + 1;
  subplot(1,nSubplots,plotNo);
  
  doRscBarPlots(monkData, useNeuronType)
end

drawnow

end
