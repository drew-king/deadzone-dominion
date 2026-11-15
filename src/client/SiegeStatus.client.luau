local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "SiegeStatus", false, 12
gui.Parent = player:WaitForChild("PlayerGui")
local panel = Instance.new("Frame")
panel.Name = "RaidReadout"
panel.AnchorPoint, panel.Position = Vector2.new(.5, 0), UDim2.new(.5, 0, 0, 106)
panel.Size, panel.BackgroundColor3 = UDim2.new(.91, 0, 0, 92), Color3.fromRGB(37, 46, 62)
panel.Parent, panel.Visible = gui, false
local clamp = Instance.new("UISizeConstraint")
clamp.MaxSize, clamp.Parent = Vector2.new(440, 92), panel
local corners = Instance.new("UICorner")
corners.CornerRadius, corners.Parent = UDim.new(0, 10), panel
require(script.Parent.InterfaceArt).panel(panel, Color3.fromRGB(255,173,87))
local function label(name, top, height, size, color)
	local text = Instance.new("TextLabel")
	text.Name = name
	text.Position, text.Size = UDim2.new(.04, 0, 0, top), UDim2.new(.92, 0, 0, height)
	text.BackgroundTransparency = 1
	text.Font, text.TextColor3, text.TextSize = Enum.Font.GothamBold, color, size
	text.TextWrapped, text.Parent = true, panel
	return text
end
local title = label("Title", 5, 20, 16, Color3.fromRGB(255, 195, 108))
local detail = label("Objective", 25, 34, 13, Color3.fromRGB(248, 250, 255))
local status = label("Integrity", 59, 28, 13, Color3.fromRGB(220, 240, 255))
local titles = {warning = "RAID INCOMING", active = "DEFEND RELAY CORE", resolved = "RAID RESULT",
	recovery = "RECOVERY", idle = "NEXT RAID"}

local function nearConsole()
	local world = workspace:FindFirstChild("DeadzonePhase1")
	local name = player:GetAttribute("ClaimedPower")
	local plot = world and name and world:FindFirstChild(name)
	local console = plot and plot:FindFirstChild("SiegeConsole")
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	return root and console and (root.Position - console.Position).Magnitude < 28
end

local function refresh()
	local phase = player:GetAttribute("SiegePhase")
	local deadline = player:GetAttribute("SiegeDeadline") or 0
	local visible = titles[phase] ~= nil and (phase ~= "idle" or deadline > 0 and nearConsole() == true)
	panel.Visible = visible
	if not visible then return end
	local timer = math.max(0, math.ceil(deadline-workspace:GetServerTimeNow()))
	local wave = player:GetAttribute("SiegeWave") or 1
	title.Text = titles[phase] .. " · " .. timer .. "s" .. (if phase == "idle" then "" else " · WAVE " .. wave)
	detail.Text = player:GetAttribute("SiegeMessage") or ""
	status.Text = string.format("Core %d HP · Gate %d HP · Barricade %d HP · %d left",
		math.ceil(player:GetAttribute("SiegeCore") or 0), math.ceil(player:GetAttribute("SiegeGateHealth") or 0),
		math.ceil(player:GetAttribute("SiegeBarricadeHealth") or 0), player:GetAttribute("SiegeRemaining") or 0)
end
for _, key in {"Phase", "Message", "Core", "GateHealth", "BarricadeHealth", "Remaining"} do
	player:GetAttributeChangedSignal("Siege"..key):Connect(refresh)
end
while task.wait(.25) do refresh() end
