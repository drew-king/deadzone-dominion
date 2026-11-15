local floor = {
	{"FeedHopper", "Bulk Feed Hopper", 90, "machine", 1},
	{"GuideRails", "Cargo Guide Rails", 110, "rail", 1},
	{"SortingScanner", "Sorting Scanner", 135, "scanner", 1},
	{"ExchangeLights", "Exchange Status Lights", 160, "lights", 1},
	{"FoundryShield", "Foundry Safety Screen", 190, "screen", 1},
	{"CompressionRam", "Compression Ram", 225, "machine", 2},
	{"RollerDrive", "Roller Drive", 275, "rail", 2},
	{"AlloyReader", "Alloy Reader", 330, "scanner", 2},
	{"BayFloodlights", "Bay Floodlights", 400, "lights", 2},
	{"AlloyShield", "Alloy Safety Screen", 475, "screen", 2},
	{"InductionCoil", "Induction Coil", 560, "machine", 3},
	{"MagneticGuides", "Magnetic Guides", 660, "rail", 3},
	{"CoreCalibrator", "Core Calibrator", 775, "scanner", 3},
	{"ReactorBeacons", "Reactor Beacons", 900, "lights", 3},
	{"ReactorShield", "Reactor Safety Screen", 1050, "screen", 3},
	{"QuantumPress", "Quantum Press", 1200, "machine", 4},
	{"ExpressDrive", "Express Drive", 1400, "rail", 4},
	{"ValueAssayer", "Value Assayer", 1625, "scanner", 4},
	{"ExchangeTower", "Exchange Signal Tower", 1850, "lights", 4},
	{"CrownBulkhead", "Crown Bulkhead", 2100, "screen", 4},
}

local config = {
	TickSeconds = 2,
	BaseYield = 5,
	UpgradedYield = 10,
	MaxPending = 5000,
	MaxWallet = 100000000,
	Prices = {Walls = 25, Production = 45, Foundry = 120, Reactor = 300, Arsenal = 550},
	Order = {"Walls", "Production", "Foundry", "Reactor", "Arsenal"},
	Names = {Walls = "Barricade", Production = "Twin Dropper", Foundry = "Plasma Foundry", Reactor = "Reactor Dropper", Arsenal = "Reactor Arsenal"},
	Yields = {Production = 10, Foundry = 24, Reactor = 55},
	RebirthCost = 750,
	Floor = floor,
	Benefits = {Walls = "BASE DEFENSE", Production = "SECOND DROPPER", Foundry = "ION CARBINE", Reactor = "ARC LANCE", Arsenal = "REACTOR BREAKER"},
}
local benefits = {machine = "+12 BASE SCRAP / CARGO", rail = "+3 STUDS/S BELT SPEED",
	scanner = "+0.10 CARGO MULTIPLIER", lights = "LIGHTS THE BAY", screen = "BUILDS A BAY PARTITION"}
for _, row in floor do
	local key, name, price, kind = table.unpack(row)
	table.insert(config.Order, key)
	config.Names[key], config.Prices[key], config.Benefits[key] = name, price, benefits[kind]
end
local floorOneCount = #config.Order
config.Upper = {
	{"AlloyPress", "Alloy Press", 2450, "+35 BASE SCRAP / CARGO"},
	{"ReturnLane", "Upper Return Lane", 2900, "+8 STUDS/S BELT SPEED"},
	{"PrismRefiner", "Prism Refiner", 3500, "+0.25 CARGO MULTIPLIER"},
	{"PrismArmory", "Prism Armory", 4200, "EQUIP PRISM REPEATER AT ARSENAL"},
	{"CrownUplink", "Crown Uplink", 5000, "+0.15 MULTIPLIER / FLOOR 2 MILESTONE"},
	{"FluxHopper", "Flux Hopper", 1200, "+18 BASE SCRAP / CARGO"},
	{"PhaseRollers", "Phase Rollers", 1450, "+5 STUDS/S BELT SPEED"},
	{"GradeSensor", "Alloy Grade Sensor", 1680, "+0.12 CARGO MULTIPLIER"},
	{"RoutingConsole", "Routing Console", 1920, "SWITCH CARGO VALUE OR BELT SPEED"},
	{"RefineryLamps", "Refinery Lamps", 680, "LIGHTS THE REFINERY AISLE"},
	{"CargoAnalyzer", "Cargo Analyzer", 880, "EQUIP A HANDHELD OUTPUT SCANNER"},
	{"RefineryBeacon", "Refinery Beacon", 1080, "LIGHTS THE FRONT REFINERY ROW"},
}
for _, row in config.Upper do
	local key, name, price, benefit = table.unpack(row)
	table.insert(config.Order, key)
	config.Names[key], config.Prices[key], config.Benefits[key] = name, price, benefit
