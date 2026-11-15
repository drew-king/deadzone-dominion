local Players=game:GetService("Players")
local Storage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local roster=require(Storage.Shared.PetConfig)
local remote=Storage:WaitForChild("DeadzoneHatch")
local config=require(Storage.Shared.BackpackConfig)
local appearance=require(script.Parent.PetAppearance)
local byId={}
for _,pet in roster do byId[pet.Id]=pet end
local gui=Instance.new("ScreenGui")
gui.Name,gui.DisplayOrder,gui.ResetOnSpawn="DeadzoneHatch",19,false
gui.Parent=player:WaitForChild("PlayerGui")
local stack=Instance.new("ScrollingFrame")
stack.Name,stack.Visible="Incubator",false
stack.Position,stack.AnchorPoint=UDim2.fromScale(.5,.5),Vector2.new(.5,.5)
stack.Size,stack.CanvasSize,stack.AutomaticCanvasSize=UDim2.fromScale(.87,.8),UDim2.new(),Enum.AutomaticSize.Y
stack.BackgroundColor3,stack.Parent=Color3.fromRGB(26,35,62),gui
local limit=Instance.new("UISizeConstraint")
limit.MaxSize,limit.Parent=Vector2.new(475,610),stack
require(script.Parent.InterfaceArt).panel(stack,Color3.fromRGB(216,159,255))
local list=Instance.new("UIListLayout")
list.SortOrder,list.Padding,list.Parent=Enum.SortOrder.LayoutOrder,UDim.new(0,5),stack
local order=0
local function row(class,text,height,tint)
	local item=Instance.new(class)
	order+=1
	item.LayoutOrder,item.Size=order,UDim2.new(1,-12,0,height)
	item.Text,item.TextWrapped,item.TextSize=text,true,16
	item.Font,item.TextColor3=Enum.Font.GothamBold,Color3.fromRGB(247,243,255)
	item.BackgroundColor3,item.Parent=tint or Color3.fromRGB(51,58,90),stack
	require(script.Parent.InterfaceArt).panel(item,tint or Color3.fromRGB(125,112,208))
	return item
end
local title=row("TextLabel","Incubator",44)
local status=row("TextLabel","",42)
local egg=row("TextLabel","",54,Color3.fromRGB(87,57,131))
local display=Instance.new("ViewportFrame")
order+=1
display.LayoutOrder,display.Size,display.Parent=order,UDim2.new(1,-12,0,124),stack
display.BackgroundColor3=Color3.fromRGB(34,31,60)
display.Ambient,display.LightColor=Color3.fromRGB(230,206,255),Color3.new(1,1,1)
local camera=Instance.new("Camera")
camera.CFrame=CFrame.lookAt(Vector3.new(0,1.7,-6.6),Vector3.new(0,.2,0))
camera.FieldOfView,camera.Parent=43,display
display.CurrentCamera=camera
local world=Instance.new("WorldModel")
world.Parent=display
local function showEgg(color)
	world:ClearAllChildren()
	local shell=Instance.new("Part")
	shell.Shape,shell.Size,shell.Color=Enum.PartType.Ball,Vector3.new(1.45,2,1.45),color
	shell.Material,shell.Anchored,shell.Parent=Enum.Material.SmoothPlastic,true,world
end
local odds=row("TextLabel","",205)
odds.TextSize=12
local single=row("TextButton","Hatch one",44)
single.Name="HatchOne"
local triple=row("TextButton","Hatch three",44)
triple.Name="HatchThree"
local auto=row("TextButton","Start Auto-Open",44)
local autoTriple=row("TextButton","Auto-Open three",44)
local stop=row("TextButton","Stop Auto-Open",44)
local close=row("TextButton","Close",44)
local motion=row("TextButton","Animation · on",44)
local reduced=false
local price,free,sequence=0,false,0
local pendingAuto
local function controls()
	local spare=if free then 1 else 0
	single.Text=string.format("Hatch one · %d Scrap",price*(1-spare))
	triple.Text=if player:GetAttribute("PreviewPass_TripleHatch") then string.format("Hatch three · %d Scrap",price*(3-spare))
		else "Triple Hatch · pass required"
	auto.Text=if player:GetAttribute("PreviewPass_AutoOpen") then string.format("Auto-Open one · %d Scrap each",price)
		else "Auto-Open · pass required"
	autoTriple.Visible=player:GetAttribute("PreviewPass_AutoOpen")==true and player:GetAttribute("PreviewPass_TripleHatch")==true
	autoTriple.Text=string.format("Auto-Open three · %d Scrap per cycle",price*3)
