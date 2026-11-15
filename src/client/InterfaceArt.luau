local InterfaceArt = {}

function InterfaceArt.panel(frame, accent)
	frame.BorderSizePixel = 0
	local corner = frame:FindFirstChildWhichIsA("UICorner") or Instance.new("UICorner")
	corner.CornerRadius, corner.Parent = UDim.new(0,12),frame
	local line = frame:FindFirstChildWhichIsA("UIStroke") or Instance.new("UIStroke")
	line.ApplyStrokeMode, line.Color = Enum.ApplyStrokeMode.Border,accent
	line.Transparency, line.Thickness, line.Parent = .3,1.5,frame
	if frame:IsA("ScrollingFrame") then frame.ScrollBarImageColor3 = accent end
	return line
end

return InterfaceArt
