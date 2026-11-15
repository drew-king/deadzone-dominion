local Players = game:GetService("Players")
local Art = require(script.Parent.FactoryArt)
local palette = require(game:GetService("ReplicatedStorage").Shared.VisualTheme)
local Boards = {}

local function text(parent, name, caption, x, y, width, height, size, color)
	local label = Instance.new("TextLabel")
	label.Name, label.Text = name, caption
	label.Position, label.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(width, height)
	label.BackgroundTransparency, label.TextColor3 = 1, color
	label.TextSize, label.Font = size, Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

function Boards.start()
	local root = Instance.new("Folder")
	root.Name, root.Parent = "LiveLeaderboards", workspace
	local joined = {}
	local definitions = {
		{"Scrap wallet", "ScrapCash", Color3.fromRGB(53,212,152)},
		{"Rebirths", "Rebirths", Color3.fromRGB(255,174,58)},
		{"Arena eliminations", "ArenaEliminations", Color3.fromRGB(189,112,252)},
		{"Session minutes", "Minutes", Color3.fromRGB(91,188,255)},
		{"Session Scrap spent", "ScrapSpent", Color3.fromRGB(254,113,153)},
	}
	local tracks = {}
	for index, definition in definitions do
		local title, attribute, accent = table.unpack(definition)
		local board = Instance.new("Part")
		board.Name, board.Anchored = title, true
		board.CanCollide, board.CanTouch, board.CanQuery = false, false, false
		board.Size = Vector3.new(11, 8, .65)
		board.CFrame = CFrame.lookAt(Vector3.new(25 + (index - 1) * 12, 5, -109), Vector3.new(25 + (index - 1) * 12, 5, -129))
		board.Color, board.Material, board.Parent = palette.Ink, Enum.Material.SmoothPlastic, root
		Art.detail(board, "ScoreboardTrim", board.CFrame * CFrame.new(0, 3.9, -.36), Vector3.new(11.1, .22, .16), accent, Enum.Material.Neon)
		local gui = Instance.new("SurfaceGui")
		gui.Face, gui.LightInfluence, gui.CanvasSize, gui.Parent = Enum.NormalId.Front, 0, Vector2.new(440, 320), board
		text(gui, "Metric", title, 20, 14, 400, 38, 32, palette.Cream)
		text(gui, "Scope", "THIS SERVER", 22, 53, 400, 26, 18, accent)
		local empty = text(gui, "Empty", "Waiting for players", 22, 100, 400, 38, 24, palette.Cream)
		local rows = {}
		for rank = 1, 5 do
			local frame = Instance.new("Frame")
			frame.Name = "Rank" .. rank
			frame.Position, frame.Size = UDim2.fromOffset(17, 88 + (rank - 1) * 44), UDim2.fromOffset(406, 39)
			frame.BackgroundColor3, frame.BorderSizePixel = palette.Ink:Lerp(accent, if rank == 1 then .22 else .08), 0
			frame.Parent = gui
			text(frame, "Rank", tostring(rank), 9, 0, 32, 39, 21, accent)
			local name = text(frame, "Player", "", 50, 0, 239, 39, 23, palette.Cream)
			name.TextTruncate = Enum.TextTruncate.AtEnd
			local value = text(frame, "Score", "", 297, 0, 100, 39, 23, accent)
			value.TextXAlignment, value.TextScaled = Enum.TextXAlignment.Right, true
			local cap = Instance.new("UITextSizeConstraint")
			cap.MaxTextSize, cap.Parent = 23, value
			rows[rank] = {frame = frame, name = name, value = value}
		end
		tracks[index] = {attribute = attribute, rows = rows, empty = empty}
	end
	local function track(player) joined[player] = os.time() end
	Players.PlayerAdded:Connect(track)
	for _, player in Players:GetPlayers() do track(player) end
	Players.PlayerRemoving:Connect(function(player) joined[player] = nil end)
	task.spawn(function()
		while root.Parent do
			local now, roster = os.time(), Players:GetPlayers()
			for _, board in tracks do
				local scores = {}
				for _, player in roster do
					scores[player] = if board.attribute == "Minutes" then math.floor((now - (joined[player] or now)) / 60)
						else player:GetAttribute(board.attribute) or 0
				end
				table.sort(roster, function(a, b)
					return if scores[a] == scores[b] then a.UserId < b.UserId else scores[a] > scores[b]
				end)
				board.empty.Visible = #roster == 0
				for index, row in board.rows do
					local player = roster[index]
					row.frame.Visible = player ~= nil
					if player then
						row.name.Text = "@" .. player.Name
						row.value.Text = tostring(scores[player])
					end
				end
			end
			task.wait(5)
		end
	end)
end
return Boards
