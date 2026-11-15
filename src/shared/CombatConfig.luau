local config = {
	Reach = 110,
	Damage = 25,
	Interval = 0.55,
	StationRange = 12,
	ArenaRadius = 73,
	Weapons = {
		{Name = "Scrap Pulse", Unlock = "ArsenalBench", Damage = 25, Interval = 0.55, Reach = 110, Color = Color3.fromRGB(82, 211, 223)},
		{Name = "Ion Carbine", Unlock = "IonUnlock", Damage = 18, Interval = 0.32, Reach = 95, Color = Color3.fromRGB(99, 237, 146)},
		{Name = "Arc Lance", Unlock = "ArcUnlock", Damage = 38, Interval = 0.85, Reach = 130, Color = Color3.fromRGB(183, 126, 255)},
		{Name = "Reactor Breaker", Unlock = "Arsenal", Damage = 48, Interval = 1.1, Reach = 85, Color = Color3.fromRGB(255, 147, 68)},
		{Name = "Prism Repeater", Unlock = "PrismArmory", Damage = 13, Interval = 0.23, Reach = 75, Color = Color3.fromRGB(218, 121, 250)},
		{Name = "Cinder Carbine", Unlock = "ForgeArms", Damage = 21, Interval = .44, Reach = 84, Color = Color3.fromRGB(255, 104, 72)},
		{Name = "Flux Lance", Unlock = "GridArms", Damage = 34, Interval = .78, Reach = 125, Color = Color3.fromRGB(94, 232, 195)},
		{Name = "Crown Driver", Unlock = "LabArms", Damage = 43, Interval = .97, Reach = 96, Color = Color3.fromRGB(177, 152, 255)},
	},
}
function config.unlocked(upgrades, level)
	local weapon = config.Weapons[level]
	return upgrades and upgrades.ArsenalBench == true and weapon ~= nil and upgrades[weapon.Unlock] == true
end
return config
