function init(plugin)
	print("Aseprite is initializing uvlookup plugin")

	if plugin.preferences.count == nil then
		plugin.preferences.count = 0
	end

	function uvlookup()
		local dialog = Dialog { title = "UV lookup" }

		local function getOpenTabs()
			local tabs = {}
			for _, sprite in ipairs(app.sprites) do
				table.insert(tabs, sprite.filename)
			end
			return tabs
		end

		function tableClear(table)
			for i in pairs(table) do
				table[i] = nil
			end
		end

		function applyColors(x, y, image, color)
			local pixelValue = image:getPixel(x, y)
			local a = app.pixelColor.rgbaA(pixelValue)

			if a > 0 then
				
				local r = app.pixelColor.rgbaR(uvColors[color])
				local g = app.pixelColor.rgbaG(uvColors[color])
				local b = app.pixelColor.rgbaB(uvColors[color])
				local a = app.pixelColor.rgbaA(uvColors[color])
				
				image:putPixel(x, y, app.pixelColor.rgba(r, g, b, a))
				color = color + 1
			end

			return color
		end

		function findLayerByName(sprite, layerName)
			for i, layer in ipairs(sprite.layers) do
				if layer.name == layerName then
					return layer
				end
			end
			return nil
		end

		local function findSpriteByPath(spritePath)
			for i, spr in ipairs(app.sprites) do
				if spr.filename == spritePath then
					return spr
				end
			end
			return nil
		end

		function getSourceAndLookup()
			lookup = findSpriteByPath(selectedLookup)
			if not lookup then
				app.alert("Lookup sprite not found!")
				return
			end
			
			source = findSpriteByPath(selectedSource)
			if not source then
				app.alert("Source sprite not found!")
				return
			end
		end

		function createSourceTop()

			local sourceTopLayer = findLayerByName(source, "color")

			if sourceTopLayer == nil then
				app.command.DuplicateLayer {
					sprite = source,
					layer = sourceBottomLayer,
				}
				sourceTopLayer = findLayerByName(source, "uv Copy")
				sourceTopLayer.name = "color"
				app.alert("Source color layer created! Click once again to sync colors!")
				return true
			end	
			return false
		end

		function syncColors(lookupBottomImage, lookupTopImage, sourceBottomLayer, sourceTopLayer)
			for y = 0, lookupBottomImage.height - 1 do
				for x = 0, lookupBottomImage.width - 1 do
					local lookupBottomColor = lookupBottomImage:getPixel(x, y)

					if app.pixelColor.rgbaA(lookupBottomColor) > 0 then
						lookupTopColor = lookupTopImage:getPixel(x, y)
						table.insert(uvLookup, lookupBottomColor)
						table.insert(colorLookup, lookupTopColor)
					end
				end
			end

			for f, frame in ipairs(source.frames) do

				local sourceBottomImage = sourceBottomLayer.cels[f].image
				local sourceTopImage = sourceTopLayer.cels[f].image

				for y = 0, sourceBottomImage.height - 1 do
					for x = 0, sourceBottomImage.width - 1 do
						local sourceBottomColor = sourceBottomImage:getPixel(x, y)

						if app.pixelColor.rgbaA(sourceBottomColor) > 0 then
							for i, uv in ipairs(uvLookup) do

								local uvr = app.pixelColor.rgbaR(uv)
								local uvg = app.pixelColor.rgbaG(uv)
								local uvb = app.pixelColor.rgbaB(uv)
								local uva = app.pixelColor.rgbaA(uv)

								local sbr = app.pixelColor.rgbaR(sourceBottomColor)
								local sbg = app.pixelColor.rgbaG(sourceBottomColor)
								local sbb = app.pixelColor.rgbaB(sourceBottomColor)
								local sba = app.pixelColor.rgbaA(sourceBottomColor)

								if uvr == sbr 
								and uvg == sbg 
								and uvb == sbb 
								and uva == sba then

									local r = app.pixelColor.rgbaR(colorLookup[i])
									local g = app.pixelColor.rgbaG(colorLookup[i])
									local b = app.pixelColor.rgbaB(colorLookup[i])
									local a = app.pixelColor.rgbaA(colorLookup[i])

									if a > 0 then

										local er = emptyColor.red
										local eg = emptyColor.green
										local eb = emptyColor.blue
										local ea = emptyColor.alpha

										if r == er 
										and g == eg 
										and b == eb 
										and a == ea then
											sourceTopImage:putPixel(x, y, app.pixelColor.rgba(r, g, b, 0))
										else
											sourceTopImage:putPixel(x, y, app.pixelColor.rgba(r, g, b, a))
										end
									end
								end
							end
						else
							sourceTopImage:putPixel(x, y, app.pixelColor.rgba(0, 0, 0, 0))
						end
					end
				end
			end
		end

		function sync()
			local lookupTopLayer = findLayerByName(lookup, "color")
			local lookupBottomLayer = findLayerByName(lookup, "uv")

			local sourceTopLayer = findLayerByName(source, "color")
			local sourceBottomLayer = findLayerByName(source, "uv")

			if not lookupTopLayer then
				app.alert("Color layer not found in Lookup sprite!")
				return
			end
			
			if not lookupBottomLayer then
				app.alert("UV layer not found in Lookup sprite!")
				return
			end

			if not sourceTopLayer then
				app.alert("Color layer not found in Source sprite!")
				return
			end

			if not sourceBottomLayer then
				app.alert("UV layer not found in Source sprite!")
				return
			end
			
			local lookupTopImage = lookupTopLayer.cels[1].image
			local lookupBottomImage = lookupBottomLayer.cels[1].image
			
			tableClear(uvLookup)
			tableClear(colorLookup)

			syncColors(lookupBottomImage, lookupTopImage, sourceBottomLayer, sourceTopLayer)
		end

		local openTabs = getOpenTabs()

		selectedLookup = openTabs[1]
		selectedSource = openTabs[1]

		lookup = nil
		source = nil

		uvColors = {}

		uvLookup = {}
		colorLookup = {}

		emptyColor = Color{ r=0, g=0, b=0, a=255 }

		local lookupDirection = "Horizontal"

		dialog:combobox {
			id = "uv_lookup_direction_id",
			label = "Lookup direction:",
			options = {"Horizontal", "Vertical"},
			onchange = function()
				lookupDirection = dialog.data.uv_lookup_direction_id
			end
		}

		dialog:button {
			id = "uv_make_lookup_button_id",
			text = "Make lookup",
			onclick = function()

				local sprite = app.activeSprite
				local cel = app.activeCel
				local image = cel.image

				tableClear(uvColors)

				local width = sprite.width
				local height = sprite.height

				for y = 0, image.height - 1 do
					for x = 0, image.width - 1 do
						local pixelValue = image:getPixel(x, y)
						local a = app.pixelColor.rgbaA(pixelValue)
					
						if a > 0 then
							local r = (x / (width - 1)) * 255
							local g = (y / (height - 1)) * 255
							image:putPixel(x, y, app.pixelColor.rgba(r, g, 255, a))
							local pixelValue = image:getPixel(x, y)
							table.insert(uvColors, pixelValue)
						end
					end
				end

				app.refresh()
			end
		}

		dialog:button {
			id = "uv_make_source_button_id",
			text = "Make source",
			onclick = function()

				local sprite = app.activeSprite
				local cel = app.activeCel
				local image = cel.image

				local width = sprite.width
				local height = sprite.height

				local color = 1

				if lookupDirection == "Vertical" then		
					for y = 0, image.height - 1 do
						for x = 0, image.width - 1 do
							color = applyColors(x, y, image, color)
						end
					end
				else
					for x = 0, image.width - 1 do
						for y = 0, image.height - 1 do
							color = applyColors(x, y, image, color)
						end
					end
				end

				app.refresh()
			end
		}

		dialog:combobox {
			id = "uv_lookup_id",
			label = "Lookup:",
			options = openTabs,
			onchange = function()
				selectedLookup = dialog.data.uv_lookup_id
			end
		}

		dialog:combobox {
			id = "uv_source_id",
			label = "Source:",
			options = openTabs,
			onchange = function()
				selectedSource = dialog.data.uv_source_id
			end
		}

		dialog:color {
			id = "uv_empty_color_id",
			label= "Empty Color:",
			color=emptyColor,
			onchange=function()
				emptyColor = dialog.data.uv_empty_color_id
			end
		}

		dialog:button { 
			id="uv_sync_id", 
			text="Sync", 
			onclick=function() 
				getSourceAndLookup()
				if createSourceTop() then
					return
				end
				app.refresh()
				sync() 
				app.refresh()
			end 
		}

		dialog:show { wait = false }
	end

	plugin:newCommand {
		id = "uvlookup_command_id",
		title = "UV lookup",
		group = "edit_insert",
		onclick=function()
			plugin.preferences.count = plugin.preferences.count+1
			uvlookup()
		end,
		onenabled=function()
			return true
		end
	}
end

function exit(plugin)
	print("Aseprite is closing uvlookup plugin")
end