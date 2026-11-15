local ProductionModel = {}

function ProductionModel.estimate(config, upgrades, rebirths, express)
	local output, tiers, speed, mult = config.BaseYield, 1, 13, 1
	for slot,key in {"Production","Foundry","Reactor"} do
		if upgrades[key] then output,tiers=config.Yields[key],slot+1 end
	end
	for _,row in config.Floor do
		local key,_,_,effect=table.unpack(row)
		if not upgrades[key] then continue end
		if effect=="machine" then output+=12
		elseif effect=="rail" then speed+=3
		elseif effect=="scanner" then mult+=.1 end
	end
	if upgrades.AlloyPress then output+=35 end
	if upgrades.ReturnLane then speed+=8 end
	if upgrades.PrismRefiner then mult+=.25 end
	if upgrades.CrownUplink then mult+=.15 end
	if upgrades.FluxHopper then output+=18 end
	if upgrades.PhaseRollers then speed+=5 end
	if upgrades.GradeSensor then mult+=.12 end
	if upgrades.RoutingConsole then
		if express.RoutingConsole then speed+=10 else output+=30 end
	end
	for _,floor in config.Expansion do
		if not upgrades[floor.Access] then continue end
		for _,row in floor.Nodes do
			local key,_,_,effect,amount,expressSpeed=table.unpack(row)
			if not upgrades[key] then continue end
			if effect=="Base" then output+=amount
			elseif effect=="Speed" then speed+=amount
			elseif effect=="Multiplier" or effect=="Capstone" then mult+=amount
			elseif effect=="Routing" then
				if express[key] then speed+=expressSpeed else output+=amount end
			end
		end
	end
	local base=output*mult*(1+.2*rebirths)
	local refinery=if upgrades.RefineryDropper then base*.55*(if upgrades.RefineryFinish then 1.25 else 1)
		*(if upgrades.CargoLift then 1.35 else 1) else 0
	return base,refinery,speed,tiers
end

return ProductionModel
