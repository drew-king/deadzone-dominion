local roster = {
	{Id="Bolt", Name="Bolt Bug", Rarity="Common", Weight=500, Income=1.05, Damage=1, Color=Color3.fromRGB(151,178,192)},
	{Id="Coil", Name="Coil Pup", Rarity="Uncommon", Weight=265, Income=1.10, Damage=1, Color=Color3.fromRGB(92,225,141)},
	{Id="Flux", Name="Flux Moth", Rarity="Rare", Weight=150, Income=1, Damage=1.15, Color=Color3.fromRGB(88,189,244)},
	{Id="Arc", Name="Arc Hound", Rarity="Epic", Weight=60, Income=1.20, Damage=1, Color=Color3.fromRGB(185,103,250)},
	{Id="Crown", Name="Crown Drake", Rarity="Legendary", Weight=20, Income=1, Damage=1.30, Color=Color3.fromRGB(255,178,65)},
	{Id="Nova", Name="Nova Warden", Rarity="Mythic", Weight=5, Income=1.35, Damage=1, Color=Color3.fromRGB(248,92,110)},
}
local themes = {
	JuggerJigg = {"Bass", "Rhythm", "Echo", Color3.fromRGB(243, 103, 122)},
	["Spam-Him-Up"] = {"Turbine", "Jet", "Gale", Color3.fromRGB(65, 216, 223)},
	["Double Pop"] = {"Twin Charge", "Pop", "Fuse", Color3.fromRGB(255, 137, 63)},
	["Rising Sun"] = {"Solar", "Dawn", "Flare", Color3.fromRGB(255, 211, 88)},
	SlurperAid = {"Bio", "Bloom", "Sprout", Color3.fromRGB(112, 224, 143)},
	PlopperFizz = {"Fizz", "Bubble", "Reagent", Color3.fromRGB(182, 116, 255)},
	CritShot = {"Target", "Scope", "Tracer", Color3.fromRGB(188, 226, 91)},
	["PolarBear Kick"] = {"Glacier", "Snow", "Frost", Color3.fromRGB(148, 212, 255)},
}
local premium = {
	{Id="GiltMoth", Name="Gilt Moth", Rarity="Legendary", Tier=3, Variant=2, Weight=340, Income=1.23, Damage=1, Color=Color3.fromRGB(246,209,106)},
	{Id="CoralCrown", Name="Coral Crown", Rarity="Legendary", Tier=5, Variant=1, Weight=340, Income=1.23, Damage=1, Color=Color3.fromRGB(255,128,161)},
	{Id="QuartzWarden", Name="Quartz Warden", Rarity="Mythic", Tier=6, Variant=2, Weight=160, Income=1.32, Damage=1, Color=Color3.fromRGB(144,224,255)},
	{Id="FoundryMonarch", Name="Foundry Monarch", Rarity="Mythic", Tier=6, Variant=1, Weight=160, Income=1.32, Damage=1, Color=Color3.fromRGB(186,136,251)},
}
for _, entry in premium do table.insert(roster, entry) end
roster.Premium = premium
local shells = {"Beetle", "Pup", "Moth", "Hound", "Drake", "Warden"}
local themesByPlot = {}
for plot, theme in themes do
	local pool = {Name = theme[1] .. " Egg", Color = theme[4], Pets = {}}
	for tier = 1, 6 do
		local base = roster[tier]
		for variant = 1, 2 do
			local entry = table.clone(base)
			entry.Id = theme[1]:gsub(" ", "") .. "_" .. base.Id .. variant
			entry.Name = theme[variant + 1] .. " " .. shells[tier]
			entry.Color = theme[4]:Lerp(base.Color, variant * .22)
			entry.Weight = if variant == 1 then math.ceil(base.Weight / 2) else math.floor(base.Weight / 2)
			entry.Variant, entry.Tier = variant, tier
			entry.Power = plot
			table.insert(pool.Pets, entry)
			table.insert(roster, entry)
		end
	end
	themesByPlot[plot] = pool
	pool.Floors={[1]=pool}
	for _,floor in {3,5} do
		local higher={Name=theme[1]..(if floor==3 then " Forge Egg" else " Sovereign Egg"),Color=theme[4],Pets={}}
		local weights=if floor==3 then {215,145,90,50} else {160,130,115,95}
		for i=1,8 do
			local tier=math.ceil(i/2)+2
			local base=pool.Pets[(tier-1)*2+(i-1)%2+1]
			local upgraded=table.clone(base)
			upgraded.Id="F"..floor.."_"..base.Id
			upgraded.Name=(if floor==3 then "Forged " else "Sovereign ")..base.Name
			upgraded.Weight=weights[math.ceil(i/2)]
			upgraded.Income=math.max(1,base.Income)+ (if floor==3 then .08 else .16)
			upgraded.Color=base.Color:Lerp(if floor==3 then Color3.fromRGB(255,174,89) else Color3.fromRGB(210,154,255),.3)
			table.insert(higher.Pets,upgraded)
			table.insert(roster,upgraded)
		end
		pool.Floors[floor]=higher
	end
end
roster.Themes = themesByPlot
return roster