end
single.Activated:Connect(function() remote:FireServer("Hatch",1) end)
triple.Activated:Connect(function() remote:FireServer("Hatch",3) end)
local function confirmAuto(quantity)
	if not player:GetAttribute("PreviewPass_AutoOpen") then return end
	if pendingAuto~=quantity then
		pendingAuto=quantity
		status.Text=string.format("Confirm %s · %d per batch · %d Scrap each cycle. Press again to start.",
			title.Text,quantity,quantity*price)
		return
	end
	pendingAuto=nil
	remote:FireServer("Auto",quantity)
end
auto.Activated:Connect(function() confirmAuto(1) end)
autoTriple.Activated:Connect(function() confirmAuto(3) end)
stop.Activated:Connect(function() pendingAuto=nil; remote:FireServer("Stop"); status.Text="Auto-Open stopped." end)
motion.Activated:Connect(function()
	reduced=not reduced
	motion.Text=if reduced then "Animation · reduced motion" else "Animation · on"
	if reduced then egg.Rotation=0 end
end)
close.Activated:Connect(function() pendingAuto=nil; remote:FireServer("Stop"); stack.Visible=false end)
player:GetAttributeChangedSignal("PreviewPass_TripleHatch"):Connect(controls)
player:GetAttributeChangedSignal("PreviewPass_AutoOpen"):Connect(controls)
remote.OnClientEvent:Connect(function(action,a,b,c,d)
	if action=="Open" then
		pendingAuto=nil
		local pool=roster.Themes[a].Floors[b]
		price,free=c,d
		title.Text=pool.Name
		egg.Text,egg.BackgroundColor3="◈   "..pool.Name.."   ◈",pool.Color:Lerp(Color3.fromRGB(44,33,62),.46)
		showEgg(pool.Color)
		status.Text=string.format("Backpack %d/%d",player:GetAttribute("BackpackUsed") or 0,config.Capacity)
		local lines,rarities={},{}
		for _,pet in pool.Pets do
			table.insert(lines,string.format("%s · %s · %.1f%%",pet.Name,pet.Rarity,pet.Weight/10))
			rarities[pet.Rarity]=(rarities[pet.Rarity] or 0)+pet.Weight
		end
		local totals={}
		for name,weight in rarities do table.insert(totals,string.format("%s %.1f%%",name,weight/10)) end
		table.sort(totals)
		odds.Text=table.concat(totals,"  ·  ").."\n\n"..table.concat(lines,"\n")
		odds.Size=UDim2.new(1,-12,0,math.max(160,#lines*18+40))
		controls()
		stack.Visible=true
	elseif action=="Status" then status.Text=a
	elseif action=="Result" then
		free=false
		controls()
		sequence+=1
		local current=sequence
		local names={}
		for _,result in a do
			local pet=byId[result.id]
			table.insert(names,pet.Rarity.." "..pet.Name..(if result.duplicate then " · owned" else ""))
		end
		status.Text=string.format("Backpack %d/%d",player:GetAttribute("BackpackUsed") or 0,config.Capacity)
		local reveal=table.concat(names,"\n")
		if b and b>0 then status.Text=status.Text..string.format(" · %d Scrap recovered",b) end
		egg.Size=UDim2.new(1,-12,0,if #names>1 then 80 else 54)
		local function finish()
			egg.Text=reveal
			world:ClearAllChildren()
			for index,result in a do
				local pet=byId[result.id]
				local model=appearance.build(pet,pet.Tier or 1)
				model:PivotTo(CFrame.new((index-(#a+1)/2)*1.65,0,0)*CFrame.Angles(0,-.13,0))
				model.Parent=world
			end
		end
		if reduced then finish(); return end
		egg.Text="◈   Cracking…"
		showEgg(egg.BackgroundColor3)
		local shell=world:FindFirstChildOfClass("Part")
		TweenService:Create(shell,TweenInfo.new(.34,Enum.EasingStyle.Back),{Rotation=Vector3.new(0,25,-28)}):Play()
		egg.Rotation=-5
		TweenService:Create(egg,TweenInfo.new(.35,Enum.EasingStyle.Back),{Rotation=0}):Play()
		task.delay(.36,function() if current==sequence then finish() end end)
	end
end)
