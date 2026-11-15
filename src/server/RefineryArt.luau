local Art = require(script.Parent.FactoryArt)
local palette = require(game.ReplicatedStorage.Shared.VisualTheme)
local RefineryArt = {}

function RefineryArt.build(plot)
	local frame = plot.Model:GetPivot()
	local deck = Instance.new("Model")
	deck.Name, deck.Parent = "RefineryWorkshop", plot.Model
	local gold, teal = plot.Theme[3], plot.Theme[2]
	local function piece(name, x, y, z, size, color, material)
		return Art.detail(deck, name, frame*CFrame.new(x,y,z),size,color,material or Enum.Material.Metal)
	end
	local function sign(x,z,words)
		local plate=piece("BaySign",x,16.5,z,Vector3.new(8,2,.4),palette.Ink)
		local gui=Instance.new("SurfaceGui")
		gui.Face,gui.LightInfluence,gui.Parent=Enum.NormalId.Back,0,plate
		local text=Instance.new("TextLabel")
		text.Size,text.BackgroundTransparency=UDim2.fromScale(1,1),1
		text.Text,text.TextColor3,text.Font,text.TextScaled=words,palette.Cream,Enum.Font.GothamBold,true
		text.Parent=gui
		return text
	end
	sign(-31,-29,"01 · CARGO INTAKE")
	sign(-10,-29,"02 · REFINERY")
	plot.RefineryDispatch = sign(13,-29,"03 · DISPATCH\nWaiting for a sale")
	for _,z in {-42,-26,-10,6} do
		for _,x in {-45,18} do
			local lamp=piece("RefineryWorkLight",x,15,z,Vector3.new(1.2,.6,4),teal,Enum.Material.Neon)
			local light=Instance.new("PointLight")
			light.Color,light.Range,light.Brightness,light.Parent=palette.Cream,15,.7,lamp
		end
	end
	for _,x in {-31,-10,13} do
		local chassis=piece("RefineryBay",x,13.2,-31,Vector3.new(13,1.6,7.4),palette.Ink)
		chassis.CanCollide,chassis.CanQuery=true,true
		for _,dx in {-4.8,4.8} do
			piece("CranePillar",x+dx,15,-33,Vector3.new(1,4.9,1.2),teal)
			piece("LaneGlow",x+dx,12.43,-20,Vector3.new(.32,.04,11.5),gold,Enum.Material.Neon)
		end
		piece("CraneCrossbeam",x,17.4,-33,Vector3.new(11.2,.72,1.2),teal)
	end
	for _,row in {{-34,2.4,gold},{-29,1.7,teal},{-25,2.5,palette.Cream}} do
		local x,h,c=table.unpack(row)
		piece("CargoCase",x,14+h/2,-32.5,Vector3.new(3,h,3),c)
		piece("CargoCaseSeal",x,14+h/2,-30.96,Vector3.new(2,.25,.11),palette.Ink)
	end
	for _,z in {-32.6,-30.2} do
		for x=-15,-5,2.5 do
			local roller=piece("RefineryRoller",x,14.05,z,Vector3.new(2.2,.36,1.6),gold)
			roller.Shape=Enum.PartType.Cylinder
		end
	end
	for _,x in {9,13,17} do
		piece("DispatchCanister",x,15.15,-32,Vector3.new(2.45,2.3,2.4),teal)
		piece("CanisterStatus",x,15.4,-30.75,Vector3.new(1.45,.35,.13),gold,Enum.Material.Neon)
	end
	local guide=piece("RefineryAisle",1,12.43,-8,Vector3.new(3,.04,34),teal)
	guide.Transparency=.25
	table.insert(plot.Construction.UpperAccess,deck)
end

return RefineryArt
