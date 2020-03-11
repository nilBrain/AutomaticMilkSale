--
-- AutomaticMilkSale
--
-- @author  nilBrain
-- @date  11/12/18
-- @node This Script do sold atomaticly Milk from Husbandry.
--

AutomaticMilkSale = {
	info = {
        Author = "nilBrain",
        interface = " 1.5.1.0",
        title = " AutomaticMilkSale",
        notes = " Animal Script",
        version = ".1.0.0.0",
        date = " 11.12.2018",
        update = " --.--.--",
        info = " This Script do sold atomaticly Milk from Husbandry",
	}
};

function AutomaticMilkSale:loadMap(mapFilename)
	g_currentMission.environment:addDayChangeListener(self);
	addConsoleCommand("nbMilkSaleDebug", "", "consoleComandMilkSaleDebug", self);
	self.milkLevel = 0;
	self.debug = false;
end;

function AutomaticMilkSale:deleteMap()
	g_currentMission.environment:removeDayChangeListener(self);
	removeConsoleCommand("nbMilkSaleDebug");
end;


function AutomaticMilkSale:sellMilk()
	g_currentMission:addMoney(self:canMilkSale() * EconomyManager:getPricePerLiter(16), g_currentMission.player.farmId, MoneyType.SOLD_MILK);
	self:canMilkSale(true);
end;


function AutomaticMilkSale.hasAnimal(husbandry)
	return #husbandry.modulesByName.animals.animals > 0;
end;


function AutomaticMilkSale:canMilkSale(reset)
	for _, husbandry in pairs(g_currentMission.husbandries) do
		if husbandry.modulesByName.animals.animalType:lower() == "cow" then
			if husbandry.modulesByName.animals.owner.ownerFarmId == g_currentMission.player.farmId then
				if self.hasAnimal(husbandry) then
					if reset then
						husbandry.modulesByName.milk.fillLevels[16] = 0;
					end;
					return husbandry.modulesByName.milk.fillLevels[16];
				end;
			end;
		end;
	end;
	return 0;
end;


function AutomaticMilkSale:dayChanged()
	if self.debug then
		print(("MilkDebug = {\n \t milkLevel = %0.2f L \n \t priceScale = %0.2f per Liter \n \t price = %0.2f Euro/L \n };"):format(self:canMilkSale(),EconomyManager:getPricePerLiter(16),self:canMilkSale()*EconomyManager:getPricePerLiter(16)));
	end;
	if self:canMilkSale() > 0 then
		self:sellMilk();
	end
end;

function AutomaticMilkSale:consoleComandMilkSaleDebug()
	self.debug = not self.debug;
	return "Milk Debug = " .. tostring(self.debug);
end;
addModEventListener(AutomaticMilkSale)
