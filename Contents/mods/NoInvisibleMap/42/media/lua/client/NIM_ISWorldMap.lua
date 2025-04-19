require "ISUI/ISPanelJoypad"

-- initializes world map custom data (known regions, symbols, annotations and points of interest)
function NIM_AddMapData()
	local symbolsApi = ISWorldMap_instance.mapAPI:getSymbolsAPI()

	local playerModData = getPlayer():getModData()
	local playerInventory = getPlayer():getInventory()

	WorldMapVisited.getInstance():forget()

	local map = playerInventory:FindAll("HandmadeMap")

	if map ~= nil then
		map = map:get(0)
		local mapData = map:getModData()
		
		if mapData.mapRegions ~= nil then
			for _, v in pairs(mapData.mapRegions) do
				WorldMapVisited.getInstance():setVisitedInSquares(v.minX, v.minY, v.maxX, v.maxY)
			end
		end

		if mapData.haveNewSymbols or mapData.id ~= (playerModData.lastReadMap or "") then 
			symbolsApi:clear()

			if mapData.symbols ~= nil then
				for _, v in pairs(mapData.symbols) do
					local textureSymbol = symbolsApi:addTexture(v.symbol, v.x, v.y)
					textureSymbol:setRGBA(v.r, v.g, v.b, 1.0)
					textureSymbol:setAnchor(0.5, 0.5)
					textureSymbol:setScale(ISMap.SCALE)
				end
			end
		
			if mapData.notes ~= nil then
				for _, v in pairs(mapData.notes) do
					local textSymbol = symbolsApi:addUntranslatedText(v.text, UIFont.SdfCaveat, v.x, v.y)
					textSymbol:setRGBA(v.r, v.g, v.b, 1.0)
					textSymbol:setAnchor(0.0, 0.0)
					textSymbol:setScale(ISMap.SCALE)
				end
			end

			if playerModData.pointsOfInterest ~= nil then
				for _, v in pairs(playerModData.pointsOfInterest) do
					local textureSymbol = symbolsApi:addTexture(v.symbol, v.x, v.y)
					textureSymbol:setRGBA(v.r, v.g, v.b, 1.0)
					textureSymbol:setAnchor(0.5, 0.5)
					textureSymbol:setScale(ISMap.SCALE)
				end

				playerModData.haveNewPointOfInterest = false
			end
		end
	end

	if playerModData.haveNewPointOfInterest then
		if playerModData.pointsOfInterest ~= nil then
			for _, v in pairs(playerModData.pointsOfInterest) do
				local textureSymbol = symbolsApi:addTexture(v.symbol, v.x, v.y)
				textureSymbol:setRGBA(v.r, v.g, v.b, 1.0)
				textureSymbol:setAnchor(0.5, 0.5)
				textureSymbol:setScale(ISMap.SCALE)
			end
		end

		playerModData.haveNewPointOfInterest = false
	end
end

