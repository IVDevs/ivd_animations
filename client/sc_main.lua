local currentDict = nil

local function split(str)
	local parts = {}
	for token in string.gmatch(str, "%S+") do
		parts[#parts + 1] = token
	end
	return parts
end

local function playAnimation(dict, clip)
	local ok, char = pcall(Game.GetPlayerChar, Game.GetPlayerId())
	if not ok or not char then
		return
	end

	pcall(Game.RequestAnims, dict)

	Thread.Create(function()
		local waited = 0
		while waited < Config.LoadTimeoutMs do
			local okLoaded, loaded = pcall(Game.HaveAnimsLoaded, dict)
			if okLoaded and loaded then
				break
			end
			Thread.Pause(50)
			waited = waited + 50
		end

		pcall(Game.TaskPlayAnim, char, clip, dict, Config.PlaySpeed, false, false, false, false, Config.PlayDuration)
		currentDict = dict
	end)
end

local function findAnimation(keyword)
	keyword = keyword:lower()

	for _, entry in ipairs(Config.AnimationDicts) do
		for _, clip in ipairs(entry.clips) do
			local haystack = (entry.label .. " " .. clip.label .. " " .. entry.dict .. " " .. clip.name):lower()
			if haystack:find(keyword, 1, true) then
				return entry.dict, clip.name
			end
		end
	end

	return nil, nil
end

local function cancelAnimation()
	local ok, char = pcall(Game.GetPlayerChar, Game.GetPlayerId())
	if ok and char then
		pcall(Game.ClearCharTasksImmediately, char)
	end

	if currentDict then
		pcall(Game.RemoveAnims, currentDict)
		currentDict = nil
	end
end

Events.Subscribe("ivd_anim:play", function(dict, clip)
	playAnimation(dict, clip)
end)

Events.Subscribe("ivd_anim:cancel", function()
	cancelAnimation()
end)

Events.Subscribe("chatCommand", function(fullCommand)
	local parts = split(fullCommand)
	if parts[1] == "/cancelanim" or parts[1] == "/stopanim" then
		cancelAnimation()
	elseif parts[1] == "/e" then
		local keyword = fullCommand:sub(#parts[1] + 2)
		if #keyword < 1 then
			pcall(Chat.AddMessage, "{3399FF}[IVD]{FFFFFF} Usage: /e [keyword] — e.g. /e sit")
			return
		end

		local dict, clip = findAnimation(keyword)
		if dict then
			playAnimation(dict, clip)
		else
			pcall(Chat.AddMessage, "{3399FF}[IVD]{FFFFFF} No animation found matching '" .. keyword .. "'.")
		end
	end
end)

Thread.Create(function()
	while true do
		Thread.Pause(16)

		if currentDict then
			local okX, downX = pcall(Game.IsGameKeyboardKeyJustPressed, Config.CancelKey)
			if okX and downX then
				cancelAnimation()
			end
		end
	end
end)
