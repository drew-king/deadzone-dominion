local PetAppearance = {}

local bodies = {
	Vector3.new(1.32, .85, 1.52),
	Vector3.new(1.24, 1.02, 1.35),
	Vector3.new(.92, .94, 1.34),
	Vector3.new(1.18, .94, 1.63),
	Vector3.new(1.32, 1.05, 1.56),
	Vector3.new(1.27, 1.30, 1.12),
}

function PetAppearance.build(pet, tier)
	local model = Instance.new("Model")
	model.Name = pet.Name
	local main = pet.Color
	local dark = main:Lerp(Color3.fromRGB(22, 30, 62), .77)
	local cream = Color3.fromRGB(255, 246, 217)
	local light = main:Lerp(cream, .46)
	local block = Enum.PartType.Block
	local size = bodies[tier]
	local height, front = size.Y * .5, -size.Z * .5
	local function piece(name, dimensions, color, offset, kind)
		local part = Instance.new("Part")
		part.Name, part.Size, part.Color = name, dimensions, color
		part.Shape, part.CFrame = kind or Enum.PartType.Ball, offset
		part.Material, part.Anchored = Enum.Material.SmoothPlastic, true
		part.CanCollide, part.CanTouch, part.CanQuery, part.CastShadow = false, false, false, false
		part.Parent = model
		return part
	end
	local body = piece("Body", size, main, CFrame.identity, if tier == 2 or tier == 6 then block else nil)
	for _, side in {-1, 1} do
		piece("Eye", Vector3.new(.36, .43, .25), cream, CFrame.new(side * .25, .15, front + .095))
		piece("Pupil", Vector3.new(.18, .22, .14), dark, CFrame.new(side * .25, .12, front - .04))
		piece("Foot", Vector3.new(.34, .28, .48), dark, CFrame.new(side * .4, -height + .02, -.22))
		if tier == 1 then
			piece("Antenna", Vector3.new(.14, .53, .16), light, CFrame.new(side * .28, height + .18, -.27) * CFrame.Angles(0, 0, -side * .32))
		elseif tier == 2 then
			piece("FoldedEar", Vector3.new(.34, .68, .33), dark, CFrame.new(side * .52, height + .14, .01) * CFrame.Angles(0, 0, -side * .36))
		elseif tier == 3 then
			piece("MothWing", Vector3.new(1.15, .57, .27), light, CFrame.new(side * .83, .23, .27) * CFrame.Angles(0, side * .24, side * .38))
		elseif tier == 4 then
			piece("HoundEar", Vector3.new(.29, .62, .27), light, CFrame.new(side * .34, height + .15, -.35) * CFrame.Angles(0, 0, -side * .17))
			piece("RearPaw", Vector3.new(.37, .31, .46), dark, CFrame.new(side * .41, -height + .01, .49))
		elseif tier == 5 then
			piece("DrakeWing", Vector3.new(1.24, .74, .22), main:Lerp(cream, .25), CFrame.new(side * .96, .18, .31) * CFrame.Angles(0, side * .38, side * .57), block)
			piece("Horn", Vector3.new(.19, .40, .22), cream, CFrame.new(side * .37, height + .17, -.23) * CFrame.Angles(0, 0, -side * .25))
		else
			piece("ShoulderArmor", Vector3.new(.48, .55, .65), dark, CFrame.new(side * .77, .29, .03) * CFrame.Angles(0, 0, side * .20), block)
		end
	end
	if tier == 1 then
		piece("Carapace", Vector3.new(1.05, .29, 1.05), light, CFrame.new(0, height - .05, .18))
	elseif tier == 2 or tier == 4 or tier == 5 then
		piece("Muzzle", Vector3.new(.62, .25, .48), light, CFrame.new(0, -.17, front -.03))
		piece("Tail", Vector3.new(.32, .33, .77), dark, CFrame.new(0, .01, -front + .17) * CFrame.Angles(-.37, 0, 0))
		if tier == 5 then
			piece("TailSpade", Vector3.new(.28, .28, .30), cream,
				CFrame.new(0, .14, -front + .49) * CFrame.Angles(0, 0, math.pi / 4), block)
			piece("CrownCore", Vector3.new(.27, .27, .22), cream, CFrame.new(0, .43, front + .04)).Material = Enum.Material.Neon
		end
	elseif tier == 6 then
		piece("HoverSkirt", Vector3.new(1.56, .26, 1.25), dark, CFrame.new(0, -height + .13, 0), block)
		for _, side in {-1, 1} do
			piece("CrownProng", Vector3.new(.24, .45, .36), light,
				CFrame.new(side * .48, height + .12, .03) * CFrame.Angles(0, 0, -side * .24), block)
		end
		piece("HoverCore", Vector3.new(.38, .36, .34), cream, CFrame.new(0, height + .13, .03)).Material = Enum.Material.Neon
	end

	if pet.Power == "JuggerJigg" then
		for _, side in {-1, 1} do
			piece("Speaker", Vector3.new(.34, .46, .50), dark, CFrame.new(side * .64, .06, -.08), block)
		end
	elseif pet.Power == "Spam-Him-Up" then
		piece("TurboFin", Vector3.new(.22, .63, .65), light, CFrame.new(0, height, .38) * CFrame.Angles(-.34, 0, 0), block)
	elseif pet.Power == "Double Pop" then
		for _, side in {-1, 1} do
			piece("TwinTank", Vector3.new(.34, .66, .34), cream, CFrame.new(side * .37, height, .42))
		end
	elseif pet.Power == "Rising Sun" then
		piece("SolarDisc", Vector3.new(.78, .78, .16), light, CFrame.new(0, height + .04, .50))
	elseif pet.Power == "SlurperAid" then
		for _, side in {-1, 1} do
			piece("Sprout", Vector3.new(.22, .58, .28), light, CFrame.new(side * .20, height + .09, .23) * CFrame.Angles(0, 0, -side * .62))
		end
	elseif pet.Power == "PlopperFizz" then
		piece("Bubble", Vector3.new(.54, .54, .54), light, CFrame.new(.27, height + .18, .45))
		piece("SmallBubble", Vector3.new(.28, .28, .28), cream, CFrame.new(-.25, height + .08, .51))
	elseif pet.Power == "CritShot" then
		piece("Sight", Vector3.new(.44, .21, .35), cream, CFrame.new(0, height + .1, -.41), block)
		piece("SightBase", Vector3.new(.18, .23, .22), dark, CFrame.new(0, height, -.40), block)
	elseif pet.Power == "PolarBear Kick" then
		piece("IceShard", Vector3.new(.36, .58, .36), light, CFrame.new(.34, height + .10, .38) * CFrame.Angles(0, .44, -.25), block)
	end
	if (pet.Variant or 1) == 2 then
		local face = front * (if tier == 2 or tier == 6 then 1 else .80)
		for _, side in {-1, 1} do
			piece("CheekMark", Vector3.new(.21, .12, .19), cream, CFrame.new(side * size.X * .33, -.11, face))
		end
	end
	model.WorldPivot = CFrame.identity
	return model, body
end

return PetAppearance
