-- if ISWorldMap_instance is null, then we will force it's init
function NIM_InitWorldMap() 
	local INSET = 0
	local playerNum = getPlayer():getPlayerNum()
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
		ISWorldMap_instance.mapAPI:setZoom(18.0)
	end
	ISWorldMap_instance:restoreSettings()
	ISWorldMap_instance:addToUIManager()
	ISWorldMap_instance.getJoypadFocus = true
	ISWorldMap_instance.symbolsUI:undisplay()
	ISWorldMap_instance:setVisible(false)
	ISWorldMap_instance:removeFromUIManager()
end

-- updates world map undiscovered area background
function NIM_overrideWorldMapBackground()
    if ISWorldMap_instance == nil then
        NIM_InitWorldMap()
    end
    
    local mapUI = ISWorldMap_instance
    local mapAPI = mapUI.javaObject:getAPIv1()

    local cr,cg,cb = 227/255, 227/255, 227/255
    mapAPI:setUnvisitedRGBA(cr * 0.915, cg * 0.915, cb * 0.915, 1.0)
	mapAPI:setUnvisitedGridRGBA(1, 1, 1, 0) --set grid to be invisible
end

-- custom map definition
function NIM_InitCustomMap()
    MapUtils = MapUtils or {}

	LootMaps = LootMaps or {};
	LootMaps.Init = LootMaps.Init or {};
	
    local MINZ = 0
    local MINZ_BUILDINGS = 13
    
	local MAXZ = 24
	local WATER_TEXTURE = false

	local function replaceWaterStyle(mapUI)
		if not WATER_TEXTURE then return end
		local mapAPI = mapUI.javaObject:getAPIv1()
		local styleAPI = mapAPI:getStyleAPI()
		local layer = styleAPI:getLayerByName("water")
		if not layer then return end
		layer:setMinZoom(MINZ)
		layer:setFilter("water", "river")
		layer:removeAllFill()
		layer:removeAllTexture()
		layer:addFill(MINZ, 59, 141, 149, 255)
		layer:addFill(MAXZ, 59, 141, 149, 255)
	end

	local function overlayPNG(mapUI, x, y, scale, layerName, tex, alpha)
		local texture = getTexture(tex)
		if not texture then return end
		local mapAPI = mapUI.javaObject:getAPIv1()
		local styleAPI = mapAPI:getStyleAPI()
		local layer = styleAPI:newTextureLayer(layerName)
		layer:setMinZoom(MINZ)
		layer:addFill(MINZ, 255, 255, 255, (alpha or 1.0) * 255)
		layer:addTexture(MINZ, tex)
		layer:setBoundsInSquares(x, y, x + texture:getWidth() * scale, y + texture:getHeight() * scale)
	end
	
    
    -- custom styles 
    function MapUtils.initCustomStyleBlack(mapUI)
        local mapAPI = mapUI.javaObject:getAPIv1()
        local styleAPI = mapAPI:getStyleAPI()
    
        local ColorblindPatterns = getCore():getOptionColorblindPatterns()
        mapAPI:setBoolean("ColorblindPatterns", ColorblindPatterns)
    
        local r,g,b = 219/255, 215/255, 192/255
        local cr,cg,cb = 227/255, 227/255, 227/255
        mapAPI:setBackgroundRGBA(cr, cg, cb, 1.0)
        mapAPI:setUnvisitedRGBA(r * 0.915, g * 0.915, b * 0.915, 1.0)
        mapAPI:setUnvisitedGridRGBA(r * 0.777, g * 0.777, b * 0.777, 1.0)
    
        styleAPI:clear()
    
        local layer = styleAPI:newPolygonLayer("forest")
        layer:setMinZoom(13.5)
        layer:setFilter("natural", "forest")
        if true then
            layer:addFill(MINZ, 212, 212, 212, 0)
            layer:addFill(13.5, 212, 212, 212, 0)
            layer:addFill(14, 212, 212, 212, 255)
            layer:addFill(MAXZ, 212, 212, 212, 255)
        else
            layer:addFill(MINZ, 255, 255, 255, 255)
            layer:addFill(MAXZ, 255, 255, 255, 255)
            layer:addTexture(MINZ, "media/textures/worldMap/Grass.png")
            layer:addTexture(MAXZ, "media/textures/worldMap/Grass.png")
            layer:addScale(13.5, 4.0)
            layer:addScale(MAXZ, 4.0)
        end
        
        layer = styleAPI:newPolygonLayer("water")
        layer:setMinZoom(MINZ)
        layer:setFilter("water", "river")
        if not WATER_TEXTURE then
            layer:addFill(MINZ, 150, 150, 150, 255)
            layer:addFill(MAXZ, 150, 150, 150, 255)
        else
            layer:addFill(MINZ, 150, 150, 150, 255)
            layer:addFill(14.5, 150, 150, 150, 255)
            layer:addFill(14.5, 255, 255, 255, 255)
            layer:addTexture(MINZ, nil)
            layer:addTexture(14.5, nil)
            layer:addTexture(14.5, "media/textures/worldMap/Water.png")
            layer:addTexture(MAXZ, "media/textures/worldMap/Water.png")
    --		layer:addScale(MINZ, 4.0)
    --		layer:addScale(MAX, 4.0)
        end
    
        layer = styleAPI:newPolygonLayer("road-trail")
        layer:setMinZoom(12.0)
        layer:setFilter("highway", "trail")
        layer:addFill(12.25,155, 155, 155, 0)
        layer:addFill(13,155, 155, 155, 255)
        layer:addFill(MAXZ,155, 155, 155, 255)
    
        layer = styleAPI:newPolygonLayer("road-tertiary")
        layer:setMinZoom(11.0)
        layer:setFilter("highway", "tertiary")
        layer:addFill(11.5, 165, 165, 165, 0)
        layer:addFill(13, 165, 165, 165, 255)
        layer:addFill(MAXZ, 165, 165, 165, 255)
    
        layer = styleAPI:newPolygonLayer("road-secondary")
        layer:setMinZoom(11.0)
        layer:setFilter("highway", "secondary")
        layer:addFill(MINZ, 143, 142, 140, 255)
        layer:addFill(MAXZ, 143, 142, 140, 255)
    
        layer = styleAPI:newPolygonLayer("road-primary")
        layer:setMinZoom(11.0)
        layer:setFilter("highway", "primary")
        layer:addFill(MINZ, 120, 120, 120, 255)
        layer:addFill(MAXZ, 120, 120, 120, 255)
    
        layer = styleAPI:newPolygonLayer("railway")
        layer:setMinZoom(14.0)
        layer:setFilter("railway", "*")
        layer:addFill(MINZ, 190, 190, 190, 255)
        layer:addFill(MAXZ, 190, 190, 190, 255)
    
        -- Default, same as building-Residential
        layer = styleAPI:newPolygonLayer("building")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "yes")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Residential.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 130, 130, 130, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 130, 130, 130, 255)
        layer:addFill(MAXZ, 130, 130, 130, 255)
    
        layer = styleAPI:newPolygonLayer("building-Residential")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Residential")
        layer:addFill(MINZ_BUILDINGS, 130, 130, 130, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 130, 130, 130, 255)
        layer:addFill(MAXZ, 130, 130, 130, 255)
    
        layer = styleAPI:newPolygonLayer("building-CommunityServices")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "CommunityServices")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Community.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 130, 130, 130, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 130, 130, 130, 255)
        layer:addFill(MAXZ, 130, 130, 130, 255)
    
        layer = styleAPI:newPolygonLayer("building-Hospitality")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Hospitality")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Hospitality.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 130, 130, 130, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 130, 130, 130, 255)
        layer:addFill(MAXZ, 130, 130, 130, 255)
    
        layer = styleAPI:newPolygonLayer("building-Industrial")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Industrial")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Industrial.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 130, 130, 130, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 130, 130, 130, 255)
        layer:addFill(MAXZ, 130, 130, 130, 255)
    
        layer = styleAPI:newPolygonLayer("building-Medical")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Medical")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Medical.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 130, 130, 130, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 130, 130, 130, 255)
        layer:addFill(MAXZ, 130, 130, 130, 255)
    
        layer = styleAPI:newPolygonLayer("building-RestaurantsAndEntertainment")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "RestaurantsAndEntertainment")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_RestaurantsEntertainment.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 130, 130, 130, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 130, 130, 130, 255)
        layer:addFill(MAXZ, 130, 130, 130, 255)
    
        layer = styleAPI:newPolygonLayer("building-RetailAndCommercial")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "RetailAndCommercial")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_RetailCommercial.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 130, 130, 130, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 130, 130, 130, 255)
        layer:addFill(MAXZ, 130, 130, 130, 255)
    end
    
    
    function MapUtils.initCustomStyleRed(mapUI)
        local mapAPI = mapUI.javaObject:getAPIv1()
        local styleAPI = mapAPI:getStyleAPI()
    
        local ColorblindPatterns = getCore():getOptionColorblindPatterns()
        mapAPI:setBoolean("ColorblindPatterns", ColorblindPatterns)
    
        local r,g,b = 219/255, 215/255, 192/255
        local cr,cg,cb = 227/255, 227/255, 227/255
        mapAPI:setBackgroundRGBA(cr, cg, cb, 1.0)
        mapAPI:setUnvisitedRGBA(r * 0.915, g * 0.915, b * 0.915, 1.0)
        mapAPI:setUnvisitedGridRGBA(r * 0.777, g * 0.777, b * 0.777, 1.0)
    
        styleAPI:clear()
    
        local layer = styleAPI:newPolygonLayer("forest")
        layer:setMinZoom(13.5)
        layer:setFilter("natural", "forest")
        if true then
            layer:addFill(MINZ, 227, 213, 213, 0)
            layer:addFill(13.5, 227, 213, 213, 0)
            layer:addFill(14, 227, 213, 213, 255)
            layer:addFill(MAXZ, 227, 213, 213, 255)
        else
            layer:addFill(MINZ, 255, 255, 255, 255)
            layer:addFill(MAXZ, 255, 255, 255, 255)
            layer:addTexture(MINZ, "media/textures/worldMap/Grass.png")
            layer:addTexture(MAXZ, "media/textures/worldMap/Grass.png")
            layer:addScale(13.5, 4.0)
            layer:addScale(MAXZ, 4.0)
        end
        
        layer = styleAPI:newPolygonLayer("water")
        layer:setMinZoom(MINZ)
        layer:setFilter("water", "river")
        if not WATER_TEXTURE then
            layer:addFill(MINZ, 212, 188, 188, 255)
            layer:addFill(MAXZ, 212, 188, 188, 255)
        else
            layer:addFill(MINZ, 212, 188, 188, 255)
            layer:addFill(14.5, 212, 188, 188, 255)
            layer:addFill(14.5, 255, 255, 255, 255)
            layer:addTexture(MINZ, nil)
            layer:addTexture(14.5, nil)
            layer:addTexture(14.5, "media/textures/worldMap/Water.png")
            layer:addTexture(MAXZ, "media/textures/worldMap/Water.png")
    --		layer:addScale(MINZ, 4.0)
    --		layer:addScale(MAX, 4.0)
        end
    
        layer = styleAPI:newPolygonLayer("road-trail")
        layer:setMinZoom(12.0)
        layer:setFilter("highway", "trail")
        layer:addFill(12.25,232, 181, 181, 0)
        layer:addFill(13,232, 181, 181, 255)
        layer:addFill(MAXZ,232, 181, 181, 255)
    
        layer = styleAPI:newPolygonLayer("road-tertiary")
        layer:setMinZoom(11.0)
        layer:setFilter("highway", "tertiary")
        layer:addFill(11.5, 237, 168, 168, 0)
        layer:addFill(13, 237, 168, 168, 255)
        layer:addFill(MAXZ, 237, 168, 168, 255)
    
        layer = styleAPI:newPolygonLayer("road-secondary")
        layer:setMinZoom(11.0)
        layer:setFilter("highway", "secondary")
        layer:addFill(MINZ, 214, 133, 133, 255)
        layer:addFill(MAXZ, 214, 133, 133, 255)
    
        layer = styleAPI:newPolygonLayer("road-primary")
        layer:setMinZoom(11.0)
        layer:setFilter("highway", "primary")
        layer:addFill(MINZ, 227, 98, 98, 255)
        layer:addFill(MAXZ, 227, 98, 98, 255)
    
        layer = styleAPI:newPolygonLayer("railway")
        layer:setMinZoom(14.0)
        layer:setFilter("railway", "*")
        layer:addFill(MINZ, 242, 196, 196, 255)
        layer:addFill(MAXZ, 242, 196, 196, 255)
    
        -- Default, same as building-Residential
        layer = styleAPI:newPolygonLayer("building")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "yes")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Residential.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 227, 98, 98, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 227, 98, 98, 255)
        layer:addFill(MAXZ, 227, 98, 98, 255)
    
        layer = styleAPI:newPolygonLayer("building-Residential")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Residential")
        layer:addFill(MINZ_BUILDINGS, 227, 98, 98, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 227, 98, 98, 255)
        layer:addFill(MAXZ, 227, 98, 98, 255)
    
        layer = styleAPI:newPolygonLayer("building-CommunityServices")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "CommunityServices")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Community.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 227, 98, 98, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 227, 98, 98, 255)
        layer:addFill(MAXZ, 227, 98, 98, 255)
    
        layer = styleAPI:newPolygonLayer("building-Hospitality")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Hospitality")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Hospitality.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 227, 98, 98, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 227, 98, 98, 255)
        layer:addFill(MAXZ, 227, 98, 98, 255)
    
        layer = styleAPI:newPolygonLayer("building-Industrial")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Industrial")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Industrial.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 227, 98, 98, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 227, 98, 98, 255)
        layer:addFill(MAXZ, 227, 98, 98, 255)
    
        layer = styleAPI:newPolygonLayer("building-Medical")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Medical")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Medical.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 227, 98, 98, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 227, 98, 98, 255)
        layer:addFill(MAXZ, 227, 98, 98, 255)
    
        layer = styleAPI:newPolygonLayer("building-RestaurantsAndEntertainment")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "RestaurantsAndEntertainment")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_RestaurantsEntertainment.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 227, 98, 98, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 227, 98, 98, 255)
        layer:addFill(MAXZ, 227, 98, 98, 255)
    
        layer = styleAPI:newPolygonLayer("building-RetailAndCommercial")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "RetailAndCommercial")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_RetailCommercial.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 227, 98, 98, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 227, 98, 98, 255)
        layer:addFill(MAXZ, 227, 98, 98, 255)
    end
    
    
    function MapUtils.initCustomStyleBlue(mapUI)
        local mapAPI = mapUI.javaObject:getAPIv1()
        local styleAPI = mapAPI:getStyleAPI()
    
        local ColorblindPatterns = getCore():getOptionColorblindPatterns()
        mapAPI:setBoolean("ColorblindPatterns", ColorblindPatterns)
    
        local r,g,b = 219/255, 215/255, 192/255
        local cr,cg,cb = 227/255, 227/255, 227/255
        mapAPI:setBackgroundRGBA(cr, cg, cb, 1.0)
        mapAPI:setUnvisitedRGBA(r * 0.915, g * 0.915, b * 0.915, 1.0)
        mapAPI:setUnvisitedGridRGBA(r * 0.777, g * 0.777, b * 0.777, 1.0)
    
        styleAPI:clear()
    
        local layer = styleAPI:newPolygonLayer("forest")
        layer:setMinZoom(13.5)
        layer:setFilter("natural", "forest")
        if true then
            layer:addFill(MINZ, 211, 218, 230, 0)
            layer:addFill(13.5, 211, 218, 230, 0)
            layer:addFill(14, 211, 218, 230, 255)
            layer:addFill(MAXZ, 211, 218, 230, 255)
        else
            layer:addFill(MINZ, 255, 255, 255, 255)
            layer:addFill(MAXZ, 255, 255, 255, 255)
            layer:addTexture(MINZ, "media/textures/worldMap/Grass.png")
            layer:addTexture(MAXZ, "media/textures/worldMap/Grass.png")
            layer:addScale(13.5, 4.0)
            layer:addScale(MAXZ, 4.0)
        end
        
        layer = styleAPI:newPolygonLayer("water")
        layer:setMinZoom(MINZ)
        layer:setFilter("water", "river")
        if not WATER_TEXTURE then
            layer:addFill(MINZ, 137, 159, 199, 255)
            layer:addFill(MAXZ, 137, 159, 199, 255)
        else
            layer:addFill(MINZ, 137, 159, 199, 255)
            layer:addFill(14.5, 137, 159, 199, 255)
            layer:addFill(14.5, 255, 255, 255, 255)
            layer:addTexture(MINZ, nil)
            layer:addTexture(14.5, nil)
            layer:addTexture(14.5, "media/textures/worldMap/Water.png")
            layer:addTexture(MAXZ, "media/textures/worldMap/Water.png")
    --		layer:addScale(MINZ, 4.0)
    --		layer:addScale(MAX, 4.0)
        end
    
        layer = styleAPI:newPolygonLayer("road-trail")
        layer:setMinZoom(12.0)
        layer:setFilter("highway", "trail")
        layer:addFill(12.25,137, 159, 199, 0)
        layer:addFill(13,137, 159, 199, 255)
        layer:addFill(MAXZ,137, 159, 199, 255)
    
        layer = styleAPI:newPolygonLayer("road-tertiary")
        layer:setMinZoom(11.0)
        layer:setFilter("highway", "tertiary")
        layer:addFill(11.5, 175, 193, 227, 0)
        layer:addFill(13, 175, 193, 227, 255)
        layer:addFill(MAXZ, 175, 193, 227, 255)
    
        layer = styleAPI:newPolygonLayer("road-secondary")
        layer:setMinZoom(11.0)
        layer:setFilter("highway", "secondary")
        layer:addFill(MINZ, 159, 182, 227, 255)
        layer:addFill(MAXZ, 159, 182, 227, 255)
    
        layer = styleAPI:newPolygonLayer("road-primary")
        layer:setMinZoom(11.0)
        layer:setFilter("highway", "primary")
        layer:addFill(MINZ, 92, 135, 219, 255)
        layer:addFill(MAXZ, 92, 135, 219, 255)
    
        layer = styleAPI:newPolygonLayer("railway")
        layer:setMinZoom(14.0)
        layer:setFilter("railway", "*")
        layer:addFill(MINZ, 191, 209, 242, 255)
        layer:addFill(MAXZ, 191, 209, 242, 255)
    
        -- Default, same as building-Residential
        layer = styleAPI:newPolygonLayer("building")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "yes")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Residential.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS,92, 135, 219, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5,92, 135, 219, 255)
        layer:addFill(MAXZ,92, 135, 219, 255)
    
        layer = styleAPI:newPolygonLayer("building-Residential")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Residential")
        layer:addFill(MINZ_BUILDINGS,92, 135, 219, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5,92, 135, 219, 255)
        layer:addFill(MAXZ,92, 135, 219, 255)
    
        layer = styleAPI:newPolygonLayer("building-CommunityServices")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "CommunityServices")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Community.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS,92, 135, 219, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5,92, 135, 219, 255)
        layer:addFill(MAXZ,92, 135, 219, 255)
    
        layer = styleAPI:newPolygonLayer("building-Hospitality")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Hospitality")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Hospitality.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS,92, 135, 219, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5,92, 135, 219, 255)
        layer:addFill(MAXZ,92, 135, 219, 255)
    
        layer = styleAPI:newPolygonLayer("building-Industrial")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Industrial")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Industrial.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS,92, 135, 219, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5,92, 135, 219, 255)
        layer:addFill(MAXZ,92, 135, 219, 255)
    
        layer = styleAPI:newPolygonLayer("building-Medical")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Medical")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Medical.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS,92, 135, 219, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5,92, 135, 219, 255)
        layer:addFill(MAXZ,92, 135, 219, 255)
    
        layer = styleAPI:newPolygonLayer("building-RestaurantsAndEntertainment")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "RestaurantsAndEntertainment")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_RestaurantsEntertainment.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS,92, 135, 219, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5,92, 135, 219, 255)
        layer:addFill(MAXZ,92, 135, 219, 255)
    
        layer = styleAPI:newPolygonLayer("building-RetailAndCommercial")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "RetailAndCommercial")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_RetailCommercial.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS,92, 135, 219, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5,92, 135, 219, 255)
        layer:addFill(MAXZ,92, 135, 219, 255)
    end
    
    
    function MapUtils.initCustomStyleGreen(mapUI)
        local mapAPI = mapUI.javaObject:getAPIv1()
        local styleAPI = mapAPI:getStyleAPI()
    
        local ColorblindPatterns = getCore():getOptionColorblindPatterns()
        mapAPI:setBoolean("ColorblindPatterns", ColorblindPatterns)
    
        local r,g,b = 219/255, 215/255, 192/255
        local cr,cg,cb = 227/255, 227/255, 227/255
        mapAPI:setBackgroundRGBA(cr, cg, cb, 1.0)
        mapAPI:setUnvisitedRGBA(r * 0.915, g * 0.915, b * 0.915, 1.0)
        mapAPI:setUnvisitedGridRGBA(r * 0.777, g * 0.777, b * 0.777, 1.0)
    
        styleAPI:clear()
    
        local layer = styleAPI:newPolygonLayer("forest")
        layer:setMinZoom(13.5)
        layer:setFilter("natural", "forest")
        if true then
            layer:addFill(MINZ, 200, 227, 206, 0)
            layer:addFill(13.5, 200, 227, 206, 0)
            layer:addFill(14, 200, 227, 206, 255)
            layer:addFill(MAXZ, 200, 227, 206, 255)
        else
            layer:addFill(MINZ, 255, 255, 255, 255)
            layer:addFill(MAXZ, 255, 255, 255, 255)
            layer:addTexture(MINZ, "media/textures/worldMap/Grass.png")
            layer:addTexture(MAXZ, "media/textures/worldMap/Grass.png")
            layer:addScale(13.5, 4.0)
            layer:addScale(MAXZ, 4.0)
        end
        
        layer = styleAPI:newPolygonLayer("water")
        layer:setMinZoom(MINZ)
        layer:setFilter("water", "river")
        if not WATER_TEXTURE then
            layer:addFill(MINZ, 181, 204, 180, 255)
            layer:addFill(MAXZ, 181, 204, 180, 255)
        else
            layer:addFill(MINZ, 181, 204, 180, 255)
            layer:addFill(14.5, 181, 204, 180, 255)
            layer:addFill(14.5, 255, 255, 255, 255)
            layer:addTexture(MINZ, nil)
            layer:addTexture(14.5, nil)
            layer:addTexture(14.5, "media/textures/worldMap/Water.png")
            layer:addTexture(MAXZ, "media/textures/worldMap/Water.png")
    --		layer:addScale(MINZ, 4.0)
    --		layer:addScale(MAX, 4.0)
        end
    
        layer = styleAPI:newPolygonLayer("road-trail")
        layer:setMinZoom(12.0)
        layer:setFilter("highway", "trail")
        layer:addFill(12.25,198, 214, 197, 0)
        layer:addFill(13,198, 214, 197, 255)
        layer:addFill(MAXZ,198, 214, 197, 255)
    
        layer = styleAPI:newPolygonLayer("road-tertiary")
        layer:setMinZoom(11.0)
        layer:setFilter("highway", "tertiary")
        layer:addFill(11.5, 188, 224, 186, 0)
        layer:addFill(13, 188, 224, 186, 255)
        layer:addFill(MAXZ, 188, 224, 186, 255)
    
        layer = styleAPI:newPolygonLayer("road-secondary")
        layer:setMinZoom(11.0)
        layer:setFilter("highway", "secondary")
        layer:addFill(MINZ, 147, 212, 142, 255)
        layer:addFill(MAXZ, 147, 212, 142, 255)
    
        layer = styleAPI:newPolygonLayer("road-primary")
        layer:setMinZoom(11.0)
        layer:setFilter("highway", "primary")
        layer:addFill(MINZ, 100, 191, 94, 255)
        layer:addFill(MAXZ, 100, 191, 94, 255)
    
        layer = styleAPI:newPolygonLayer("railway")
        layer:setMinZoom(14.0)
        layer:setFilter("railway", "*")
        layer:addFill(MINZ, 190, 209, 188, 255)
        layer:addFill(MAXZ, 190, 209, 188, 255)
    
        -- Default, same as building-Residential
        layer = styleAPI:newPolygonLayer("building")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "yes")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Residential.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 100, 191, 94, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 100, 191, 94, 255)
        layer:addFill(MAXZ, 100, 191, 94, 255)
    
        layer = styleAPI:newPolygonLayer("building-Residential")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Residential")
        layer:addFill(MINZ_BUILDINGS, 100, 191, 94, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 100, 191, 94, 255)
        layer:addFill(MAXZ, 100, 191, 94, 255)
    
        layer = styleAPI:newPolygonLayer("building-CommunityServices")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "CommunityServices")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Community.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 100, 191, 94, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 100, 191, 94, 255)
        layer:addFill(MAXZ, 100, 191, 94, 255)
    
        layer = styleAPI:newPolygonLayer("building-Hospitality")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Hospitality")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Hospitality.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 100, 191, 94, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 100, 191, 94, 255)
        layer:addFill(MAXZ, 100, 191, 94, 255)
    
        layer = styleAPI:newPolygonLayer("building-Industrial")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Industrial")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Industrial.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 100, 191, 94, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 100, 191, 94, 255)
        layer:addFill(MAXZ, 100, 191, 94, 255)
    
        layer = styleAPI:newPolygonLayer("building-Medical")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "Medical")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_Medical.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 100, 191, 94, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 100, 191, 94, 255)
        layer:addFill(MAXZ, 100, 191, 94, 255)
    
        layer = styleAPI:newPolygonLayer("building-RestaurantsAndEntertainment")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "RestaurantsAndEntertainment")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_RestaurantsEntertainment.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 100, 191, 94, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 100, 191, 94, 255)
        layer:addFill(MAXZ, 100, 191, 94, 255)
    
        layer = styleAPI:newPolygonLayer("building-RetailAndCommercial")
        layer:setMinZoom(MINZ_BUILDINGS)
        layer:setFilter("building", "RetailAndCommercial")
        if ColorblindPatterns then
            layer:addTexture(MINZ, "media/textures/worldMap/Colorblind Patterns/Pattern_RetailCommercial.png", "ScreenPixel")
            layer:addScale(MINZ, 4)
        end
        layer:addFill(MINZ_BUILDINGS, 100, 191, 94, 0)
        layer:addFill(MINZ_BUILDINGS + 0.5, 100, 191, 94, 255)
        layer:addFill(MAXZ, 100, 191, 94, 255)
    end


    -- custom map data for sketches
    LootMaps.Init.CustomMap = function(mapUI)
        local player = getPlayer()
        local item = mapUI.mapItem or mapUI.mapObj
    
        local modData = item:getModData()
        local playerCell = player:getCell()
        local mapAPI = mapUI.javaObject:getAPIv1()
        
        local minX = nil
        local minY = nil
        local maxX = nil
        local maxY = nil
    
        MapUtils.initDirectoryMapData(mapUI, LootMaps.DEFAULT_MAP_DIRECTORY)
        
        local mapColor = modData.mapColor
        
        if mapColor == "black" then
            MapUtils.initCustomStyleBlack(mapUI)
        elseif mapColor == "red" then
            MapUtils.initCustomStyleRed(mapUI)
        elseif mapColor == "blue" then
            MapUtils.initCustomStyleBlue(mapUI)
        elseif mapColor == "green" then
            MapUtils.initCustomStyleGreen(mapUI)
        else
            MapUtils.initDefaultStyleV1(mapUI)
        end
    
        replaceWaterStyle(mapUI)
    
        local boxTable = modData.custoMapData
    
        if boxTable == nil then
            -- generates an empty map
            minX = 0
            minY = 0
            maxX = 0
            maxY = 0
    
            boxTable = {
                _minX = minX,
                _minY = minY,
                _maxX = maxX,
                _maxY = maxY
            }
    
            modData.custoMapData = boxTable
        else
            minX = boxTable._minX
            minY = boxTable._minY
            maxX = boxTable._maxX
            maxY = boxTable._maxY
        end
    
        mapAPI:setBoundsInSquares(minX, minY, maxX, maxY)
    end

    MapUtils.revealKnownArea = function(mapUI) end
end

Events.OnGameStart.Add(NIM_overrideWorldMapBackground)
Events.OnGameStart.Add(NIM_InitCustomMap)