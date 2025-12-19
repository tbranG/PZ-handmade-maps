NIM_TransferRegionWindow = ISPanel:derive("NIM_TransferRegionWindow");

local WINDOW_WIDTH = 860
local WINDOW_HEIGHT = 460

local MOVING_UP = 0
local MOVING_RIGHT = 1
local MOVING_DOWN = 2
local MOVING_LEFT = 3

local paperTextureWidth = 400
local paperTextureHeight = 350

local paperTextureX = 450
local paperTextureY = 40

local TILE_SIZE = 50

-- Method responsible for adding visited regions to the world map
 local function NIM_TransferRegions(item)
    local mapModData = item:getModData()
    local playerModData = getPlayer():getModData()

    for _, v in pairs(playerModData.visitedRegions) do
        if mapModData.mapRegions == nil then
            mapModData.mapRegions = {}
        end

        local isRegionAlreadyOnMap = false
        local offset = 32

        for _, k in pairs(mapModData.mapRegions) do
            if v.minX >= k.minX - offset then
                if v.maxX <= k.maxX + offset then
                    if v.minY >= k.minY - offset then
                        if v.maxY <= k.maxY + offset then
                            isRegionAlreadyOnMap = true
                        end
                    end
                end
            end
        end
        
        if not isRegionAlreadyOnMap then
            table.insert(mapModData.mapRegions, v)
            mapModData.haveNewRegions = true
        end
    end

    local playerObj = getPlayer()
    playerModData.visitedRegions = {}

    ISTimedActionQueue.clear(playerObj)
    ISTimedActionQueue.add(ISReadWorldMap:new(playerObj))
end

-- #######################

