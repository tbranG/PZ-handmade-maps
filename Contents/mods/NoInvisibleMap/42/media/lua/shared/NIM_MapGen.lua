-- this function is called when the map is created. It generates it's map area and store it in it's mod data
function NIM_GenerateMap(sketch, playerCell, outside, playerCanSeeOutside, zIndex, pencilColor) 
    if sketch ~= nil then
        if sketch:getMapID() == "CustomMap" then
            --default values
            local cellX = math.floor(playerCell:getMinX() / 256)
            local cellY = math.floor(playerCell:getMinY() / 256)

            local minX = NIM.Utils.Round(cellX * 256)
            local minY = NIM.Utils.Round(cellY * 256)
            local maxX = NIM.Utils.Round((cellX * 256) + 256)
            local maxY = NIM.Utils.Round((cellY * 256) + 256)
            
            if not outside and not playerCanSeeOutside then
                sketch:setName("Empty Sketch")
                minX = 0
                minY = 0
                maxX = 0
                maxY = 0
            end

            if zIndex > 0 then
                local viewOffset = NIM.Config.lvl_one_area
                
                if zIndex == 2 then 
                    viewOffset = NIM.Config.lvl_two_area 
                elseif zIndex > 2 then
                    viewOffset = NIM.Config.lvl_three_area
                end 

                minX = math.ceil(minX - ((zIndex ^ viewOffset) * 64))
                minY = math.ceil(minY - ((zIndex ^ viewOffset) * 64))
                maxX = math.ceil(maxX + ((zIndex ^ viewOffset) * 64))
                maxY = math.ceil(maxY + ((zIndex ^ viewOffset) * 64))
            end

            local boxTable = {
                _minX = minX - 32,
                _minY = minY,
                _maxX = maxX + 32,
                _maxY = maxY
            }

            local modData = sketch:getModData()

            modData.custoMapData = boxTable
            modData.mapColor = pencilColor

            -- ensure the map has a unique id
            if modData.id == nil then
                modData.id = NIM.Utils.GenerateMapId()
            end

            if isServer() then
                sketch:transmitModData()
            end
        end
    end
end


-- This function it's used when you add a loot map to your world map
function NIM_AddRegion(worldMap, inputItem)
    local mapData = worldMap:getModData()

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

    local xdiff = math.ceil((_maxX - _minX) / 256)
    local ydiff = math.ceil((_maxY - _minY) / 256)

    local rectConstraints = {
        minX = NIM.Utils.Round(_minX / 256) * 256,
        minY = NIM.Utils.Round(_minY / 256) * 256,
        maxX = NIM.Utils.Round(((_minX / 256) * 256) + (256 * xdiff)),
        maxY = NIM.Utils.Round(((_minY / 256) * 256) + (256 * ydiff))
    }

    local numCells, alreadyCovered = 0, 0

    for rx = rectConstraints.minX, rectConstraints.maxX - 256, 256 do
        for ry = rectConstraints.minY, rectConstraints.maxY - 256, 256 do
            numCells = numCells + 1

            local cx, cy = math.floor(rx/256), math.floor(ry/256)
            local strCoord = NIM.Utils.StringifyCellCoordinate(cx, cy)

            local box = {
                minX = math.floor(cx * 256),
                minY = math.floor(cy * 256),
                maxX = math.floor((cx * 256) + 256),
                maxY = math.floor((cy * 256) + 256)
            }

            if mapData.haveCells == nil then mapData.haveCells = {} end
            
            if mapData.haveCells[strCoord] then 
                alreadyCovered = alreadyCovered + 1 
            else
                if mapData.mapRegions == nil then
                    local data = {}
                    table.insert(data, box)
                    mapData.mapRegions = data
                else
                    table.insert(mapData.mapRegions, box)
                end
            end

            mapData.haveCells[strCoord] = true
        end
    end

    mapData.haveNewRegions = true

    if mapData.id == nil then
        mapData.id = NIM.Utils.GenerateMapId()
    end

    if isServer() then
        worldMap:transmitModData()
    end

    local playerObj = getPlayer()

    ISTimedActionQueue.clear(playerObj)
    ISTimedActionQueue.add(ReadNIMWorldMap:new(playerObj))
end


-- This function is called when you create a world map using one of the three recipes
function NIM_generateWorldMapId(recipeData, character)
    local output = recipeData:getFirstCreatedItem()
    local modData = output:getModData()

    modData.id = NIM.Utils.GenerateMapId()
end