-- this function is called when the map is created. It generates it's map area and store it in it's mod data
function NIM_GenerateMap(sketch, playerCell, outside, playerCanSeeOutside, zIndex, pencilColor) 
    if sketch ~= nil then
        if sketch:getMapID() == "CustomMap" then
            --default values
            local minX = playerCell:getMinX() - 96
            local minY = playerCell:getMinY() - 60
            local maxX = playerCell:getMaxX() + 96
            local maxY = playerCell:getMaxY() + 60
            
            if not outside and not playerCanSeeOutside then
                sketch:setName("Empty Sketch")
                minX = 0
                minY = 0
                maxX = 0
                maxY = 0
            end

            if zIndex > 0 then
                local viewOffset = NIM.Config.lvl_one_area
                
                if viewOffset == 2 then 
                    viewOffset = NIM.Config.lvl_two_area 
                else
                    viewOffset = NIM.Config.lvl_three_area
                end 

                minX = math.ceil(minX - ((zIndex ^ viewOffset) * 72))
                minY = math.ceil(minY - ((zIndex ^ viewOffset) * 56))
                maxX = math.ceil(maxX + ((zIndex ^ viewOffset) * 72))
                maxY = math.ceil(maxY + ((zIndex ^ viewOffset) * 56))
            end

            local boxTable = {
                _minX = minX,
                _minY = minY,
                _maxX = maxX,
                _maxY = maxY
            }

            local modData = sketch:getModData()

            modData.custoMapData = boxTable
            modData.mapColor = pencilColor

            -- ensure the map has a unique id for synchronization
            if modData.id == nil then
                modData.id = NIM.Utils.GenerateMapId()
            end

            if isClient() and not isServer() then
                sendClientCommand(
                    getPlayer(),
                    "NIM",
                    "SyncMap",
                    { id = modData.id, modData = modData }
                )
            elseif isServer() then
                sketch:transmitModData()
            end
        end
    end
end


-- This function it's used when you add a loot map to your world map
function NIM_AddRegion(worldMap, inputItem)
    local mapData = worldMap:getModData()
    local mapRegions = mapData.mapRegions

    local _minX = 0
    local _minY = 0
    local _maxX = 0
    local _maxY = 0

    local mapUI = ISMap:new(0, 0, 0, 0, inputItem, 0)
    local javaObject = UIWorldMap.new(mapUI)
    local mapAPI = javaObject:getAPIv1()

    mapUI.mapAPI = mapAPI
    mapUI.javaObject = javaObject

    LootMaps.callLua("Init", mapUI)

    -- from now on i will use the object modData to store each symbol,
    -- that's because for some reason TIS decided to hide getSymbols() method.
    -- ugly ass hack
    local modData = inputItem:getModData()
    local itemSymbols = modData.symbols
    local itemNotes = modData.notes

    if inputItem:getMapID() == "CustomMap" then
        local sketchData = inputItem:getModData().custoMapData
        _minX = sketchData._minX
        _minY = sketchData._minY
        _maxX = sketchData._maxX
        _maxY = sketchData._maxY
    else
        _minX = mapUI.mapAPI:getMinXInSquares()
        _minY = mapUI.mapAPI:getMinYInSquares()
        _maxX = mapUI.mapAPI:getMaxXInSquares()
        _maxY = mapUI.mapAPI:getMaxYInSquares()
    end

    mapData.haveNewSymbols = itemSymbols ~= nil or itemNotes ~= nil

    if itemSymbols ~= nil then
        for _, v in pairs(itemSymbols) do
            local mapSymbols = mapData.symbols
            local symbolData = {
                symbol = v.symbol,
                x = v.x,
                y = v.y,
                r = v.r,
                g = v.g,
                b = v.b,
                scale = v.scale,
                rotation = v.rotation
            }
    
            if mapSymbols == nil then
                local data = {}
                table.insert(data, symbolData)

                mapData.symbols = data
            else
                table.insert(mapSymbols, symbolData)
            end
        end
    end
		
    if itemNotes ~= nil then
        for _, v in pairs(itemNotes) do
            local mapNotes = mapData.notes
            local noteData = {
                text = v.text,
                x = v.x,
                y = v.y,
                r = v.r,
                g = v.g,
                b = v.b,
                scale = v.scale,
                rotation = v.rotation
            }
    
            if mapNotes == nil then
                local data = {}
                table.insert(data, noteData)

                mapData.notes = data
            else
                table.insert(mapNotes, noteData)
            end
        end
    end

    local rectConstraints = {
        minX = _minX,
        minY = _minY,
        maxX = _maxX,
        maxY = _maxY
    }

    if mapRegions == nil then
        local data = {}
        table.insert(data, rectConstraints)
        mapData.mapRegions = data
    else
        table.insert(mapData.mapRegions, rectConstraints)
    end

    mapData.haveNewRegions = true

    if isClient() and not isServer() then
        if mapData.id == nil then
            mapData.id = NIM.Utils.GenerateMapId()
        end

        sendClientCommand(
            getPlayer(),
            "NIM",
            "SyncMap",
            { id = mapData.id, modData = mapData }
        )
    elseif isServer() then
        worldMap:transmitModData()
    end

    local playerObj = getPlayer()

    ISTimedActionQueue.clear(playerObj)
    ISTimedActionQueue.add(ISReadWorldMap:new(playerObj))
end


-- This function is called when you create a world map using one of the three recipes
function NIM_generateWorldMapId(recipeData, character)
    local output = recipeData:getFirstCreatedItem()
    local modData = output:getModData()

    modData.id = NIM.Utils.GenerateMapId()
end