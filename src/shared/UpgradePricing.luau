local production = require(script.Parent.ProductionModel)
local pricing = {}
pricing.TargetSeconds={20,20,32,44,56}

function pricing.apply(config)
	local effects = {Production="Income",Foundry="Income",Reactor="Income",AlloyPress="Income",ReturnLane="Speed",
		PrismRefiner="Income",CrownUplink="Income",FluxHopper="Income",PhaseRollers="Speed",GradeSensor="Income",
		RoutingConsole="Income",RefineryDropper="Income",RefineryFinish="Income",CargoLift="Income",
		BeltAnnex="Extension",BeltDispatch="Extension"}
	for _,row in config.Floor do
		effects[row[1]]=({machine="Income",rail="Speed",scanner="Income",lights="Cosmetic"})[row[4]]
	end
	for _,floor in config.Expansion do
		for _,row in floor.Nodes do
			effects[row[1]]=({Base="Income",Multiplier="Income",Capstone="Income",Routing="Income",
				Speed="Speed",Lamp="Cosmetic",Display="Cosmetic"})[row[4]]
		end
	end
	effects.RefineryLamps,effects.RefineryBeacon="Cosmetic","Cosmetic"
	local additional={Foundry="BeltAnnex",Reactor="BeltDispatch",UpperAccess="Reactor",EggMachine="Production"}
	local function include(upgrades,key)
		if not key or upgrades[key] then return end
		upgrades[key]=true
		include(upgrades,config.Prerequisites[key])
		include(upgrades,config.FloorAccess[config.FloorByUpgrade[key]])
		include(upgrades,additional[key])
	end
	local report,last={},{}
	for _,key in config.Order do
		local floor=config.FloorByUpgrade[key]
		local path={StarterFactory=true}
		include(path,config.Prerequisites[key])
		include(path,config.FloorAccess[floor])
		include(path,additional[key])
		if config.NeedsArsenal[key] then include(path,"ArsenalBench") end
		local baseline,upper=production.estimate(config,path,math.max(0,floor-2),{})
		local rate=(baseline+upper)/config.TickSeconds
		local target=pricing.TargetSeconds[floor]
		local effect=effects[key] or "Utility"
		local share=if effect=="Income" then 1 elseif effect=="Extension" then .2
			elseif effect=="Speed" then .55 elseif effect=="Cosmetic" then .45 else .74
		if key=="Foundry" or key=="Reactor" then share=.8 end
		local price=math.max(5,5*math.floor(rate*target*share/5+.5))
		if key=="StarterFactory" then price=config.RebirthStarterCash end
		if key=="ArsenalBench" then price=35 end
		local prior=config.Prerequisites[key]
		local comparable=prior
		while comparable and (effects[comparable]=="Cosmetic" or effects[comparable]=="Extension"
			or config.FloorByUpgrade[comparable]~=floor) do comparable=config.Prerequisites[comparable] end
		if effect~="Cosmetic" and effect~="Extension" and comparable and last[comparable] then
			price=math.max(price,last[comparable]+5)
		elseif effect=="Cosmetic" and prior and last[prior] and effects[prior]=="Cosmetic" then
			price=math.max(price,last[prior]+5)
		end
		config.Prices[key],last[key]=price,price
		report[key]={floor=floor,effect=effect,rate=rate,seconds=target,price=price,estimated=price/rate,
			prior=prior,gate=additional[key] or config.FloorAccess[floor]}
	end
	return report
end

return pricing
