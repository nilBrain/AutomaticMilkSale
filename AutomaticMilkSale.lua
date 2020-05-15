--
-- AutomaticMilkSale
--
-- @author  nilBrain
-- @date  11/12/18
-- @node This Script do sold atomaticly Milk from Husbandry.
-- @update Call "EconomyManager" from the Instance not from the Class, add debug func, call Animals over Method...

AutomaticMilkSale = {
	info = {
        Author = "nilBrain",
        interface = " 1.5.1.0",
        title = " AutomaticMilkSale",
        notes = " Animal Script",
        version = ".1.0.0.0",
        date = " 11.12.2018",
        update = " 05.05.20",
        info = " This Script do sold atomaticly Milk from Husbandry",
	}
};

function AutomaticMilkSale:logInfo(s, ...)
	if self.debug then
		print(string.format(s, ...));
	end;
end;


function AutomaticMilkSale:loadMap(mapFilename)
	if g_currentMission:getIsServer() then
		g_currentMission.environment:addDayChangeListener(self);
		addConsoleCommand("nbMilkSaleDebug", "", "consoleComandMilkSaleDebug", self);
	end;
	self.milkLevel = 0;
	self.debug = false;
end;

function AutomaticMilkSale:deleteMap()
	if g_currentMission:getIsServer() then
		g_currentMission.environment:removeDayChangeListener(self);
		removeConsoleCommand("nbMilkSaleDebug");
	end;
end;


function AutomaticMilkSale:sellMilk(farmID)
	g_currentMission:addMoney(self:canMilkSale(farmID) * g_currentMission.economyManager:getPricePerLiter(g_fillTypeManager:getFillTypeIndexByName("milk")), farmID, MoneyType.SOLD_MILK, true);
	self:canMilkSale(farmID, true);
end;


function AutomaticMilkSale.hasAnimal(husbandry)
	return #husbandry:getModuleByName("animals").animals > 0;
end;


function AutomaticMilkSale:canMilkSale(farmID, reset)
	for _, husbandry in pairs(g_currentMission.husbandries) do
		if husbandry:getModuleByName("animals").animalType:lower() == "cow" then
			if husbandry:getOwnerFarmId() == farmID then
				if self.hasAnimal(husbandry) then
					if reset then
						husbandry:getModuleByName("milk"):setFillLevel(g_fillTypeManager:getFillTypeIndexByName("milk"), 0);
					end;
					local fillLevel = husbandry:getModuleByName("milk"):getFillLevel(g_fillTypeManager:getFillTypeIndexByName("milk"));
					self:logInfo('husbandry:getModuleByName("milk").getFillLevel(16) = %i', fillLevel);
					return fillLevel;
				end;
			end;
		end;
	end;
	return 0;
end;


function AutomaticMilkSale:dayChanged()
	for farmID in pairs(g_farmManager.farms) do
		self:logInfo("MilkDebug[%i] = {\n \t milkLevel = %0.2f L \n \t priceScale = %0.2f per Liter \n \t price = %0.2f Euro/L \n };", 
					farmID, self:canMilkSale(farmID), g_currentMission.economyManager:getPricePerLiter(g_fillTypeManager:getFillTypeIndexByName("milk")), 
					self:canMilkSale(farmID) * g_currentMission.economyManager:getPricePerLiter(g_fillTypeManager:getFillTypeIndexByName("milk")));
		
		if self:canMilkSale(farmID) > 0 then
			self:sellMilk(farmID);
		end;
	end;
end;

function AutomaticMilkSale:consoleComandMilkSaleDebug()
	self.debug = not self.debug;
	return "Milk Debug = " .. tostring(self.debug);
end;
addModEventListener(AutomaticMilkSale)