-- Updates world map custom data (known regions, symbols, annotations and points of interest)
function NIM_UpdateMapData()
	local symbolsAPI = ISWorldMap_instance.mapAPI:getSymbolsAPI()
	local playerModData = getPlayer():getModData()
	local playerInventory = getPlayer():getInventory()

	local maps = playerInventory:FindAll("HandmadeMap")
	local thisMap = nil

	if maps ~= nil then
		-- for _, v in pairs(maps) do
		-- 	if v.id == playerModData.lastReadMap then
		-- 		thisMap = v
		-- 		break
		-- 	end
		-- end

		thisMap = maps:get(0)
		--if thisMap == nil then return end

		local mapData = thisMap:getModData()
		mapData.symbols = {}
		mapData.notes = {}

		local n = symbolsAPI:getSymbolCount()
		
		for i=0, n - 1 do
			local symbol = symbolsAPI:getSymbolByIndex(i)

			if symbol:isText() then
				local mapNotes = mapData.notes

				if mapNotes == nil then
					local data = {}
					table.insert(data, {
						text = symbol:getUntranslatedText() or symbol:getTranslatedText(),
						x = symbol:getWorldX(),
						y = symbol:getWorldY(),
						r = symbol:getRed(),
						g = symbol:getGreen(),
						b = symbol:getBlue()
					})

					mapData.notes = data
				else
					table.insert(mapNotes, {
						text = symbol:getUntranslatedText() or symbol:getTranslatedText(),
						x = symbol:getWorldX(),
						y = symbol:getWorldY(),
						r = symbol:getRed(),
						g = symbol:getGreen(),
						b = symbol:getBlue()
					})
				end
			else
				local mapSymbols = mapData.symbols

				if mapSymbols == nil then
					local data = {}
					table.insert(data, {
						symbol = symbol:getSymbolID(),
						x = symbol:getWorldX(),
						y = symbol:getWorldY(),
						r = symbol:getRed(),
						g = symbol:getGreen(),
						b = symbol:getBlue()
					})

					mapData.symbols = data
				else
					table.insert(mapSymbols, {
						symbol = symbol:getSymbolID(),
						x = symbol:getWorldX(),
						y = symbol:getWorldY(),
						r = symbol:getRed(),
						g = symbol:getGreen(),
						b = symbol:getBlue()
					})
				end
			end
		end

		mapData.haveNewSymbols = false
	end

end

