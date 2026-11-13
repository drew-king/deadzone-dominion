local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "DeadzoneGuide"
gui.ResetOnSpawn = false
local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.fromScale(0.5, 0.025)
label.Size = UDim2.new(0.9, 0, 0, 60)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(430, 60)
limit.Parent = label
label.BackgroundColor3 = Color3.fromRGB(28, 34, 43)
label.TextColor3 = Color3.fromRGB(255, 225, 174)
label.TextScaled = true
label.TextWrapped = true
label.Font = Enum.Font.GothamBold
local textLimit = Instance.new("UITextSizeConstraint")
textLimit.MaxTextSize = 18
textLimit.Parent = label
label.Parent = gui
local function update()
	local power = player:GetAttribute("ClaimedPower")
	local feedback = player:GetAttribute("ClaimFeedback")
	local objective = if power then power .. " · Explore Reactor Crown" else "CLAIM A BASE · Find an available gate"
	label.Text = if feedback then objective .. "\n" .. feedback else objective
end
player:GetAttributeChangedSignal("ClaimedPower"):Connect(update)
player:GetAttributeChangedSignal("ClaimFeedback"):Connect(update)
update()
gui.Parent = player:WaitForChild("PlayerGui")
