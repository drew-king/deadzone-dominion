local Art = require(script.Parent.FactoryArt)
local layout = require(game.ReplicatedStorage.Shared.CargoRoutes)
local CargoArt = {}

function CargoArt.build(plot)
	local frame = plot.Model:GetPivot()
	local ink = Color3.fromRGB(30,46,66)
	local light, accent = plot.Theme[3], plot.Theme[2]
	local folder
	local function group(key)
		folder = Instance.new("Model")
		folder.Name,folder.Parent=key.."Assembly",plot.Model
		plot.Construction[key] = {folder}
	end
	local function part(name,transform,size,color,neon)
		return Art.detail(folder,name,transform,size,color,if neon then Enum.Material.Neon else Enum.Material.Metal)
	end
	local function line(points)
		for i = 2, #points do
			local first,last = points[i-1],points[i]
			local distance=(last-first).Magnitude
			local up=if last.Y~=first.Y then frame.RightVector else Vector3.yAxis
			local body=CFrame.lookAt(frame:PointToWorldSpace((first+last)/2),frame:PointToWorldSpace(last),up)
			part("BeltChassis",body*CFrame.new(0,-.32,0),Vector3.new(4.4,.58,distance),ink)
			for _,side in {-1,1} do
				part("BeltGuide",body*CFrame.new(side*2.2,.05,0),Vector3.new(.23,.25,distance),accent)
			end
			for z=-distance/2+1,distance/2-1,2 do
				part("BeltRoller",body*CFrame.new(0,-.09,z),Vector3.new(4.15,.14,.62),light)
			end
		end
	end
	local function endpoint(name,point)
		local dock=part(name,frame*CFrame.new(point+Vector3.new(0,-.25,-.4)),Vector3.new(5.2,.48,2),ink)
		local lightBar=part("SellIndicator",dock.CFrame*CFrame.new(0,.28,0),Vector3.new(4,.1,1.2),light,true)
		lightBar.Parent=dock
		return dock
	end
	group("BeltAnnex")
	line(layout.Annex)
	local annex=endpoint("AnnexSellBlock",layout.Annex[2])
	group("BeltDispatch")
	line(layout.Dispatch)
	endpoint("DispatchSellBlock",layout.Dispatch[2])
	group("RefineryBelt")
	line(layout.Refinery)
	local refinery=endpoint("RefinerySellBlock",layout.Refinery[#layout.Refinery])
	group("RefineryDropper")
	local spout=frame*CFrame.new(-23,16.9,8)
	part("AlloyPressureChamber",spout,Vector3.new(4.5,2.3,3.4),accent)
	part("AlloyOutlet",spout*CFrame.new(0,-1.4,0),Vector3.new(2,1,2),light,true)
	for _, x in {-2.55,2.55} do
		part("DropperSupport",spout*CFrame.new(x,-1.6,0),Vector3.new(.7,5.8,2.9),ink)
	end
	group("RefineryFinish")
	local polish=frame*CFrame.new(6,14.55,-15)
	part("PolisherHeader",polish*CFrame.new(0,1.15,0),Vector3.new(3.6,.75,5),light)
	for _,z in {-2.45,2.45} do
		part("PolisherUpright",polish*CFrame.new(0,-.55,z),Vector3.new(3.6,3.5,.36),accent)
	end
	group("CargoLift")
	line(layout.Lift)
	endpoint("RaisedSellBlock",layout.Lift[#layout.Lift])
	for _, side in {-1,1} do
		local barrier=part("CargoShaftBarrier",frame*CFrame.new(22+side*2.9,25.65,-42),Vector3.new(.2,2.5,6),accent)
		barrier.CanCollide,barrier.CanQuery=true,true
		barrier=part("CargoShaftBarrier",frame*CFrame.new(22,25.65,-42+side*2.9),Vector3.new(5.6,2.5,.2),accent)
		barrier.CanCollide,barrier.CanQuery=true,true
	end
	plot.ExtensionDocks={annex=annex,refinery=refinery}
end

return CargoArt
