local menuId = nil

local function split(str)
	local parts = {}
	for token in string.gmatch(str, "%S+") do
		parts[#parts + 1] = token
	end
	return parts
end

local function openMenu()
	if menuId then
		return
	end

	local okRes, screenX, screenY = pcall(Game.GetScreenResolution)
	local width = (okRes and screenX) or 1920
	local height = (okRes and screenY) or 1080

	menuId = WebUI.Create("file://ivd_animations/client/ui/animations.html", width, height, true)
	pcall(WebUI.SetRect, menuId, 0, 0, width, height)

	Console.Log("[ivd_animations] menu WebUI opened (id " .. tostring(menuId) .. ")")

	Thread.Create(function()
		local waited = 0
		while not WebUI.IsReady(menuId) do
			if waited >= 5000 then
				Console.Log("[ivd_animations] menu WebUI never became ready after 5000ms")
				return
			end
			Thread.Pause(50)
			waited = waited + 50
		end

		pcall(WebUI.SetFocus, menuId)
	end)
end

local function closeMenu()
	if not menuId then
		return
	end

	pcall(WebUI.SetFocus, -1)
	pcall(WebUI.Destroy, menuId)
	menuId = nil
end

local function toggleMenu()
	if menuId then
		closeMenu()
	else
		openMenu()
	end
end

function ToggleMenu()
	toggleMenu()
end

function IsMenuOpen()
	return menuId ~= nil
end

Events.Subscribe("ivd_anim:toggleMenu", function()
	toggleMenu()
end)

Events.Subscribe("chatCommand", function(fullCommand)
	local parts = split(fullCommand)
	if parts[1] == "/anim" or parts[1] == "/emotes" or parts[1] == "/animations" then
		toggleMenu()
	end
end)

Events.Subscribe("ivd_anim:closeMenu", function()
	closeMenu()
end)

Events.Subscribe("ivd_anim:playFromMenu", function(dict, clip)
	Events.Call("ivd_anim:play", { dict, clip })
	closeMenu()
end)

if Config.EnableMenuKey then
	Thread.Create(function()
		while true do
			Thread.Pause(16)

			local ok, down = pcall(Game.IsGameKeyboardKeyJustPressed, Config.MenuKey)
			if ok and down then
				toggleMenu()
			end
		end
	end)
end
