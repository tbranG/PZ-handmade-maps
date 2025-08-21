NIM_TransferRegionWindow = ISPanel:derive("NIM_TransferRegionWindow");

local WINDOW_WIDTH = 860
local WINDOW_HEIGHT = 460

local MOVING_UP = 0
local MOVING_RIGHT = 1
local MOVING_DOWN = 2
local MOVING_LEFT = 3

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

    local playerInv = getPlayer():getInventory()

    self.itemsPanel:drawText(getText("UI_TransferRegionPencilsTooltip"), 15, 40, 1,1,1,1, UIFont.Medium)
    self:drawRectBorder(195, 53, 1, 70, 0.3, 1, 1, 1)

    -- ======================= displaying pencil icons =======================
    local getMulticolorItem = function()
        local crayon = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.Crayons" end) 
        if crayon ~= nil then return crayon end
        
        local multicolorPen = playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.PenMultiColor" end) ~= nil
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


    local multicolorItem = getMulticolorItem()
    local blackItem = getBlackItem()
    local redItem = getRedItem()
    local blueItem = getBlueItem()
    local greenItem = getGreenItem()

    if multicolorItem ~= nil then
        self.multiColorItem:drawItemIcon(multicolorItem, 7, 7, 1, 30, 30)
    else
        self.multiColorItem.borderColor = {r=1, g=0, b=0, a=0.3}
    end

    if blackItem ~= nil then
        self.blackItem:drawItemIcon(blackItem, 7, 7, 1, 30, 30)
    else
        self.blackItem.borderColor = {r=1, g=0, b=0, a=0.3}
    end

    if redItem ~= nil then
        self.redItem:drawItemIcon(redItem, 7, 7, 1, 30, 30)
    else
        self.redItem.borderColor = {r=1, g=0, b=0, a=0.3}
    end

    if blueItem ~= nil then
        self.blueItem:drawItemIcon(blueItem, 7, 7, 1, 30, 30)
    else
        self.blueItem.borderColor = {r=1, g=0, b=0, a=0.3}
    end

    if greenItem ~= nil then
        self.greenItem:drawItemIcon(greenItem, 7, 7, 1, 30, 30)
    else
        self.greenItem.borderColor = {r=1, g=0, b=0, a=0.3}
    end

    -- ================ drawing grid =================
    for i = 1, #self.pixelMatrix do
        self:drawRectBorder(
            self.pixelMatrix[i].x, 
            self.pixelMatrix[i].y, 
            50, 
            50,
            0.7, 
            0.4, 
            0.4, 
            0.4
        )
    end

end


