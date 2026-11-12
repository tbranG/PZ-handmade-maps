--globals for easy access
local hider_lastTime = getTimestamp()
local fixer_lastTime = getTimestamp()

local quick_mapModData_ref = nil

-- initializes world map custom data (known regions, symbols, annotations and points of interest)
function NIM_AddMapData()
	local symbolsApi = NIM_WorldMap_Instance.mapAPI:getSymbolsAPIv2()

	local playerModData = getPlayer():getModData()
	local playerInventory = getPlayer():getInventory()

	local map = playerInventory:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.HandmadeMap" end)
    
	if map ~= nil then
		local mapData = map:getModData()
		playerModData.quickMapRef = mapData
		
		if mapData.haveNewSymbols or mapData.haveNewRegions or mapData.id ~= (playerModData.lastReadMap or "") then 
            WorldMapVisited.getInstance():forget()
			symbolsApi:clear()
            
            if mapData.mapRegions ~= nil then
                for _, v in pairs(mapData.mapRegions) do
                    WorldMapVisited.getInstance():setVisitedInSquares(v.minX, v.minY, v.maxX, v.maxY)
                end
            end

            mapData.haveNewRegions = false

			if mapData.symbols ~= nil then
				for _, v in pairs(mapData.symbols) do
					local textureSymbol = symbolsApi:addTexture(v.symbol, v.x, v.y)
					textureSymbol:setRGBA(v.r, v.g, v.b, 1.0)
					textureSymbol:setAnchor(0.5, 0.5)
					textureSymbol:setScale(v.scale)
                    textureSymbol:setRotation(v.rotation)
				end
			end
		
			if mapData.notes ~= nil then
				for _, v in pairs(mapData.notes) do
                    local layerID = symbolsApi:getDefaultTextLayerID()
					local textSymbol = symbolsApi:addUntranslatedText(v.text, layerID, v.x, v.y)
					textSymbol:setRGBA(v.r, v.g, v.b, 1.0)
					textSymbol:setAnchor(0.0, 0.0)
					textSymbol:setScale(v.scale)
                    textSymbol:setRotation(v.rotation)
				end
			end
		end

        if playerModData.haveNewPointOfInterest then
            if playerModData.pointsOfInterest ~= nil then
                for _, v in pairs(playerModData.pointsOfInterest) do
                    local textureSymbol = symbolsApi:addTexture(v.symbol, v.x, v.y)
                    textureSymbol:setRGBA(v.r, v.g, v.b, 1.0)
                    textureSymbol:setAnchor(0.5, 0.5)
                    textureSymbol:setScale(v.scale)
    
                    if mapData.symbols ~= nil then
                        table.insert(mapData.symbols, {
                                symbol = v.symbol,
                                x = v.x,
                                y = v.y,
                                r = v.r,
                                g = v.g,
                                b = v.b,
                                scale = v.scale,
                                rotation = 0
                            })
                    end
                end
            end
    
            playerModData.haveNewPointOfInterest = false
    
            --clear points of interest so it doesn't get added again
            playerModData.pointsOfInterest = nil
        end
	end

end

-- Updates world map custom data (symbols, annotations and points of interest)
function NIM_UpdateMapData()
	local symbolsAPI = NIM_WorldMap_Instance.mapAPI:getSymbolsAPIv2()
	local playerModData = getPlayer():getModData()
	local playerInventory = getPlayer():getInventory()

	local map = playerInventory:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.HandmadeMap" end)

	if map ~= nil then
		local mapData = map:getModData()
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
						b = symbol:getBlue(),
                        scale = symbol:getScale(),
                        rotation = symbol:getRotation()
					})

					mapData.notes = data
				else
					table.insert(mapNotes, {
						text = symbol:getUntranslatedText() or symbol:getTranslatedText(),
						x = symbol:getWorldX(),
						y = symbol:getWorldY(),
						r = symbol:getRed(),
						g = symbol:getGreen(),
						b = symbol:getBlue(),
                        scale = symbol:getScale(),
                        rotation = symbol:getRotation()
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
						b = symbol:getBlue(),
                        scale = symbol:getScale(),
                        rotation = symbol:getRotation()
					})

					mapData.symbols = data
				else
					table.insert(mapSymbols, {
						symbol = symbol:getSymbolID(),
						x = symbol:getWorldX(),
						y = symbol:getWorldY(),
						r = symbol:getRed(),
						g = symbol:getGreen(),
						b = symbol:getBlue(),
                        scale = symbol:getScale(),
                        rotation = symbol:getRotation()
					})
				end
			end
		end

		mapData.haveNewSymbols = false
		playerModData.quickMapRef = nil
	end

end

