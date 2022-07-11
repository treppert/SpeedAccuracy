function [ anovaTbl ] = fig08RscMonkUnitType( rscData , monkeys , cellArrUnitTypes)
%fig08RscMonkUnitType() Summary of this function goes here

anovaTbl = struct();

nSubplots = sum(cellfun(@(x) numel(x),cellArrUnitTypes));
plotNo = 0;
for mm = 1:numel(monkeys)
    monkey = monkeys{mm};
    if strcmp(monkey,'Da_Eu')
        monkIdx = true(size(rscData,1),1);
    else
        monkIdx = ismember(rscData.monkey,monkey(1));
    end

    unitTypes = cellArrUnitTypes{mm};
    for un = 1:numel(unitTypes)
        useNeuronType = unitTypes{un};
        monkData = rscData(monkIdx,:);

        plotNo = plotNo + 1;
        subplot(1,nSubplots,plotNo);
        
        temp = doRscBarPlots(monkData,monkey,useNeuronType);
        if ~isempty(temp)
            anovaTbl.(monkey).(useNeuronType) = temp;
        else
            plotNo = plotNo - 1;
        end
    end

end % for : monkey (mm)

ppretty([6 4])
drawnow

end % fxn : fig08RscMonkUnitType()
