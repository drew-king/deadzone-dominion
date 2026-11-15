local Players = game:GetService("Players")
local Art = require(script.Parent.FactoryArt)
local makeZombie = require(script.Parent.ZombieArt)
local tuning = require(game.ReplicatedStorage.Shared.SiegeConfig).Enemies
local Outbreak = {}
local STEP, CAP = .2, 18

local function inZone(zone, position)
	local p = zone.frame:PointToObjectSpace(position)
	return math.abs(p.X) < 12 and math.abs(p.Z) < 32 and p.Y > -.7 and p.Y < 9
end

local function rootOf(player)
	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

function Outbreak.start(plots, options)
	local zones, actors = {}, {}
	local total = 0
	local folder = Instance.new("Folder")
	folder.Name, folder.Parent = "OutdoorOutbreaks", workspace
	for _, plot in plots do
		for _, side in {-1, 1} do
			local frame = plot.Model:GetPivot() * CFrame.new(side * 71, 0, -7)
			local zone = {frame=frame, actors={}, count=0, spawnAt=0, cursor=0,
				kinds=if side < 0 then {"Walker","Runner"} else {"Walker",if plot.Index%2 == 0 then "Spitter" else "Bruiser"}}
			table.insert(zones, zone)
			for _, offset in {-32,32} do
				local plate = Art.detail(folder, "OutbreakBoundary", frame*CFrame.new(0,.09,offset),
					Vector3.new(24,.15,.45),Color3.fromRGB(255,168,67),Enum.Material.Neon)
				local gui = Instance.new("BillboardGui")
				gui.Adornee, gui.Parent, gui.Size = plate, plate, UDim2.fromOffset(164,42)
				gui.StudsOffsetWorldSpace, gui.MaxDistance = Vector3.new(0,3,0), 65
				local label = Instance.new("TextLabel")
				label.Size, label.Parent = UDim2.fromScale(1,1), gui
				label.BackgroundColor3, label.TextColor3 = Color3.fromRGB(36,31,53), Color3.fromRGB(255,213,132)
				label.Font, label.TextSize, label.Text = Enum.Font.GothamBold, 13, "OUTBREAK ZONE\nRetreat beyond the stripe"
			end
			for _, offset in {-12,12} do
				Art.detail(folder, "OutbreakBoundary", frame*CFrame.new(offset,.09,0),
					Vector3.new(.45,.15,64),Color3.fromRGB(255,168,67),Enum.Material.Neon)
			end
		end
	end
	local function remove(actor)
		local zone = actor.zone
		actors[actor.model], zone.actors[actor.model] = nil, nil
		zone.count, total = zone.count-1, total-1
		actor.model:Destroy()
	end

	local function tickZone(zone, now, roots, params)
		local nearby, centerDistance = nil, 65
		local active = {}
		for player, root in roots do
			local distance = (root.Position-zone.frame.Position).Magnitude
			if distance < centerDistance then nearby, centerDistance = root, distance end
			if inZone(zone,root.Position) and options.eligible(player) then active[player] = root end
		end
		if not nearby then
			for _, a in zone.actors do remove(a) end
			return
		end
		if next(active) and zone.count < 2 and total < CAP and now >= zone.spawnAt then
			for _, z in {-25,25} do
				local marker = zone.frame:PointToWorldSpace(Vector3.new(0,2,z))
				local ground = workspace:Raycast(marker,Vector3.new(0,-3,0),params)
				if not ground or ground.Normal.Y < .98 then continue end
				local position = ground.Position + Vector3.yAxis*.05
				local free = true
				for _, root in roots do if (root.Position-position).Magnitude < 25 then free = false; break end end
				if free then
					zone.cursor = zone.cursor%#zone.kinds+1
					local kind = zone.kinds[zone.cursor]
					local data = tuning[kind]
					local model, label = makeZombie(folder,kind,data)
					model:PivotTo(CFrame.new(position))
					model:SetAttribute("Health", data.Health)
					local a = {model=model, label=label, zone=zone, position=position, spawn=position, hp=data.Health,
						kind=kind, data=data, charge=0, attackAt=0, blocked=0}
					zone.actors[model], actors[model] = a,a
					zone.count, total, zone.spawnAt = zone.count+1,total+1,now+8
					break
				end
			end
		end
		for _, a in zone.actors do
			local target, player, closest = nil,nil,35
			for p, root in active do
				local distance = (root.Position-a.position).Magnitude
				if distance < closest then target,player,closest = root,p,distance end
			end
			local aim = if target then target.Position else a.spawn
			local delta = Vector3.new(aim.X-a.position.X,0,aim.Z-a.position.Z)
			local inRange = target and delta.Magnitude <= a.data.Reach and math.abs(target.Position.Y-a.position.Y) < 7
				and not workspace:Raycast(a.position+Vector3.yAxis*3, target.Position-(a.position+Vector3.yAxis*3), params)
			if inRange then
				if now >= a.attackAt then
					if a.charge == 0 then a.charge=now; a.attackAt=now+.6; a.label.Text="INCOMING · "..a.kind
					else
						options.hurt(player,target.Parent:FindFirstChildOfClass("Humanoid"),a.data.Damage)
						a.charge,a.attackAt,a.label.Text=0,now+1.5,a.kind
					end
				end
			else
				a.charge,a.label.Text=0,a.kind
				if delta.Magnitude > .25 then
					local step = delta.Unit*math.min(delta.Magnitude, a.data.Speed*STEP)
					local position = a.position+step
					if inZone(zone,position) and not workspace:Raycast(a.position+Vector3.yAxis*2,step+delta.Unit*.8,params) then
						a.position,a.blocked=position,0
						a.model:PivotTo(CFrame.lookAt(position+Vector3.yAxis*(.1*math.abs(math.sin(now*9))), position+delta.Unit))
					else
						a.blocked+=1
						if a.blocked >= 22 then remove(a); zone.spawnAt=now+12 end
					end
				end
			end
		end
	end

	task.spawn(function()
		while task.wait(STEP) do
			if options.paused() then continue end
			local now, roots = workspace:GetServerTimeNow(), {}
			local ignored = {folder}
			for _, player in Players:GetPlayers() do
				if player.Character then table.insert(ignored,player.Character) end
				roots[player] = rootOf(player)
			end
			local params=RaycastParams.new()
			params.FilterType,params.FilterDescendantsInstances=Enum.RaycastFilterType.Exclude,ignored
			for _, zone in zones do tickZone(zone,now,roots,params) end
		end
	end)
	return {
		canFire = function(player, position)
			if not options.eligible(player) then return false end
			for _, zone in zones do if inZone(zone,position) then return true end end
			return false
		end,
		hit = function(player, model, damage)
			local a, root = actors[model], rootOf(player)
			if not a or not root or not options.eligible(player) or not inZone(a.zone,root.Position) then return false end
			a.hp = math.max(0,a.hp-damage)
			model:SetAttribute("Health",a.hp)
			if a.hp == 0 then remove(a); options.reward(player) end
			return true
		end,
	}
end

return Outbreak
