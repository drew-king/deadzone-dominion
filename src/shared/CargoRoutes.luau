local CargoRoutes = {}
CargoRoutes.GroundDropperZ={18,6,-31,-42}

CargoRoutes.Nodes = {
	{"BeltAnnex", "Conveyor Annex", 30, 1, "EXTENDS THE BELT · OPENS FOUNDRY SPACE", "Production"},
	{"BeltDispatch", "Dispatch Extension", 65, 1, "EXTENDS THE BELT · OPENS REACTOR SPACE", "BeltAnnex"},
	{"RefineryBelt", "Refinery Conveyor", 180, 2, "BUILDS A NEW FLOOR TWO LINE"},
	{"RefineryDropper", "Alloy Pellet Dropper", 320, 2, "ADDS A SECOND SOURCE OF CARGO", "RefineryBelt"},
	{"RefineryFinish", "Dispatch Polisher", 450, 2, "+25% VALUE FOR REFINERY CARGO", "RefineryDropper"},
	{"CargoLift", "Floor Three Cargo Lift", 900, 3, "SENDS REFINERY CARGO UPSTAIRS · +35% VALUE", "RefineryFinish"},
}

CargoRoutes.Annex = {Vector3.new(-22,.94,-26),Vector3.new(-22,.94,-36)}
CargoRoutes.Dispatch = {Vector3.new(-22,.94,-36),Vector3.new(-22,.94,-47)}
CargoRoutes.Refinery = {Vector3.new(-23,13.34,8),Vector3.new(-23,13.34,-15),
	Vector3.new(22,13.34,-15),Vector3.new(22,13.34,-42)}
CargoRoutes.Lift = {Vector3.new(22,13.34,-42),Vector3.new(22,28.25,-42),Vector3.new(13,28.25,-42),Vector3.new(13,25.34,-42)}

function CargoRoutes.points(upgrades, start, refinery)
	if refinery then
		local route = table.clone(CargoRoutes.Refinery)
		if upgrades.CargoLift then
			for index = 2, #CargoRoutes.Lift do table.insert(route,CargoRoutes.Lift[index]) end
		end
		return route
	end
	local route = {Vector3.new(-22,.94,start)}
	if start > -26 then table.insert(route,CargoRoutes.Annex[1]) end
	if (upgrades.BeltAnnex or upgrades.BeltDispatch) and start > -36 then table.insert(route,CargoRoutes.Annex[2]) end
	if upgrades.BeltDispatch then table.insert(route,CargoRoutes.Dispatch[2]) end
	return route
end

return CargoRoutes
