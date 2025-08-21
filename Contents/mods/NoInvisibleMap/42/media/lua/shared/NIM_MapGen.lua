-- this function is called when the map is created. It generates it's map area and store it in it's mod data
function NIM_GenerateMap(sketch, playerCell, outside, playerCanSeeOutside, zIndex, pencilColor) 
    if sketch ~= nil then
        if sketch:getMapID() == "CustomMap" then
            local modData = sketch:getModData()

            --defualt values
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
                minX = math.ceil(minX - ((zIndex ^ 1.5) * 72))
                minY = math.ceil(minY - ((zIndex ^ 1.5) * 56))
                maxX = math.ceil(maxX + ((zIndex ^ 1.5) * 72))
                maxY = math.ceil(maxY + ((zIndex ^ 1.5) * 56))
            end

            local boxTable = {
                _minX = minX,
                _minY = minY,
                _maxX = maxX,
                _maxY = maxY
            }

            modData.custoMapData = boxTable
            modData.mapColor = pencilColor
        end
    end
end


-- This function it's used when you add a loot map to your world map
function NIM_AddRegion(worldMap, inputItem)
    local mapData = worldMap:getModData()
    local sketch = inputItem

    local mapRegions = mapData.mapRegions

    local _minX = 0
    local _minY = 0
    local _maxX = 0
    local _maxY = 0

    local mapUI = ISMap:new(0, 0, 0, 0, sketch, 0)
    local javaObject = UIWorldMap.new(mapUI)
    local mapAPI = javaObject:getAPIv1()

    mapUI.mapAPI = mapAPI
    mapUI.javaObject = javaObject

    LootMaps.callLua("Init", mapUI)
    
    local symbolsAPI = WorldMapSymbolsV2.new(javaObject, sketch:getSymbols())

    if sketch:getMapID() == "CustomMap" then
        local sketchData = sketch:getModData().custoMapData
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
    
    local n = symbolsAPI:getSymbolCount()
    
    for i=0, n - 1 do
        mapData.haveNewSymbols = true

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

    if mapRegions == nil then
        local data = {}
        table.insert(data, {
            minX = _minX,
            minY = _minY,
            maxX = _maxX,
            maxY = _maxY
        })
        mapData.mapRegions = data
    else
        table.insert(mapData.mapRegions, {
            minX = _minX,
            minY = _minY,
            maxX = _maxX,
            maxY = _maxY
        })
    end

    mapData.haveNewRegions = true

    local playerObj = getPlayer()

    ISTimedActionQueue.clear(playerObj)
    ISTimedActionQueue.add(ISReadWorldMap:new(playerObj))
end


-- This function is called when you create a world map using one of the three recipes
function NIM_generateWorldMapId(recipeData, character)
    local output = recipeData:getFirstCreatedItem()
    local modData = output:getModData()

    modData.id = NIM_MapIdGenerator()
end

function NIM_MapIdGenerator()
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local result = ''
    for i = 1, 32 do
        local index = ZombRand(62)
        result = result .. chars:sub(index, index)
    end
    return result
end