-- Add a visited region to player's modData
function NIM_CreateMemoryRegion(player)
    local playerModData = player:getModData()

	if playerModData.known == nil then playerModData.known = {} end
	if playerModData.visitedRegions == nil then playerModData.visitedRegions = {} end
	
    local cellX = math.floor(player:getX() / 256)
    local cellY = math.floor(player:getY() / 256)

    local strCoord = NIM.Utils.StringifyCellCoordinate(cellX, cellY)
    local alreadyVisited = playerModData.known[strCoord] ~= nil

    if alreadyVisited then return end

    playerModData.known[strCoord] = true
    local newBox = {
        minX = cellX * 256,
        maxX = (cellX * 256) + 256,
        minY = cellY * 256,
        maxY = (cellY * 256) + 256
    }
	
	HaloTextHelper.addGoodText(player, getText("IGUI_NIM_NewVisitedRegion"))
    table.insert(playerModData.visitedRegions, newBox)
end

function NIM_MapPosHider()
	local player = getPlayer()
    local playerModData = player:getModData()

	local currentTime = getTimestamp()
    local dt = (currentTime - hider_lastTime) / 1000.0
	hider_lastTime = currentTime

	local playerModData = player:getModData()

	playerModData.hiderTick = playerModData.hiderTick or 0
	playerModData.hiderTick = playerModData.hiderTick + dt

	if playerModData.hiderTick < 0.0005 then return end
	playerModData.hiderTick = 0

    local worldMapVisitedInstance = WorldMapVisited.getInstance()

	local cellX = math.floor(player:getX() / 256)
    local cellY = math.floor(player:getY() / 256)

    local strCoord = NIM.Utils.StringifyCellCoordinate(cellX, cellY)

	local mapModData = quick_mapModData_ref or playerModData.quickMapRef
	if mapModData == nil then
		local mapObj = player:getInventory():getAllTypeRecurse("HandmadeMap")
		if mapObj ~= nil and mapObj:size() > 0  then
			mapObj = mapObj:get(0)
			quick_mapModData_ref = mapObj:getModData()
		end
	end

	if mapModData == nil or (mapModData.haveCells and (mapModData.haveCells[strCoord] or false)) then return end
    
	local minX = NIM.Utils.Round(cellX * 256)
    local minY = NIM.Utils.Round(cellY * 256)
    local maxX = NIM.Utils.Round((cellX * 256) + 256)
    local maxY = NIM.Utils.Round((cellY * 256) + 256)

    worldMapVisitedInstance:clearKnownInSquares(
        minX + 32,
        minY + 32,
        maxX - 32,
        maxY - 32
    )
    worldMapVisitedInstance:clearVisitedInSquares(
        minX + 32,
        minY + 32,
        maxX - 32,
        maxY - 32
    )
end

function NIM_MapAdjRegionsFixer()
	local player = getPlayer()
	local playerModData = player:getModData()

	local mapModData = quick_mapModData_ref or playerModData.quickMapRef
	if mapModData == nil then
		local mapObj = player:getInventory():getAllTypeRecurse("HandmadeMap")
		if mapObj ~= nil and mapObj:size() > 0  then
			mapObj = mapObj:get(0)
			quick_mapModData_ref = mapObj:getModData()
		end
	end

	if not playerModData.NIM_WorldMapOpen then return end

	local currentTime = getTimestamp()
    local dt = (currentTime - fixer_lastTime) / 1000.0
	fixer_lastTime = currentTime

	playerModData.fixerTick = playerModData.fixerTick or 0
	playerModData.fixerTick = playerModData.fixerTick + dt

	if playerModData.fixerTick < 0.05 then return end
	playerModData.fixerTick = 0

    local worldMapVisitedInstance = WorldMapVisited.getInstance()

	local cellX = math.floor(player:getX() / 256)
    local cellY = math.floor(player:getY() / 256)
	local strCoord = NIM.Utils.StringifyCellCoordinate(cellX, cellY)

	if mapModData == nil then return end
	if mapModData.haveCells and (mapModData.haveCells[strCoord] or false) then return end

	for dx = -1, 1 do
        for dy = -1, 1 do
            if math.abs(dx) + math.abs(dy) == 1 then
                local x = cellX + dx
                local y = cellY + dy
                strCoord = NIM.Utils.StringifyCellCoordinate(x, y)

                if mapModData.haveCells[strCoord] then
                    local minX = NIM.Utils.Round(x * 256)
                    local minY = NIM.Utils.Round(y * 256)
                    local maxX = NIM.Utils.Round((x * 256) + 256)
                    local maxY = NIM.Utils.Round((y * 256) + 256)
                    worldMapVisitedInstance:setVisitedInSquares(minX, minY, maxX, maxY)
                end
            end
        end
    end
end

Events.OnPlayerUpdate.Add(NIM_CreateMemoryRegion)

Events.OnTick.Add(NIM_MapPosHider)
Events.OnTick.Add(NIM_MapAdjRegionsFixer)