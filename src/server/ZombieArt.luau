local Art = require(script.Parent.FactoryArt)
local ink = Color3.fromRGB(34, 46, 65)
local beacon = Color3.fromRGB(255, 169, 67)

return function(parent, name, data)
	local model = Instance.new("Model")
	model.Name = name
	local scale = data.Scale * 1.37
	local function piece(label, x, y, z, w, h, d, color)
		local p = Art.detail(model, label, CFrame.new(x * scale, y * scale, z * scale), Vector3.new(w, h, d)*scale, color, Enum.Material.SmoothPlastic)
		p.CanQuery = true
		p.CanCollide = false
		return p
	end
	local chest = piece("Jacket", 0, 2.15, 0, 1.8, 1.5, 1.03, data.Color:Lerp(ink, .47))
	piece("Face", 0, 3.23, -.09, 1.1, 1.04, .91, data.Color)
	for _, side in {-1, 1} do
		piece("Boot", side*.49, .51, -.06, .75, 1.02, 1, ink)
		piece("Arm", side*1.19, 2.16, -.17, .54, 1.4, .59, data.Color)
		piece("Eye", side*.24, 3.33, -.57, .22, .12, .09, beacon).Material = Enum.Material.Neon
	end
	if name == "Runner" then
		piece("RunnerCrest", 0, 3.96, .06, .37, .55, .9, beacon)
	elseif name == "Spitter" then
		piece("AcidTank", 0, 2.31, .74, 1.3, 1.35, .66, data.Color).Material = Enum.Material.Neon
	elseif name == "Saboteur" then
		piece("CircuitPack", 0, 2.22, .67, 1.51, 1.51, .56, data.Color).Material = Enum.Material.Neon
	elseif name == "Bruiser" or name == "Abomination" then
		for _, side in {-1, 1} do piece("Armor", side*1.19, 2.96, 0, .81, .67, 1.2, data.Color) end
	end
	local label = Instance.new("BillboardGui")
	label.Name, label.Size = "Threat", UDim2.fromOffset(112, 24)
	label.StudsOffsetWorldSpace, label.MaxDistance = Vector3.new(0, 2.5*scale, 0), 48
	label.Adornee, label.Parent = chest, model
	local text = Instance.new("TextLabel")
	text.BackgroundColor3, text.BackgroundTransparency = ink, .2
	text.Size, text.TextColor3 = UDim2.fromScale(1, 1), Color3.new(1, 1, 1)
	text.TextSize, text.Font, text.Text = 13, Enum.Font.GothamBold, name
	text.Parent = label
	model.Parent = parent
	return model, text
end