end
config.RebirthUpgrade = "CrownUplink"
config.RebirthStarterCash = 25
config.Branches = {
	{Name = "Production", Keys = {"Production","Foundry","Reactor","FeedHopper","GuideRails","SortingScanner","CompressionRam","RollerDrive","AlloyReader","InductionCoil","MagneticGuides","CoreCalibrator","QuantumPress","ExpressDrive","ValueAssayer","AlloyPress","ReturnLane","PrismRefiner","CrownUplink"}},
	{Name = "Arsenal", Keys = {"IonUnlock","ArcUnlock","Arsenal","PrismArmory"}},
	{Name = "Infrastructure", Keys = {"Walls","ExchangeLights","FoundryShield","BayFloodlights","AlloyShield","ReactorBeacons","ReactorShield","ExchangeTower","CrownBulkhead"}},
}
for _, weapon in {{"IonUnlock","Ion Carbine",125},{"ArcUnlock","Arc Lance",325},{"StarterFactory","Starter Factory",25},{"UpperAccess","Stairs & Upper Deck",180},{"EggMachine","Power Egg Incubator",80},{"ArsenalBench","Arsenal Station",35}} do
	local key, name, price = table.unpack(weapon)
	table.insert(config.Order, floorOneCount + 1, key)
	floorOneCount += 1
	config.Prices[key], config.Names[key], config.Benefits[key] = price, name, "WEAPON UNLOCK"
end
table.insert(config.Branches[1].Keys, 1, "StarterFactory")
table.insert(config.Branches[2].Keys, 1, "ArsenalBench")
table.insert(config.Branches, {Name = "Expansion", Keys = {"UpperAccess"}})
table.insert(config.Branches, {Name = "Pets", Keys = {"EggMachine"}})
table.insert(config.Branches, {Name = "Refinery machinery", Keys = {"FluxHopper", "PhaseRollers", "GradeSensor", "RoutingConsole"}})
table.insert(config.Branches, {Name = "Refinery construction", Keys = {"RefineryLamps", "CargoAnalyzer", "RefineryBeacon"}})
local defense = {Name = "Defense", Keys = {}}
for _, row in require(script.Parent.SiegeConfig).Upgrades do
	local key, name, price, benefit = table.unpack(row)
	floorOneCount += 1
	table.insert(config.Order, floorOneCount, key)
	table.insert(defense.Keys, key)
	config.Prices[key], config.Names[key], config.Benefits[key] = price, name, benefit
end
table.insert(config.Branches, defense)
config.Benefits.Production = "BASE CARGO 5 TO 10 SCRAP"
config.Benefits.Foundry, config.Benefits.Reactor = "BASE CARGO 10 TO 24 SCRAP", "BASE CARGO 24 TO 55 SCRAP"
config.Benefits.Walls = "BUILDS WALLS AND AN 80 HP SIEGE BARRICADE"
config.Benefits.StarterFactory = "ACTIVATE DROPPER, BELT & EXCHANGE"
config.Benefits.UpperAccess = "BUILD FLOOR TWO"
config.Benefits.EggMachine = "BUILD INCUBATOR · FIRST EGG INCLUDED"
config.Benefits.ArsenalBench = "BUILD ARSENAL · EQUIP SCRAP PULSE"
config.Benefits.IonUnlock = "EQUIP ION CARBINE AT ARSENAL"
config.Benefits.ArcUnlock = "EQUIP ARC LANCE AT ARSENAL"
config.Benefits.Arsenal = "EQUIP REACTOR BREAKER AT ARSENAL"
config.FloorByUpgrade = {}
for index, key in config.Order do config.FloorByUpgrade[key] = if index <= floorOneCount then 1 else 2 end
config.Prerequisites = {}
for _, branch in config.Branches do
	for index, key in branch.Keys do config.Prerequisites[key] = branch.Keys[index - 1] end