function NIM_ISWorldMapOverrides()
    -- function override
    -- disables the perspective button
    function ISWorldMap:createChildren()
        local symbolsWidth = ISWorldMapSymbols.RequiredWidth()
        self.symbolsUI = ISWorldMapSymbols:new(self.width - UI_BORDER_SPACING - symbolsWidth, UI_BORDER_SPACING, symbolsWidth, self.height - 40 * 2, self)
        self.symbolsUI:initialise()
        self.symbolsUI:setAnchorLeft(false)
        self.symbolsUI:setAnchorRight(true)
        self:addChild(self.symbolsUI)
    
        self.keyUI = ISWorldMapKey:new(UI_BORDER_SPACING, UI_BORDER_SPACING, 10, 200, self)
        self.keyUI:initialise()
        self.keyUI:setAnchorLeft(true)
        self.keyUI:setAnchorRight(false)
        self.keyUI:setIso(self.isometric)
        self:addChild(self.keyUI)
    
        local btnSize = self.texViewIsometric and self.texViewIsometric:getWidth() or 48
    
        self.buttonPanel = ISWorldMapButtonPanel:new(self.width - 200, self.height - UI_BORDER_SPACING - btnSize, 200, btnSize)
        self.buttonPanel.anchorLeft = false
        self.buttonPanel.anchorRight = true
        self.buttonPanel.anchorTop = false
        self.buttonPanel.anchorBottom = true
        self:addChild(self.buttonPanel)
    
        local buttons = {}
    
        self.optionBtn = ISButton:new(0, 0, btnSize, btnSize, getText("UI_mainscreen_option"), self, self.onChangeOptions)
        self.buttonPanel:addChild(self.optionBtn)
        table.insert(buttons, self.optionBtn)
    
        self.zoomInButton = ISButton:new(buttons[#buttons]:getRight() + UI_BORDER_SPACING, 0, btnSize, btnSize, "+", self, self.onZoomInButton)
        self.buttonPanel:addChild(self.zoomInButton)
        table.insert(buttons, self.zoomInButton)
    
        self.zoomOutButton = ISButton:new(buttons[#buttons]:getRight() + UI_BORDER_SPACING, 0, btnSize, btnSize, "-", self, self.onZoomOutButton)
        self.buttonPanel:addChild(self.zoomOutButton)
        table.insert(buttons, self.zoomOutButton)
    
        if getDebug() then
            self.pyramidBtn = ISButton:new(buttons[#buttons]:getRight() + UI_BORDER_SPACING, 0, btnSize, btnSize, "", self, self.onTogglePyramid)
            self.pyramidBtn:setImage(self.texViewPyramid)
            self.buttonPanel:addChild(self.pyramidBtn)
            table.insert(buttons, self.pyramidBtn)
        end
    
        --[[
        self.perspectiveBtn = ISButton:new(buttons[#buttons]:getRight() + UI_BORDER_SPACING, 0, btnSize, btnSize, "", self, self.onChangePerspective)
        self.perspectiveBtn:setImage(self.isometric and self.texViewIsometric or self.texViewOrthographic)
        self.buttonPanel:addChild(self.perspectiveBtn)
        table.insert(buttons, self.perspectiveBtn)
        ]]
    
        self.centerBtn = ISButton:new(buttons[#buttons]:getRight() + UI_BORDER_SPACING, 0, btnSize, btnSize, "C", self, self.onCenterOnPlayer)
        self.buttonPanel:addChild(self.centerBtn)
        table.insert(buttons, self.centerBtn)
        
    
        self.symbolsBtn = ISButton:new(buttons[#buttons]:getRight() + UI_BORDER_SPACING, 0, btnSize, btnSize, "S", self, self.onToggleSymbols)
        self.buttonPanel:addChild(self.symbolsBtn)
        table.insert(buttons, self.symbolsBtn)
    
        self.forgetBtn = ISButton:new(buttons[#buttons]:getRight() + UI_BORDER_SPACING, 0, btnSize, btnSize, "?", self, function(self, button) self:onForget(button) end)
        self.buttonPanel:addChild(self.forgetBtn)
        table.insert(buttons, self.forgetBtn)
    
        self.closeBtn = ISButton:new(buttons[#buttons]:getRight() + UI_BORDER_SPACING, 0, btnSize, btnSize, getText("UI_btn_close"), self, self.close)
        self.buttonPanel:addChild(self.closeBtn)
        table.insert(buttons, self.closeBtn)
    
        self.buttonPanel:shrinkWrap(0, 0, nil)
        self.buttonPanel:setX(self.width - UI_BORDER_SPACING - self.buttonPanel.width)
    
        self.buttonPanel:insertNewListOfButtons(buttons)
        self.buttonPanel.joypadIndex = 1
        self.buttonPanel.joypadIndexY = 1
    end
    
    -- function override
    -- disables player view and isometric perspective
    function ISWorldMap:new(x, y, width, height)
        local o = ISPanelJoypad.new(self, x, y, width, height)
        o:noBackground()
        o.anchorRight = true
        o.anchorBottom = true
        o.showCellGrid = false
        o.showTileGrid = false
        o.showPlayers = false
        o.showRemotePlayers = false
        o.showPlayerNames = false
        o.hideUnvisitedAreas = true
        o.isometric = false
        o.character = nil
        o.playerNum = character and character:getPlayerNum() or 0
        o.cross = getTexture("media/ui/LootableMaps/mapCross.png")
        o.texViewIsometric = getTexture("media/textures/worldMap/ViewIsometric.png")
        o.texViewOrthographic = getTexture("media/textures/worldMap/ViewOrtho.png")
        o.texViewPyramid = getTexture("media/textures/worldMap/ViewPyramid.png")
        return o
    end

    -- function override
    -- disabling perspective button setImage call (button no longer exists)
    function ISWorldMap:render()
        getWorld():setDrawWorld(false)
    
        local INSET = 0
        local w = getCore():getScreenWidth() - INSET * 2
        local h = getCore():getScreenHeight() - INSET * 2
        if self.width ~= w or self.height ~= h then
            self:setWidth(w)
            self:setHeight(h)
        end
    
        self.isometric = self.mapAPI:getBoolean("Isometric")
        --self.perspectiveBtn:setImage(self.isometric and self.texViewIsometric or self.texViewOrthographic)
        self.keyUI:setIso(self.isometric)
    
        self:updateJoypad()
    
        if self.playerNum and ((self.playerNum ~= 0) or (JoypadState.players[self.playerNum+1] ~= nil and not wasMouseActiveMoreRecentlyThanJoypad())) then
            self:drawTexture(self.cross, self.width/2-12, self.height/2-12, 1, 1,1,1);
        end
    
        if self.joyfocus then
            local joypadTexture = Joypad.Texture.YButton
            self:drawTexture(joypadTexture, self.buttonPanel.x - 16 - joypadTexture:getWidth(), self.buttonPanel.y + (self.buttonPanel.height - joypadTexture:getHeight()) / 2, 1, 1, 1, 1)
    
            self.joypadPromptHgt = math.max(32, FONT_HGT_LARGE)
            self:renderJoypadPrompt(Joypad.Texture.XButton, getText("IGUI_Map_EditMarkings"), 16, self.height - 16 - self.joypadPromptHgt)
    
            if self.symbolsUI.currentTool then
                self:renderJoypadPrompt(Joypad.Texture.BButton, getText("UI_Cancel"), self.buttonPanel.x - 16 - 32, self.buttonPanel.y - 10 - self.joypadPromptHgt - 10 - self.joypadPromptHgt)
                local text = self.symbolsUI:getJoypadAButtonText()
                if text then
                    self:renderJoypadPrompt(Joypad.Texture.AButton, text, self.buttonPanel.x - 16 - 32, self.buttonPanel.y - 10 - self.joypadPromptHgt)
                end
            end
    
            self:renderJoypadPrompt(Joypad.Texture.LTrigger, getText("IGUI_Map_ZoomOut"), 16, self.height - 16 - self.joypadPromptHgt - 8 - self.joypadPromptHgt)
            self:renderJoypadPrompt(Joypad.Texture.RTrigger, getText("IGUI_Map_ZoomIn"), 16, self.height - 16 - self.joypadPromptHgt - 8 - self.joypadPromptHgt - 8 - self.joypadPromptHgt)
        end
    
        -- change to make the chat window visible when the map is open
        if isClient() then
            ISChat.chat:setVisible(true);
            ISChat.chat:bringToTop()
        end
    
        ISPanelJoypad.render(self)
    end

    -- function override
    -- adding NIM_AddMapData call
    function ISWorldMap.ShowWorldMap(playerNum, centerX, centerY, zoom)
        local player = getPlayer()
        local playerModData = player:getModData()
        local playerInv = player:getInventory()
    
        local mapModData = nil
    
        if not ISWorldMap.IsAllowed() or not playerInv:contains("HandmadeMap") then
            player:Say("No World map found")
            return
        end
    
        playerModData.isWorldMapOpen = true
    
        local map = playerInv:FindAll("HandmadeMap")
    
        if map ~= nil then
            map = map:get(0)
            mapModData = map:getModData()
        end
    
        if not ISWorldMap_instance then
            local INSET = 0
            ISWorldMap_instance = ISWorldMap:new(INSET, INSET, getCore():getScreenWidth() - INSET * 2, getCore():getScreenHeight() - INSET * 2)
            ISWorldMap_instance:initialise()
            ISWorldMap_instance:instantiate()
    
            ISWorldMap_instance.character = getSpecificPlayer(playerNum)
            ISWorldMap_instance.playerNum = playerNum
            ISWorldMap_instance.symbolsUI.character = getSpecificPlayer(playerNum)
            ISWorldMap_instance.symbolsUI.playerNum = playerNum
            ISWorldMap_instance.symbolsUI:checkInventory()
            ISWorldMap_instance:initDataAndStyle()
            ISWorldMap_instance:setHideUnvisitedAreas(ISWorldMap_instance.hideUnvisitedAreas)
            ISWorldMap_instance:setShowPlayers(ISWorldMap_instance.showPlayers)
            ISWorldMap_instance:setShowRemotePlayers(ISWorldMap_instance.showRemotePlayers)
            ISWorldMap_instance:setShowPlayerNames(ISWorldMap_instance.showPlayerNames)
            ISWorldMap_instance:setShowCellGrid(ISWorldMap_instance.showCellGrid)
            ISWorldMap_instance:setShowTileGrid(ISWorldMap_instance.showTileGrid)
            ISWorldMap_instance:setIsometric(ISWorldMap_instance.isometric)
            ISWorldMap_instance.mapAPI:resetView()
            if ISWorldMap_instance.character then
                ISWorldMap_instance.mapAPI:centerOn(ISWorldMap_instance.character:getX(), ISWorldMap_instance.character:getY())
                ISWorldMap_instance.mapAPI:setZoom(zoom and zoom or 18.0)
            end
            ISWorldMap_instance:restoreSettings()
    
            if centerX and centerY then
                ISWorldMap_instance.mapAPI:centerOn(centerX, centerY)
                ISWorldMap_instance.mapAPI:setZoom(zoom and zoom or 18.0)
            end
    
            --first call when game loads
            NIM_AddMapData()
            playerModData.lastReadMap = mapModData.id
    
            ISWorldMap_instance:addToUIManager()
            ISWorldMap_instance.getJoypadFocus = true
            for i=1,getNumActivePlayers() do
                if getSpecificPlayer(i-1) then
                    getSpecificPlayer(i-1):setBlockMovement(true)
                end
            end
            return
        end
    
        ISWorldMap_instance.character = getSpecificPlayer(playerNum)
        ISWorldMap_instance.playerNum = playerNum
        ISWorldMap_instance.symbolsUI.character = getSpecificPlayer(playerNum)
        ISWorldMap_instance.symbolsUI.playerNum = playerNum
        ISWorldMap_instance.symbolsUI:checkInventory()
        if centerX and centerY then
            ISWorldMap_instance.mapAPI:centerOn(centerX, centerY)
            ISWorldMap_instance.mapAPI:setZoom(zoom and zoom or 18.0)
        end
    
        --called every other time
        NIM_AddMapData()
        playerModData.lastReadMap = mapModData.id
    
        ISWorldMap_instance:setVisible(true)
        ISWorldMap_instance:addToUIManager()
        ISWorldMap_instance.getJoypadFocus = true
    
        if MainScreen.instance.inGame then
            for i=1,getNumActivePlayers() do
                if getSpecificPlayer(i-1) then
                    getSpecificPlayer(i-1):setBlockMovement(true)
                end
            end
        else
            ISWorldMap_instance:setHideUnvisitedAreas(false)
        end
    end

    -- fucntion override
    -- adding NIM_UpdateMapData call
    function ISWorldMap:close()
        NIM_UpdateMapData()
        
        local playerModData = getPlayer():getModData()
        playerModData.isWorldMapOpen = false
    
        self:saveSettings()
        self.symbolsUI:undisplay()
        if self.forgetUI then
            self.forgetUI.no:forceClick()
        end
        self:setVisible(false)
        self:removeFromUIManager()
        if getSpecificPlayer(0) then
            getWorld():setDrawWorld(true)
        end
        for i=1,getNumActivePlayers() do
            if getSpecificPlayer(i-1) then
                getSpecificPlayer(i-1):setBlockMovement(false)
            end
        end
        if JoypadState.players[self.playerNum+1] then
            setJoypadFocus(self.playerNum, nil)
        end
        if MainScreen.instance and not MainScreen.instance.inGame then
            -- Debug in main menu
            self:setHideUnvisitedAreas(true)
            ISWorldMap_instance = nil
            WorldMapVisited.Reset()
        end
        if self.character then
            self.character:playSoundLocal("MapClose")
        end
    end
end

Events.OnGameStart.Add(NIM_ISWorldMapOverrides)