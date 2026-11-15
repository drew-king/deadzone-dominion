local rgb = Color3.fromRGB
local themes = {
	{ "SHIELD", rgb(202, 48, 79), rgb(255, 167, 165) },
	{ "TURBINE", rgb(19, 156, 181), rgb(255, 216, 91) },
	{ "TWIN RINGS", rgb(224, 105, 48), rgb(253, 151, 203) },
	{ "SUNBURST", rgb(203, 135, 32), rgb(255, 239, 165) },
	{ "BIO CORE", rgb(35, 149, 94), rgb(178, 242, 170) },
	{ "FIZZ TOWER", rgb(131, 79, 204), rgb(224, 166, 255) },
	{ "RETICLE", rgb(115, 154, 44), rgb(228, 251, 132) },
	{ "ICE CRYSTAL", rgb(73, 126, 199), rgb(172, 233, 255) },
}

return {
	Plots = themes,
	Ink = rgb(33, 27, 58),
	Cream = rgb(255, 238, 204),
	Sand = rgb(222, 181, 145),
	Teal = rgb(23, 136, 132),
	Gold = rgb(252, 185, 70),
}