function NIM_TransferRegionWindow:prerender()
    ISPanel.prerender(self)

    local titleText = getText("UI_TransferRegionTitle")
    self:drawText(titleText, self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, titleText) / 2), 10, 1,1,1,1, UIFont.Small)
    self:drawRectBorder(0, 30, self.width, WINDOW_HEIGHT-30, 1, 0.4, 0.4, 0.4)

    self.itemsPanel:drawText(getText("UI_TransferRegionPencilsTooltip"), 20, 40, 1,1,1,1, UIFont.Medium)
    self.itemsPanel:drawRectBorder(0, 0, self.itemsPanel:getWidth() / 4.6, self.itemsPanel:getHeight(), 0.3, 1, 1, 1)
    self:drawRectBorder(195, 53, 1, 70, 0.3, 1, 1, 1)

    -- ======================= displaying pencil icons =======================
    if self.multicolorItemRef ~= nil then
        local textWidth = getTextManager():MeasureStringX(UIFont.Small, getText("UI_TransferRegionPencilMulti"))
        self.multiColorItem:drawItemIcon(self.multicolorItemRef, 7, 7, 1, 30, 30)
        self.multiColorItem:drawText(getText("UI_TransferRegionPencilMulti"), 22 - (textWidth/2), 50, 1, 1, 1, 1, UIFont.Small)
        self.multiColorItem:drawRectBorder(1, 1, self.multiColorItem:getWidth() - 2, self.multiColorItem:getHeight() - 2, 0.7, 1, 1, 1)
    else
        self.multiColorItem.borderColor = {r=1, g=75/255, b=75/255, a=0.7}
        self.multiColorItem:drawText(getText("UI_TransferRegionPencilMulti"), -3, 50, 1, 1, 1, 0.6, UIFont.Small)
    end


    if self.blackItemRef ~= nil then
        self.blackItem:drawItemIcon(self.blackItemRef, 7, 7, 1, 30, 30)
        self.blackItem:drawText(getText("UI_TransferRegionPencilBlack"), 8, 50, 1, 1, 1, 1, UIFont.Small)
        self.blackItem:drawRectBorder(1, 1, self.blackItem:getWidth() - 2, self.blackItem:getHeight() - 2, 0.7, 1, 1, 1)
    else
        self.blackItem.borderColor = {r=1, g=75/255, b=75/255, a=0.7}
        self.blackItem:drawText(getText("UI_TransferRegionPencilBlack"), 8, 50, 1, 1, 1, 0.6, UIFont.Small)
    end

    if self.redItemRef ~= nil then
        local textWidth = getTextManager():MeasureStringX(UIFont.Small, getText("UI_TransferRegionPencilRed"))
        self.redItem:drawItemIcon(self.redItemRef, 7, 7, 1, 30, 30)
        self.redItem:drawText(getText("UI_TransferRegionPencilRed"), 7 - textWidth, 50, 1, 1, 1, 1, UIFont.Small)
        self.redItem:drawRectBorder(1, 1, self.redItem:getWidth() - 2, self.redItem:getHeight() - 2, 0.7, 1, 1, 1)
    else
        self.redItem.borderColor = {r=1, g=75/255, b=75/255, a=0.7}
        self.redItem:drawText(getText("UI_TransferRegionPencilRed"), 10, 50, 1, 1, 1, 0.6, UIFont.Small)
    end

    if self.blueItemRef ~= nil then
        self.blueItem:drawItemIcon(self.blueItemRef, 7, 7, 1, 30, 30)
        self.blueItem:drawText(getText("UI_TransferRegionPencilBlue"), 10, 50, 1, 1, 1, 1, UIFont.Small)
        self.blueItem:drawRectBorder(1, 1, self.blueItem:getWidth() - 2, self.blueItem:getHeight() - 2, 0.7, 1, 1, 1)
    else
        self.blueItem.borderColor = {r=1, g=75/255, b=75/255, a=0.7}
        self.blueItem:drawText(getText("UI_TransferRegionPencilBlue"), 10, 50, 1, 1, 1, 0.6, UIFont.Small)
    end

    if self.greenItemRef ~= nil then
        self.greenItem:drawItemIcon(self.greenItemRef, 7, 7, 1, 30, 30)
        self.greenItem:drawText(getText("UI_TransferRegionPencilGreen"), 8, 50, 1, 1, 1, 1, UIFont.Small)
        self.greenItem:drawRectBorder(1, 1, self.greenItem:getWidth() - 2, self.greenItem:getHeight() - 2, 0.7, 1, 1, 1)
    else
        self.greenItem.borderColor = {r=1, g=75/255, b=75/255, a=0.7}
        self.greenItem:drawText(getText("UI_TransferRegionPencilGreen"), 8, 50, 1, 1, 1, 0.6, UIFont.Small)
    end

    -- ================ displaying map inputs =================
    self.inputPanel:drawRectBorder(0, 0, self.inputPanel:getWidth(), self.inputPanel:getHeight() / 6.5, 0.4, 1, 1, 1)
    self.inputPanel:drawText(getText("UI_TransferRegionSelectMapTooltip"), (self.inputPanel:getWidth() / 2) - 20, 10, 1,1,1,1, UIFont.Medium)

    for i = 1, #self.mapInputs do
        local item = self.playerMapItems:get(i-1)
        if item ~= nil then
            self.mapInputs[i]:drawItemIcon(item, 7, 9, 1, 30, 30)
            self.mapInputs[i]:drawText(
                item:getName(),
                50, 
                17, 
                1, 1, 1, 1, 
                UIFont.Small
            )
        end
    end

    if not self.drawMode and not self.missingPencils then
        if self.selectedMapTexture == 0 then    
            -- drawing map texture
            self.selectedMapTexture = ZombRand(5) + 1
        end
        
        self:drawTextureScaled(self.mapsTexture[self.selectedMapTexture].tex, paperTextureX, paperTextureY, paperTextureWidth, paperTextureHeight, 1, 1, 1, 1)    
    end
    
    self:drawTextureScaled(self.paperTexture, paperTextureX, paperTextureY, paperTextureWidth, paperTextureHeight, 0.5, 1, 1, 1)

     -- ================ drawing grid rect =================
    self:drawRectBorder(
        self.pixelMatrix[1].x, 
        self.pixelMatrix[1].y, 
        (self.pixelMatrix[#self.pixelMatrix].x + TILE_SIZE) - self.pixelMatrix[1].x, 
        (self.pixelMatrix[#self.pixelMatrix].y + TILE_SIZE) - self.pixelMatrix[1].y, 
        0.4, 1, 1, 1
    )

    self:drawRectBorder(
        self.pixelMatrix[1].x + 1, 
        self.pixelMatrix[1].y + 1, 
        ((self.pixelMatrix[#self.pixelMatrix].x + TILE_SIZE) - self.pixelMatrix[1].x) - 2, 
        ((self.pixelMatrix[#self.pixelMatrix].y + TILE_SIZE) - self.pixelMatrix[1].y) - 2, 
        1, 1, 1, 1
    )
end


function NIM_TransferRegionWindow:render()
    local tooDark = self.character:tooDarkToRead()

    -- Blocking conditions =======================================
    if tooDark then
        self:drawRect(
            paperTextureX, 
            paperTextureY, 
            paperTextureWidth, 
            paperTextureHeight,
            0.3,
            1,
            0,
            0
        )

        self:drawText(
            getText("UI_TransferRegionTooDark"),
            (paperTextureX - 100) + (paperTextureWidth / 2), 
            (paperTextureY - 10) + (paperTextureHeight / 2), 
            1, 1, 1, 1, 
            UIFont.Medium
        )
        return
    end

    if self.multicolorItemRef == nil and (
        self.redItemRef == nil or
        self.blackItemRef == nil or
        self.greenItemRef == nil or
        self.blueItemRef == nil
    ) then
        self:drawRect(
            paperTextureX, 
            paperTextureY, 
            paperTextureWidth, 
            paperTextureHeight,
            0.3,
            1,
            0,
            0
        )

        self:drawText(
            getText("UI_TransferRegionMissingPencils"),
            (paperTextureX - 100) + (paperTextureWidth / 2) - 25, 
            (paperTextureY - 10) + (paperTextureHeight / 2), 
            1, 1, 1, 1, 
            UIFont.Medium
        )
        return
    end
    -- ===========================================================

    -- DRAW MODE =================================================
    if self.drawMode then
        for i = 1, #self.pixelMatrix do
            if self.pixelMatrix[i].toColor then
                self:drawRect(
                    self.pixelMatrix[i].x, 
                    self.pixelMatrix[i].y, 
                    TILE_SIZE, 
                    TILE_SIZE,
                    0.3,
                    self.pixelMatrix[i].r,
                    self.pixelMatrix[i].g,
                    self.pixelMatrix[i].b
                )
            end
        end

        -- Pencil aim
        local aimWidth, aimHeight = 50, 50
        self:drawRectBorder(self:getMouseX() - (aimWidth / 2), self:getMouseY() - (aimHeight / 2), aimWidth, aimHeight, 1, 0.3, 0.3, 0.3)
        self:drawRectBorder(self:getMouseX() - (aimWidth / 2) - 1, self:getMouseY() - (aimHeight / 2) - 1, aimWidth, aimHeight, 1, 0.9, 0.9, 0.9)
        
        return
    end
    -- ===========================================================

    -- drawing pixel matrix
    local unclearAlpha = 0.85
    local clearAlpha = 0.4

    for i = 1, #self.pixelMatrix do
        local alpha = 0

        if self.pixelMatrix[i].filled then
            alpha = clearAlpha
        else
            alpha = unclearAlpha
        end

        self:drawRect(
            self.pixelMatrix[i].x, 
            self.pixelMatrix[i].y, 
            TILE_SIZE, 
            TILE_SIZE,
            alpha, 
            0, 0, 0
        )

        --border
        self:drawRectBorder(
            self.pixelMatrix[i].x, 
            self.pixelMatrix[i].y, 
            TILE_SIZE, 
            TILE_SIZE,
            0.05, 
            1, 
            1, 
            1
        )
    end

    -- when map is selected  
    if self.mapInputSelected then
        for i = 1, #self.mapInputs do
            if i == self.selectedInput then
                self.mapInputs[i].backgroundColor = {r=0, g=1, b=0, a=0.3}
            else
                self.mapInputs[i].backgroundColor = {r=0, g=0, b=0, a=0}
            end
        end

        if self.selectedPixelOverlay ~= 0 then
            for i = 1, #self.pixelMatrix do
                if i == self.selectedPixelOverlay then
                    self:drawRect(
                        self.pixelMatrix[i].x, 
                        self.pixelMatrix[i].y, 
                        TILE_SIZE, 
                        TILE_SIZE,
                        0.3, 
                        0, 1, 0
                    )
    
                    self:drawRectBorder(
                        self.pixelMatrix[i].x, 
                        self.pixelMatrix[i].y, 
                        TILE_SIZE, 
                        TILE_SIZE,
                        1, 
                        0, 1, 0
                    )
                    self:drawRectBorder(
                        self.pixelMatrix[i].x - 1, 
                        self.pixelMatrix[i].y - 1, 
                        TILE_SIZE + 2, 
                        TILE_SIZE + 2,
                        1, 
                        0, 1, 0
                    )
                end
            end
        end
    end
end


function NIM_TransferRegionWindow:new(x, y, width, height)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    return o;
end


function NIM_TransferRegionWindow:initialise()
    ISPanel.initialise(self)
    self:create()
    NIM_TransferRegionWindow.instance = self

    self.character = getPlayer()
    local playerInv = self.character:getInventory()

    local getMulticolorItem = function()
        local crayon = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.Crayons" end) 
        if crayon ~= nil then return crayon end
        
        local multicolorPen = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.PenMultiColor" end)
        if multicolorPen ~= nil then return multicolorPen end
    end
    local getBlackItem = function()
        local pen = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.Pen" end)
        if pen ~= nil then return pen end

        local pencil = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.Pencil" end)
        if pencil ~= nil then return pencil end
        
        local penFancy = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.PenFancy" end)
        if penFancy ~= nil then return penFancy end

        local penSpiffo = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.PenSpiffo" end)
        if penSpiffo ~= nil then return penSpiffo end

        local markerBlack = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.MarkerBlack" end)
        if markerBlack ~= nil then return markerBlack end
    end
    local getRedItem = function()
        local redPen = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.RedPen" end)
        if redPen ~= nil then return redPen end

        local markerRed = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.MarkerRed" end)
        if markerRed ~= nil then return markerRed end
    end
    local getBlueItem = function()
        local bluePen = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.BluePen" end)
        if bluePen ~= nil then return bluePen end

        local markerBlue = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.MarkerBlue" end)
        if markerBlue ~= nil then return markerBlue end
    end
    local getGreenItem = function()
        local greenPen = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.GreenPen" end)
        if greenPen ~= nil then return greenPen end

        local markerGreen = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.MarkerGreen" end)
        if markerGreen ~= nil then return markerGreen end
    end

    self.multicolorItemRef = getMulticolorItem()
    self.blackItemRef = getBlackItem()
    self.redItemRef = getRedItem()
    self.blueItemRef = getBlueItem()
    self.greenItemRef = getGreenItem()

    self.missingPencils = false

    if self.multicolorItemRef == nil and (
        self.redItemRef == nil or
        self.blackItemRef == nil or
        self.greenItemRef == nil or
        self.blueItemRef == nil
    ) then
        self.missingPencils = true
        self.draw.enable = false
    end

    self.mapInputSelected = false
    self.selectedPixelOverlay = 0

    self.paperTexture = getTexture("media/textures/worldMap/Paper.png")
    self.mapsTexture = {}

    table.insert(self.mapsTexture, { tex = getTexture("media/textures/hm_map1.png") })
    table.insert(self.mapsTexture, { tex = getTexture("media/textures/hm_map2.png") })
    table.insert(self.mapsTexture, { tex = getTexture("media/textures/hm_map3.png") })
    table.insert(self.mapsTexture, { tex = getTexture("media/textures/hm_map4.png") })
    table.insert(self.mapsTexture, { tex = getTexture("media/textures/hm_map5.png") })

    self.selectedMapTexture = 0
    self.drawMode = false
    self.finalizedDrawing = false

    for i = 1, #self.pixelMatrix do
        if self.pixelMatrix[i].filled == true then
            self.filledPixels = self.filledPixels + 1
        end
    end
    
    -- (DRAW MODE) -> Counting how many pixels we have to color
    for i = 1, #self.pixelMatrix do
        if self.pixelMatrix[i].toColor == true then
            self.pixelsToColor = self.pixelsToColor + 1
        end
    end

    self.coloredPixels = 0
end


function NIM_TransferRegionWindow:create()
    self.exit = ISButton:new(WINDOW_WIDTH - 25, 5, 20, 20, "X", self, NIM_TransferRegionWindow.onOptionMouseDown);
    self.exit.internal = "EXIT";
    self.exit:initialise();
    self.exit:instantiate();
    self.exit.borderColor = {r=1, g=1, b=1, a=0.3};
    self:addChild(self.exit);

    --Pencils panel
    self.itemsPanel = ISPanel:new(10, 40, WINDOW_WIDTH / 2, WINDOW_HEIGHT / 4.5)
    self.itemsPanel:initialise();
    self.itemsPanel:instantiate();
    self.itemsPanel.backgroundColor = {r=0, b=0, g=0, a=0};
    self:addChild(self.itemsPanel);

    local padd = 45

    self.multiColorItem = ISPanel:new(75 + padd, 25, 45, 45)
    self.multiColorItem:initialise();
    self.multiColorItem:instantiate();
    self.multiColorItem.backgroundColor = {r=0, b=0, g=0, a=0};
    self.itemsPanel:addChild(self.multiColorItem);

    self.redItem = ISPanel:new(165 + padd, 25, 45, 45)
    self.redItem:initialise();
    self.redItem:instantiate();
    self.redItem.backgroundColor = {r=0, b=0, g=0, a=0};
    self.itemsPanel:addChild(self.redItem);

    self.blueItem = ISPanel:new(215 + padd, 25, 45, 45)
    self.blueItem:initialise();
    self.blueItem:instantiate();
    self.blueItem.backgroundColor = {r=0, b=0, g=0, a=0};
    self.itemsPanel:addChild(self.blueItem);

    self.greenItem = ISPanel:new(265 + padd, 25, 45, 45)
    self.greenItem:initialise();
    self.greenItem:instantiate();
    self.greenItem.backgroundColor = {r=0, b=0, g=0, a=0};
    self.itemsPanel:addChild(self.greenItem);

    self.blackItem = ISPanel:new(315 + padd, 25, 45, 45)
    self.blackItem:initialise();
    self.blackItem:instantiate();
    self.blackItem.backgroundColor = {r=0, b=0, g=0, a=0};
    self.itemsPanel:addChild(self.blackItem);


    --Map input panel
    self.inputPanel = ISPanel:new(10, 150, WINDOW_WIDTH / 2, WINDOW_HEIGHT / 1.55)
    self.inputPanel:initialise();
    self.inputPanel:instantiate();
    self.inputPanel.backgroundColor = {r=0, b=0, g=0, a=0};
    self:addChild(self.inputPanel);

    self.playerMapItems = getPlayer():getInventory():getAllEvalRecurse(function(item) return item:getDisplayCategory() == "Cartography" and item:getFullType() ~= "Base.HandmadeMap" end)
    self.mapInputs = {}

    --buttons
    self.draw = ISButton:new(self:getWidth() - 275, self:getHeight() - 55, 150, 45, getText("UI_TransferRegionVisited"), self, NIM_TransferRegionWindow.onOptionMouseDown)
    self.draw.internal = "DRAW";
    self.draw:initialise();
    self.draw:instantiate();
    self.draw.borderColor = {r=1, g=1, b=1, a=0.3};
    self.draw.enable = true;
    self:addChild(self.draw);

    self.finish = ISButton:new(self:getWidth() - 110, self:getHeight() - 55, 100, 45, getText("UI_TransferRegionFinish"), self, NIM_TransferRegionWindow.onOptionMouseDown)
    self.finish.internal = "FINISH";
    self.finish:initialise();
    self.finish:instantiate();
    self.finish.borderColor = {r=1, g=1, b=1, a=0.3};
    self.finish.enable = false;
    self:addChild(self.finish);

    self.pixelMatrix = {}
    self.filledPixels = 0
    self.pixelsToColor = 0

    -- matrix init here
    local startingX = 450

    local row = 40
    local column = startingX

    local toColor = true

    for i = 1, 7 do
        column = startingX
        for j = 1, 8 do
            local isFilled = false
            local randColorOffset = 0.0
            local randomFactor = ZombRand(3) == 0

            toColor = not toColor and randomFactor

            if self.sourceItem:getModData().mapRegions ~= nil and #self.sourceItem:getModData().mapRegions > 0 then
                local minValue = math.min(#self.sourceItem:getModData().mapRegions, 10)

                if ZombRand(minValue, 12) == minValue then
                    isFilled = true
                end
            end

            table.insert(self.pixelMatrix, {
                x = column,
                y = row,
                filled = isFilled,
                toColor = toColor, --used on draw mode to check if this pixel need to be colored
                colored = false, --used on draw mode to check if this pixel is already colored
                r = 0,
                g = 0,
                b = 0,
                a = 0
            });
            column = column + TILE_SIZE;
        end
        row = row + TILE_SIZE
    end

    -- buttons init here    
    local startingY = 55
    local startingX = 5

    local xOffset = startingX
    for i = 1, self.playerMapItems:size() do
        if i == 5 then
            xOffset = xOffset + 212
        end

        -- panel limit to 7 items
        if i > 8 then
            break
        end

        local pane = ISPanel:new(xOffset, startingY + (((i-1) % 4) * 55), 205, 50)
        pane:initialise();
        pane:instantiate();
        pane.backgroundColor = {r=0, b=0, g=0, a=0};
        self.inputPanel:addChild(pane);

        local cellRef = 0
        repeat
            for j = 1, #self.pixelMatrix do
                if ZombRand(8) == 0 and not self.pixelMatrix[j].filled then
                    cellRef = j
                    break
                end
            end
        until cellRef ~= 0

        local button = ISButton:new(0, 0, 205, 50, "", self, function()
            self.mapInputSelected = true;
            self.selectedInput = i;
            self.targetMapItem = self.playerMapItems:get(i-1);
            self.selectedPixelOverlay = cellRef;
        end);
        button.internal = "MAP_INPUT_" .. i;
        button:initialise();
        button:instantiate();
        button.backgroundColor = {r=0, g=0, b=0, a=0};
        pane:addChild(button);

        table.insert(self.mapInputs, pane);
    end
end


function NIM_TransferRegionWindow:close()
    NIM_TransferRegionWindow.instance = nil
    ISPanel.close(self)
end


function NIM_TransferRegionWindow:open(source)
    local modal = NIM_TransferRegionWindow:new(
        Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTH/2, 
        Core:getInstance():getScreenHeight()/2 - 500/2,
        WINDOW_WIDTH, 
        WINDOW_HEIGHT
    )
    modal.sourceItem = source

    modal:initialise()
    modal:addToUIManager()
end


function NIM_TransferRegionWindow:setVisible(visible)
    self.javaObject:setVisible(visible);
end


function NIM_TransferRegionWindow:onOptionMouseDown(button, x, y)
    if button.internal == "EXIT" then
        self:setVisible(false);
        self:removeFromUIManager();
        self:close()
    end
    if button.internal == "DRAW" then
        for i = 1, #self.mapInputs do
            self.mapInputs[i].backgroundColor = {r=0, g=0, b=0, a=0}
        end

        self.mapInputSelected = false;
        self.selectedInput = 0;

        self.drawMode = true;
    end
    if button.internal == "FINISH" then
        if self.drawMode then
            NIM_TransferRegions(self.sourceItem)
        elseif self.targetMapItem ~= nil then
            NIM_AddRegion(self.sourceItem, self.targetMapItem)
        end
        
        self:setVisible(false);
        self:removeFromUIManager();
        self:close()
    end
end


function NIM_TransferRegionWindow:onTick()
    local window = NIM_TransferRegionWindow.instance

    if window == nil then
        return
    end

    local tooDark = window.character:tooDarkToRead()

    if tooDark or window.missingPencils then
        return
    end

    if (window.mapInputSelected and not window.drawMode) or (window.drawMode and window.finalizedDrawing) then
        window.finish.enable = true
        return
    else
        window.finish.enable = false
    end

    if window.drawMode then    
        local mouseX = window:getMouseX()
        local mouseY = window:getMouseY()
    
        local r, g, b
    
        local pencil = ZombRand(4)
        if pencil == 0 then
            r = 0.2;
            g = 0.2;
            b = 0.2;
        elseif pencil == 1 then
            r = 1;
            g = 77/255;
            b = 77/255;
        elseif pencil == 2 then
            r = 51/255;
            g = 153/255;
            b = 1;
        else
            r = 102/255;
            g = 1;
            b = 102/255;
        end
    
        local leftCollisionOffset = -5
        local rightCollisionOffset = 75
        local topCollisionOffset = 5
        local bottomCollisionOffset = 90
    
        if window.pixelMatrix ~= nil then
            for i = 1, #window.pixelMatrix do
                if (mouseX > window.pixelMatrix[i].x + leftCollisionOffset and mouseX < window.pixelMatrix[i].x + rightCollisionOffset) and 
                (mouseY > window.pixelMatrix[i].y + topCollisionOffset and mouseY < window.pixelMatrix[i].y + bottomCollisionOffset) then
                    if window.pixelMatrix[i].toColor and not window.pixelMatrix[i].colored then
                        window.pixelMatrix[i].r = r
                        window.pixelMatrix[i].g = g
                        window.pixelMatrix[i].b = b
                        window.pixelMatrix[i].colored = true
    
                        window.coloredPixels = window.coloredPixels + 1
                        window.character:playSound("Painting")
                    end
                end
            end
        end
    
        if window.coloredPixels == window.pixelsToColor then
            window.finalizedDrawing = true
        end
    end
end

Events.OnTick.Add(NIM_TransferRegionWindow.onTick)