local Builder = {}
local steel = Color3.fromRGB(42, 50, 61)
local concrete = Color3.fromRGB(94, 105, 115)
local amber = Color3.fromRGB(255, 182, 74)

local function part(parent, name, size, frame, color, shape)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color = name, size, frame, color
	p.Anchored = true
	p.Material = Enum.Material.Concrete
	if shape then p.Shape = shape end
	p.Parent = parent
	return p
end

local function sign(partInstance, message, color)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(260, 64)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
	gui.MaxDistance = 105
	gui.Parent = partInstance
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = steel
	label.BackgroundTransparency = 0.15
	label.TextColor3 = color
	label.Text = message
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
	return label
end

function Builder.build(config)
	assert(#config.Plots == 8, "Expected eight plots")
	local root = Instance.new("Folder")
	root.Name = "DeadzonePhase1"
	root:SetAttribute("DeadzoneGenerated", true)
	part(root, "Ground", Vector3.new(720, 12, 720), CFrame.new(0, -6, 0), steel)
	local function disc(name, diameter, height, y, color)
		return part(root, name, Vector3.new(height, diameter, diameter),
			CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.pi / 2), color, Enum.PartType.Cylinder)
	end
	disc("Arena", 145, 0.3, 0.15, concrete)
	disc("ReactorCrown", 34, 4, 2, steel)
	disc("CaptureMarker", 28, 0.12, 4.06, amber)
	local tower = part(root, "ReactorBeacon", Vector3.new(5, 20, 5), CFrame.new(0, 14, 0), amber)
	tower.Material = Enum.Material.Neon
	sign(tower, "REACTOR CROWN", amber)
	for i = 0, 3 do
		local rotation = CFrame.Angles(0, i * math.pi / 2, 0)
		part(root, "ReactorRamp", Vector3.new(9, 0.6, 17),
			rotation * CFrame.new(0, 2, -23) * CFrame.Angles(-math.atan2(4, 16), 0, 0), concrete)
	end
	for i = 0, 7 do
		local radial = CFrame.Angles(0, (i + 0.5) * math.pi / 4, 0)
		part(root, "ArenaCover", Vector3.new(12, 5, 4), radial * CFrame.new(0, 2.8, -43), steel)
	end
	for _, objective in ipairs({{"Supply Yard", 64}, {"Quarantine Relay", -64}}) do
		local marker = part(root, objective[1], Vector3.new(10, 1, 10), CFrame.new(objective[2], 0.65, 0), steel)
		sign(marker, objective[1] .. "\nFuture objective", Color3.new(1, 1, 1))
	end
	local plots = {}
	local names = {}
	for index, info in ipairs(config.Plots) do
		local name, x, z, accent = table.unpack(info)
		assert(not names[name], "Duplicate plot name")
		names[name] = true
		local pivot = Vector3.new(x, 0, z)
		for other = 1, index - 1 do
			local entry = config.Plots[other]
			assert((pivot - Vector3.new(entry[2], 0, entry[3])).Magnitude > config.Footprint.Magnitude, "Plot footprints overlap")
		end
		local frame = CFrame.lookAt(pivot, Vector3.zero)
		local model = Instance.new("Model")
		model.Name = name
		model.Parent = root
		local function localPart(label, size, lx, y, lz, color)
			return part(model, label, size, frame * CFrame.new(lx, y, lz), color)
		end
		local width, depth = config.Footprint.X, config.Footprint.Y
		localPart("Foundation", Vector3.new(width, 0.4, depth), 0, 0.2, 0, concrete)
		local reach = pivot.Magnitude - depth / 2 - 70
		localPart("Approach", Vector3.new(16, 0.2, reach), 0, 0.1, -depth / 2 - reach / 2, concrete)
		localPart("RouteStripe", Vector3.new(0.65, 0.06, reach), 0, 0.23, -depth / 2 - reach / 2, accent)
		for _, side in ipairs({-1, 1}) do
			localPart("SideWall", Vector3.new(2, 12, depth), side * 53, 6.4, 0, steel)
			localPart("FrontWall", Vector3.new(46, 12, 2), side * 30, 6.4, -57, steel)
			localPart("GatePillar", Vector3.new(2, 14, 3), side * 8, 7.4, -57, accent)
			localPart("SpawnScreen", Vector3.new(2, 7, 15), side * 11, 3.9, 41, steel)
		end
		localPart("RearWall", Vector3.new(108, 12, 2), 0, 6.4, 58, steel)
		local gate = localPart("GateHeader", Vector3.new(18, 2, 3), 0, 12, -57, accent)
		local label = sign(gate, string.format("%02d  %s\nAVAILABLE", index, name), accent)
		local motifs = {"SpeakerStacks", "TurbineFins", "TwinCharges", "SolarCrest", "LabCanisters", "ChemicalStacks", "TargetReticle", "IceCrates"}
		local profiles = {{4,7,3}, {2,8,6}, {5,4,4}, {3,9,3}, {3,5,3}, {3,10,3}, {6,2,2}, {5,5,5}}
		local profile = profiles[index]
		for _, side in ipairs({-1, 1}) do
			localPart(motifs[index], Vector3.new(table.unpack(profile)), side * 16, profile[2] / 2 + 0.4, -53, accent)
		end
		local terminal = localPart("ClaimTerminal", Vector3.new(4, 4, 3), -18, 2.4, -47, accent)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText, prompt.ObjectText = "Claim base", name
		prompt.MaxActivationDistance = 10
		prompt.Parent = terminal
		localPart("SpawnPad", Vector3.new(14, 0.2, 12), 0, 0.5, 38, accent)
		local markers = Instance.new("Folder")
		markers.Name = "FutureStations"
		markers.Parent = model
		local stations = {StarterGenerator={-31,19}, ConveyorStart={-22,8}, CurrencyCollector={-17,-29},
			WeaponStation={29,-25}, AbilityStation={29,6}, DefenseTerminal={-38,-34},
			PowerCore={0,0}, UpgradeTerminal={22,30}, Stairs={42,21}}
		for station, offset in pairs(stations) do
			local marker = part(markers, station, Vector3.new(4, 0.06, 4), frame * CFrame.new(offset[1], 0.43, offset[2]), steel)
			marker.CanCollide = false
		end
		model.WorldPivot = frame
		plots[index] = {Name = name, Label = label, Prompt = prompt, Terminal = terminal, Spawn = frame * CFrame.new(0, 4, 38), Index = index, Model = model}
	end
	local lobby = Instance.new("SpawnLocation")
	lobby.Name = "NeutralSpawn"
	lobby.Size = Vector3.new(18, 1, 18)
	lobby.CFrame = CFrame.lookAt(Vector3.new(53, 0.5, -128), Vector3.new(0, 0.5, -260))
	lobby.Anchored, lobby.Neutral = true, true
	lobby.Duration = 6
	lobby.Color = amber
	lobby.Parent = root
	sign(lobby, "CLAIM A BASE\n01 JuggerJigg  /  02 Spam-Him-Up", amber)
	local existing = workspace:FindFirstChild(root.Name)
	if existing then
		assert(existing:GetAttribute("DeadzoneGenerated") == true, "Generated map name is already in use")
		existing:Destroy()
	end
	root.Parent = workspace
	return plots, lobby.CFrame * CFrame.new(0, 4, 0)
end

return Builder