function NIM_TransferRegionWindow:render()
    local paperTextureWidth = 400
    local paperTextureHeight = 350

    local paperTextureX = 450
    local paperTextureY = 40

    local tooDark = self.character:tooDarkToRead()

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

    if not self.mapInputSelected then return end

    for i = 1, #self.pixelMatrix do
        if self.pixelMatrix[i].filled then
            self:drawRect(
                self.pixelMatrix[i].x, 
                self.pixelMatrix[i].y, 
                50, 
                50,
                1,
                246/255,
                217/255,
                159/255
            )
        else
            self:drawRect(
                self.pixelMatrix[i].x, 
                self.pixelMatrix[i].y, 
                50, 
                50,
                0.1, 
                204/255, 
                178/255, 
                123/255
            )
        end

        if self.pixelMatrix[i].toFill then
            self:drawRectBorder(
                self.pixelMatrix[i].x + 12.5, 
                self.pixelMatrix[i].y + 12.5, 
                25, 
                25,
                1, 
                1, 
                0, 
                0
            )
        end
    end

    -- Paper texture
    self:drawTextureScaled(self.paperTexture, paperTextureX, paperTextureY, paperTextureWidth, paperTextureHeight, 0.25, 246/255, 217/255, 159/255)

    if self.selectedPixel ~= -1 then
        self:drawRectBorder(
            self.pixelMatrix[self.selectedPixel].x, 
            self.pixelMatrix[self.selectedPixel].y, 
            51, 
            51,
            1, 
            0, 
            1, 
            0
        )
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

    for i = 1, 3 do
        local validSelection = false
        repeat
            local selectedPixel = ZombRand(1, #self.pixelMatrix)

            if not self.pixelMatrix[selectedPixel].filled then
                self.pixelMatrix[selectedPixel].toFill = true
                validSelection = true
            end
        until (validSelection)
    end

    self.mapInputSelected = true
    self.selectedPixel = -1

    self.movingPixel = false
    self.movingDir = -1

    self.tickSize = 10000
    self.tickCounter = 0

    self.character = getPlayer()
    self.paperTexture = getTexture("media/textures/worldMap/Paper.png")
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
    self.inputPanel = ISPanel:new(10, 150, WINDOW_WIDTH / 2, WINDOW_HEIGHT / 1.6)
    self.inputPanel:initialise();
    self.inputPanel:instantiate();
    self:addChild(self.inputPanel);

    self.pixelMatrix = {}
    self.filledPixels = 0

    local startingX = 450

    local row = 40
    local column = startingX

    for i = 1, 7 do
        column = startingX
        for j = 1, 8 do
            local isFilled = ZombRand(4) == 0

            table.insert(self.pixelMatrix, {
                x = column,
                y = row,
                r = 1,
                g = 1,
                b = 1,
                filled = isFilled,
                toFill = false
            });
            column = column + 50;

            if isFilled then
                self.filledPixels = self.filledPixels + 1
            end
        end
        row = row + 50
    end
end


function NIM_TransferRegionWindow:close()
    NIM_TransferRegionWindow.instance = nil
    ISPanel.close(self)
end


function NIM_TransferRegionWindow:open()
    local modal = NIM_TransferRegionWindow:new(
        Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTH/2, 
        Core:getInstance():getScreenHeight()/2 - 500/2,
        WINDOW_WIDTH, 
        WINDOW_HEIGHT
    )
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
end


function NIM_TransferRegionWindow:onTick()
    local window = NIM_TransferRegionWindow.instance

    if window == nil then
        return
    end

    local tooDark = window.character:tooDarkToRead()

    if tooDark then
        return
    end

    if window.movingPixel then
        if tickCounter == tickSize then
            if window.movingDir == MOVING_UP then
                local newPixel = window.selectedPixel - 8

                if newPixel < 0 or window.pixelMatrix[newPixel].filled then 
                    window.movingPixel = false
                    window.tickCounter = 0
                    return
                end

                window.pixelMatrix[window.selectedPixel].filled = false
                window.pixelMatrix[newPixel].filled = true

                window.selectedPixel = newPixel

                window.tickCounter = 0
            end
        else
            tickCounter = tickCounter + 1
        end

        return
    end

    local mouseX = window:getMouseX()
    local mouseY = window:getMouseY()

    if window.pixelMatrix ~= nil then
        for i = 1, #window.pixelMatrix do
            if (mouseX > window.pixelMatrix[i].x and mouseX < window.pixelMatrix[i].x + 45) and 
            (mouseY > window.pixelMatrix[i].y and mouseY < window.pixelMatrix[i].y + 45) then
                if window.pixelMatrix[i].filled then
                    window.selectedPixel = i
                end
            end
        end
    end
end

function NIM_TransferRegionWindow:onKeyPress(key)
    local window = NIM_TransferRegionWindow.instance

    if window == nil or window.selectedPixel == -1 then
        return
    end

    if key == Keyboard.KEY_W then
        window.movingPixel = true
        window.movingDir = MOVING_UP
    elseif key == Keyboard.KEY_DOWN then
        window.movingPixel = true
        window.movingDir = MOVING_DOWN
    elseif key == Keyboard.KEY_LEFT then
        window.movingPixel = true
        window.movingDir = MOVING_LEFT
    elseif key == Keyboard.KEY_RIGHT then
        window.movingPixel = true
        window.movingDir = MOVING_RIGHT
    end
end

Events.OnTick.Add(NIM_TransferRegionWindow.onTick)
Events.OnKeyPressed.Add(NIM_TransferRegionWindow.onKeyPress)