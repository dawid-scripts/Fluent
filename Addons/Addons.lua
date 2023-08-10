local httpService = game:GetService("HttpService")

local Addons = {} do
	Addons.Folder = "LinoriaLibSettings"
	Addons.Ignore = {}
	Addons.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = "Toggle", idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if Addons.Options[idx] then 
					Addons.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = "Slider", idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				if Addons.Options[idx] then 
					Addons.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = "Dropdown", idx = idx, value = object.Value, mutli = object.Multi }
			end,
			Load = function(idx, data)
				if Addons.Options[idx] then 
					Addons.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Colorpicker = {
			Save = function(idx, object)
				return { type = "Colorpicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
			end,
			Load = function(idx, data)
				if Addons.Options[idx] then 
					Addons.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		Keybind = {
			Save = function(idx, object)
				return { type = "Keybind", idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if Addons.Options[idx] then 
					Addons.Options[idx]:SetValue({ data.key, data.mode })
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = "Input", idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if Addons.Options[idx] and type(data.text) == "string" then
					Addons.Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function Addons:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function Addons:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

	function Addons:Save(name)
		if (not name) then
			return false, "no config file is selected"
		end

		local fullPath = self.Folder .. "/settings/" .. name .. ".json"

		local data = {
			objects = {}
		}

		for idx, option in next, Addons.Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, "failed to encode data"
		end

		writefile(fullPath, encoded)
		return true
	end

	function Addons:Load(name)
		if (not name) then
			return false, "no config file is selected"
		end
		
		local file = self.Folder .. "/settings/" .. name .. ".json"
		if not isfile(file) then return false, "invalid file" end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, "decode error" end

		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				task.spawn(function() self.Parser[option.type].Load(option.idx, option) end) -- task.spawn() so the config loading wont get stuck.
			end
		end

		return true
	end

	function Addons:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", -- themes
			"ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName", -- themes
		})
	end

	function Addons:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. "/settings"
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function Addons:RefreshConfigList()
		local list = listfiles(self.Folder .. "/settings")

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == ".json" then
				-- i hate this but it has to be done ...

				local pos = file:find(".json", 1, true)
				local start = pos

				local char = file:sub(pos, pos)
				while char ~= "/" and char ~= "\\" and char ~= "" do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == "/" or char == "\\" then
					table.insert(out, file:sub(pos + 1, start - 1))
				end
			end
		end
		
		return out
	end

	function Addons:SetLibrary(library)
		self.Library = library
        self.Options = library.Options
	end

	function Addons:LoadAutoloadConfig()
		if isfile(self.Folder .. "/settings/autoload.txt") then
			local name = readfile(self.Folder .. "/settings/autoload.txt")

			local success, err = self:Load(name)
			if not success then
				--return self.Library:Notify("Failed to load autoload config: " .. err)
			end

			--self.Library:Notify(string.format("Auto loaded config %q", name))
		end
	end


	function Addons:BuildConfigSection(tab)
		assert(self.Library, "Must set Addons.Library")

		local section = tab:AddSection("Configuration")

		section:AddInput("Addons_ConfigName",    { Title = "Config name" })
		section:AddDropdown("Addons_ConfigList", { Title = "Config list", Values = self:RefreshConfigList(), AllowNull = true })

		section:AddButton({
            Title = "Create config",
            Callback = function()
                local name = Addons.Options.Addons_ConfigName.Value

                if name:gsub(" ", "") == "" then 
                    --return self.Library:Notify("Invalid config name (empty)", 2)
                end

                local success, err = self:Save(name)
                if not success then
                    --return self.Library:Notify("Failed to save config: " .. err)
                end

                --self.Library:Notify(string.format("Created config %q", name))

                Addons.Options.Addons_ConfigList:SetValues(self:RefreshConfigList())
                Addons.Options.Addons_ConfigList:SetValue(nil)
            end
        })

        section:AddButton({Title = "Load config", Callback = function()
			local name = Addons.Options.Addons_ConfigList.Value

			local success, err = self:Load(name)
			if not success then
				return --self.Library:Notify("Failed to load config: " .. err)
			end

			--self.Library:Notify(string.format("Loaded config %q", name))
		end})

		section:AddButton({Title = "Overwrite config", Callback = function()
			local name = Addons.Options.Addons_ConfigList.Value

			local success, err = self:Save(name)
			if not success then
				--return self.Library:Notify("Failed to overwrite config: " .. err)
			end

			--self.Library:Notify(string.format("Overwrote config %q", name))
		end})

		section:AddButton({Title = "Refresh list", Callback = function()
			Addons.Options.Addons_ConfigList:SetValues(self:RefreshConfigList())
			Addons.Options.Addons_ConfigList:SetValue(nil)
		end})

		section:AddButton({Title = "Set as autoload", Callback = function()
			local name = Addons.Options.Addons_ConfigList.Value
			writefile(self.Folder .. "/settings/autoload.txt", name)
			--Addons.AutoloadLabel:SetText("Current autoload config: " .. name)
			--self.Library:Notify(string.format("Set %q to auto load", name))
		end})

		--Addons.AutoloadLabel = section:AddLabel("Current autoload config: none", true)

		if isfile(self.Folder .. "/settings/autoload.txt") then
			local name = readfile(self.Folder .. "/settings/autoload.txt")
			--Addons.AutoloadLabel:SetText("Current autoload config: " .. name)
		end

		Addons:SetIgnoreIndexes({ "Addons_ConfigList", "Addons_ConfigName" })
	end

	Addons:BuildFolderTree()
end

return Addons