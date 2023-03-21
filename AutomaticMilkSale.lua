--
-- automaticMilkSale
--
-- @author  nilBrain
-- @date 	24.06.2022
-- @node	This Script do sold atomaticly Milk from Husbandry.
-- @update	Call "EconomyManager" from the Instance not from the Class, add debug func, call Animals over Method...

automaticMilkSale = {};

function automaticMilkSale:loadMap(mapFilename)
	if g_currentMission:getIsServer() then
		g_messageCenter:subscribe(MessageType.HOUR_CHANGED, self.hourChanged, self);
	end;
end;

function automaticMilkSale:deleteMap()
	if g_currentMission:getIsServer() then
		g_messageCenter:unsubscribe(MessageType.HOUR_CHANGED, self)
	end;
end;

function automaticMilkSale:sellMilk()
	for _, placeable in ipairs(g_currentMission.husbandrySystem.placeables) do
		if placeable:getAnimalTypeIndex() == AnimalType.COW then
			if placeable:getNumOfAnimals() > 0 then
				local fillType = g_fillTypeManager:getFillTypeIndexByName("milk");
				local fillLevel = placeable:getHusbandryFillLevel(fillType);
				placeable:removeHusbandryFillLevel(nil, fillLevel, fillType);
				local price = fillLevel * g_currentMission.economyManager:getPricePerLiter(fillType);
				g_currentMission:addMoney(price, placeable:getOwnerFarmId(), MoneyType.SOLD_MILK, true, true);
			end;
		end;
	end;
	return 0;
end;

function automaticMilkSale:hourChanged()
	local currentHour = g_currentMission.environment.currentHour

	if currentHour == 6 then
		self:sellMilk();
	end;
end;

addModEventListener(automaticMilkSale);