end
config.Expansion = require(script.Parent.ExpansionFloors)
config.FloorAccess, config.MinimumRebirth, config.NeedsArsenal = {[2] = "UpperAccess"}, {}, {}
for _, floorPlan in config.Expansion do
	local number, access = floorPlan.Number, floorPlan.Access
	config.FloorAccess[number] = access
	config.MinimumRebirth[access] = number - 2
	config.Names[access] = floorPlan.Name .. " Access"
	config.Prices[access] = 1000 * (number - 2)
	config.Benefits[access] = "BUILD STAIRS & FLOOR " .. number
	config.Prerequisites[access] = floorPlan.Prior
	config.FloorByUpgrade[access] = number - 1
	table.insert(config.Order, access)
	table.insert(config.Branches, {Name = floorPlan.Name .. " access", Keys = {access}})
	local groups = {Production = {}, Construction = {}, Arsenal = {}}
	for _, branch in {"Production", "Construction", "Arsenal"} do
		table.insert(config.Branches, {Name = "Floor " .. number .. " " .. branch, Keys = groups[branch]})
	end
	for _, row in floorPlan.Nodes do
		local key, name, price, effect, amount, speed = table.unpack(row)
		local branch = if effect == "Arsenal" then "Arsenal" elseif effect == "Lamp" or effect == "Display" then "Construction" else "Production"
		if effect == "Arsenal" then config.NeedsArsenal[key] = true end
		local keys = groups[branch]
		config.Prerequisites[key] = keys[#keys] or access
		table.insert(keys, key)
		table.insert(config.Order, key)
		config.FloorByUpgrade[key] = number
		config.MinimumRebirth[key] = number - 2
		config.Names[key], config.Prices[key] = name, price
		config.Benefits[key] = if effect == "Base" then "+" .. amount .. " BASE SCRAP / CARGO"
			elseif effect == "Speed" then "+" .. amount .. " STUDS/S BELT SPEED"
			elseif effect == "Multiplier" then "+" .. amount .. " CARGO MULTIPLIER"
			elseif effect == "Routing" then "+" .. amount .. " BASE SCRAP OR +" .. speed .. " SPEED"
			elseif effect == "Lamp" then "LIGHTS THE WORK BAY"
			elseif effect == "Display" then "BUILDS THE MATERIAL EXHIBIT"
			elseif effect == "Arsenal" then "EQUIP " .. string.upper(amount) .. " AT ARSENAL"
			else "+" .. amount .. " MULTIPLIER / " .. (if number == 5 then "FINISH THE TYCOON" else "FLOOR " .. number .. " MILESTONE")
	end
end
for _, row in require(script.Parent.CargoRoutes).Nodes do
	local id, name, price, floorNumber, benefit, prior = table.unpack(row)
	table.insert(config.Order,id)
	config.Prices[id], config.Names[id], config.Benefits[id] = price,name,benefit
	config.FloorByUpgrade[id], config.Prerequisites[id] = floorNumber,prior
end
for _, row in {{"ForgeEggMachine","Forge Egg Incubator",3},{"LabEggMachine","Sovereign Egg Incubator",5}} do
	local id,name,floorNumber=table.unpack(row)
	table.insert(config.Order,id)
	config.Names[id],config.Prices[id],config.Benefits[id]=name,1000,"OPENS A STRONGER POWER EGG"
	config.FloorByUpgrade[id]=floorNumber
end

function config.rebirthRequirement(rebirths)
	local floorPlan = config.Expansion[math.min(rebirths or 0, #config.Expansion)]
	if not floorPlan then return config.RebirthUpgrade, config.RebirthCost, 2 end
	return floorPlan.Nodes[#floorPlan.Nodes][1], floorPlan.RebirthCost, floorPlan.Number
end
function config.canPurchase(upgrades, key, rebirths)
	local prerequisite = config.Prerequisites[key]
	local access = config.FloorAccess[config.FloorByUpgrade[key]]
	return config.Prices[key] ~= nil and not upgrades[key]
		and (rebirths or 0) >= (config.MinimumRebirth[key] or 0)
		and (key == "StarterFactory" or upgrades.StarterFactory == true)
		and (key ~= "UpperAccess" or upgrades.Reactor == true)
		and (key ~= "EggMachine" or upgrades.Production == true)
		and (key ~= "Foundry" or upgrades.BeltAnnex == true)
		and (key ~= "Reactor" or upgrades.BeltDispatch == true)
		and (not config.NeedsArsenal[key] or upgrades.ArsenalBench == true)
		and (not prerequisite or upgrades[prerequisite] == true)
		and (not access or upgrades[access] == true)
end
config.PriceReport=require(script.Parent.UpgradePricing).apply(config)
return config
