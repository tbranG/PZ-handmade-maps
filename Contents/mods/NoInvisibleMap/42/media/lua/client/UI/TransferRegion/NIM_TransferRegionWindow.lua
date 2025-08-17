NIM_TransferRegionWindow = ISPanel:derive("NIM_TransferRegionWindow");

local WINDOW_WIDTH = 860
local WINDOW_HEIGHT = 460

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

    local playerInventory = getPlayer():getInventory()
    local pistol = playerInventory:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.Pistol" end)

    --self:drawItemIcon(pistol, 50, 50, 1, 25, 25)
end


function NIM_TransferRegionWindow:render()
    for i = 1, #self.pixelMatrix do
        if self.pixelMatrix[i].filled then
            self:drawRect(
                self.pixelMatrix[i].x, 
                self.pixelMatrix[i].y, 
                50, 
                50,
                1,
                self.pixelMatrix[i].r,
                self.pixelMatrix[i].g,
                self.pixelMatrix[i].b
            )
        elseif self.pixelMatrix[i].toFill then
            self:drawRect(
                self.pixelMatrix[i].x, 
                self.pixelMatrix[i].y, 
                50, 
                50,
                0.3, 
                1, 
                1, 
                1
            )
        else
            self:drawRectBorder(
                self.pixelMatrix[i].x, 
                self.pixelMatrix[i].y, 
                50, 
                50,
                1, 
                0.4, 
                0.4, 
                0.4
            )
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
end


function NIM_TransferRegionWindow:create()
    self.exit = ISButton:new(WINDOW_WIDTH - 25, 5, 20, 20, "X", self, NIM_TransferRegionWindow.onOptionMouseDown);
    self.exit.internal = "EXIT";
    self.exit:initialise();
    self.exit:instantiate();
    self.exit.borderColor = {r=1, g=1, b=1, a=0.3};
    self:addChild(self.exit);

    self.itemsPanel = ISPanel:new(10, 40, WINDOW_WIDTH / 3.5, WINDOW_HEIGHT - 50)
    self.itemsPanel:initialise();
    self.itemsPanel:instantiate();
    self:addChild(self.itemsPanel);

    self.inputPanel = ISPanel:new(255, 40, WINDOW_WIDTH / 4.5, WINDOW_HEIGHT - 50)
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

    for i = 1, self.filledPixels do
        local validSelection = false
        repeat
            local selectedPixel = ZombRand(1, #self.pixelMatrix)

            if not self.pixelMatrix[selectedPixel].filled then
                self.pixelMatrix[selectedPixel].toFill = true
                validSelection = true
            end
        until (validSelection)
    end
end


function NIM_TransferRegionWindow:close()
    NIM_TransferRegionWindow.instance = nil
    ISPanel.close(self)
end


function NIM_TransferRegionWindow:open()
    local modal = NIM_TransferRegionWindow:new(
        Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTH/2 + 300, 
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