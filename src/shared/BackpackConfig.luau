return {
	Capacity=75,
	BaseSlots=2,
	MaxPreviewTiers=20,
	FirstSlotPrice=1000,
	EggPrices={[1]=375,[3]=2100,[5]=6400},
	Potions={
		Cash={Name="Scrap Tonic", Factor=1.35, Duration=120, Price=180, Color=Color3.fromRGB(90,237,164)},
		Speed={Name="Velocity Tonic", Factor=1.2, Duration=90, Price=140, Color=Color3.fromRGB(80,211,247)},
		Damage={Name="Overcharge Tonic", Factor=1.25, Duration=90, Price=200, Color=Color3.fromRGB(253,131,104)},
		Armor={Name="Guard Tonic", Factor=.75, Duration=90, Price=160, Color=Color3.fromRGB(185,151,250)},
	},
	Count=function(profile)
		local count=0
		for _ in profile.pets do count+=1 end
		for _,doses in (profile.potions or {}) do if doses>0 then count+=1 end end
		return count
	end,
}
