local Players=game:GetService("Players")
local Storage=game:GetService("ReplicatedStorage")
local config=require(Storage.Shared.BackpackConfig)
local Potions={}

function Potions.start(profiles,getPlot,economy)
	local effects,last={},{}
	local moved={}
	local remote=Instance.new("RemoteFunction")
	remote.Name="DeadzonePotions"
	local function publish(p)
		local profile=profiles[p]
		if not profile then return end
		for key in config.Potions do p:SetAttribute("PotionCount_"..key,(profile.potions or {})[key] or 0) end
		p:SetAttribute("BackpackUsed",config.Count(profile))
	end
	remote.OnServerInvoke=function(p,action,key)
		local now=workspace:GetServerTimeNow()
		if now<(last[p] or 0) then return false,"Wait a moment." end
		last[p]=now+.3
		local potion=type(key)=="string" and config.Potions[key]
		local profile,plot=profiles[p],getPlot(p)
		if not potion or not profile or not plot then return false,"Claim a plot to use potions." end
		profile.potions=profile.potions or {}
		local quantity=profile.potions[key] or 0
		if action=="Buy" then
			if quantity==0 and config.Count(profile)>=config.Capacity then return false,"Backpack is full." end
			if quantity>=10000 or profile.wallet<potion.Price then return false,"Purchase unavailable." end
			profile.wallet-=potion.Price
			profile.potions[key]=quantity+1
			economy.publish(plot)
		elseif action=="Use" then
			local human=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
			if quantity<1 or not human or human.Health<=0 then return false,"No potion available." end
			effects[p]=effects[p] or {}
			if now<(effects[p][key] or 0) then return false,"That boost is already active." end
			profile.potions[key]=if quantity==1 then nil else quantity-1
			effects[p][key]=now+potion.Duration
			p:SetAttribute("PotionUntil_"..key,effects[p][key])
		else return false,"Unknown potion action." end
		publish(p)
		return true,if action=="Buy" then potion.Name.." added." else potion.Name.." active."
	end
	remote.Parent=Storage
	Players.PlayerRemoving:Connect(function(p) effects[p],last[p],moved[p]=nil,nil,nil end)
	task.spawn(function()
		local safeRadius=require(Storage.Shared.CombatConfig).ArenaRadius+14
		while task.wait(.15) do
			local now=workspace:GetServerTimeNow()
			for _,p in Players:GetPlayers() do
				local char=p.Character
				local h=char and char:FindFirstChildOfClass("Humanoid")
				local root=char and char:FindFirstChild("HumanoidRootPart")
				local plot=getPlot(p)
				local factor=1
				if plot and h and h.Health>0 and root and Vector2.new(root.Position.X,root.Position.Z).Magnitude>safeRadius
					and now>=(p:GetAttribute("PowerBoostUntil") or 0) then
					local point=plot.Model:GetPivot():PointToObjectSpace(root.Position)
					if p:GetAttribute("PreviewPass_FactorySpeed") and math.abs(point.X)<52 and math.abs(point.Z)<56 then factor=1.25 end
					if effects[p] and now<(effects[p].Speed or 0) then factor=math.max(factor,config.Potions.Speed.Factor) end
				end
				local prior=moved[p]
				if prior and (factor==1 or h~=prior.h or h.WalkSpeed~=prior.applied) then
					if prior.h.Parent and prior.h.WalkSpeed==prior.applied then prior.h.WalkSpeed=prior.base end
					moved[p]=nil
				end
				if factor>1 and h and (not moved[p] or moved[p].factor~=factor) then
					local base=if moved[p] then moved[p].base else h.WalkSpeed
					h.WalkSpeed=base*factor
					moved[p]={base=base,applied=h.WalkSpeed,h=h,factor=factor}
				end
			end
		end
	end)
	return {publish=publish, factor=function(p,key)
		local state=effects[p]
		return if state and workspace:GetServerTimeNow()<(state[key] or 0) then config.Potions[key].Factor else 1
	end}
end

return Potions
