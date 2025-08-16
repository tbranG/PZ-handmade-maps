NIM_DrawMapWindow = ISPanel:derive("NIM_DrawMapWindow");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

local WINDOW_WIDTH = 680
local WINDOW_HEIGHT = 460

local COLOR_BLACK = 0
local COLOR_RED = 1
local COLOR_BLUE = 2
local COLOR_GREEN = 3

function NIM_DrawMapWindow:prerender()
    ISPanel.prerender(self)

    local titleText = "Sketching"
    self:drawText(titleText, self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, titleText) / 2), 10, 1,1,1,1, UIFont.Small)
    self:drawRectBorder(0, 30, self.width, WINDOW_HEIGHT-60, 1, 0.4, 0.4, 0.4)

    local sketchBorderWidth = 485
    local sketchBorderHeight = 385

    local sketchBorderX = 15
    local sketchBorderY = 35

    self:drawRectBorder(sketchBorderX, sketchBorderY, sketchBorderWidth, sketchBorderHeight, 1, 0.7, 0.7, 0.7)
    self:drawRectBorder(sketchBorderX + 495, sketchBorderY, sketchBorderWidth / 3, sketchBorderHeight / 2.2, 1, 0.7, 0.7, 0.7)
    
    self:drawText("Select color:", 560, 45, 1,1,1,1, UIFont.Small)
end


function NIM_DrawMapWindow:render()
    local offsetX = 20
    local offsetY = 40
    
    for i = 1, #self.pixelMatrix do
        self:drawRect(
            self.pixelMatrix[i].x + offsetX, 
            self.pixelMatrix[i].y + offsetY, 
            25, 
            25,
            1,
            self.pixelMatrix[i].r,
            self.pixelMatrix[i].g,
            self.pixelMatrix[i].b
        )
    end

    local paperTextureWidth = 480
    local paperTextureHeight = 380

    local paperTextureX = 15
    local paperTextureY = 35

    self:drawTextureScaled(self.paperTexture, paperTextureX, paperTextureY, paperTextureWidth, paperTextureHeight, 0.3, 1, 1, 1)

    if self.canDraw then
        self:drawRectBorder(self:getMouseX() - 5, self:getMouseY() - 5, 20, 20, 1, 1, 100/255, 0)
    end
end


function NIM_DrawMapWindow:new(x, y, width, height)
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


function NIM_DrawMapWindow:initialise()
    ISPanel.initialise(self)
    self:create()
    NIM_DrawMapWindow.instance = self

    for i = 1, #self.pixelMatrix do
        if self.pixelMatrix[i].toColor == true then
            self.pixelsToColor = self.pixelsToColor + 1
        end
    end

    self.paperTexture = getTexture("media/textures/worldMap/Paper.png")
    self.character = getPlayer()
    local playerInv = self.character:getInventory()

    local hasMulticolorItem = function()
        return playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.Crayons" end) ~= nil or 
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.PenMultiColor" end) ~= nil
    end
    
    if hasMulticolorItem() then 
        return
    end

    local hasBlack = function()
        return playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.Pen" end) ~= nil or 
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.Pencil" end) ~= nil or
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.PenFancy" end) ~= nil or
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.PenSpiffo" end) ~= nil or
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.MarkerBlack" end) ~= nil
    end
    local hasRed = function()
        return playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.RedPen" end) ~= nil or 
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.MarkerRed" end) ~= nil
    end
    local hasBlue = function()
        return playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.BluePen" end) ~= nil or 
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.MarkerBlue" end) ~= nil
    end
    local hasGreen = function()
        return playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.GreenPen" end) ~= nil or 
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.MarkerGreen" end) ~= nil
    end


    if not hasBlack() then
        self.blackBtn.borderColor = {r=1, g=1, b=1, a=0.3};
        self.blackBtn.backgroundColor = {r=0, g=0, b=0, a=0.3};
        self.blackBtn.enable = false
    end

    if not hasRed() then
        self.redBtn.borderColor = {r=1, g=1, b=1, a=0.3};
        self.redBtn.backgroundColor = {r=0, g=0, b=0, a=0.3};
        self.redBtn.enable = false
    end

    if not hasBlue() then
        self.blueBtn.borderColor = {r=1, g=1, b=1, a=0.3};
        self.blueBtn.backgroundColor = {r=0, g=0, b=0, a=0.3};
        self.blueBtn.enable = false
    end

    if not hasGreen() then
        self.greenBtn.borderColor = {r=1, g=1, b=1, a=0.3};
        self.greenBtn.backgroundColor = {r=0, g=0, b=0, a=0.3};
        self.greenBtn.enable = false
    end
end


function NIM_DrawMapWindow:create()
    local btnHgt = FONT_HGT_SMALL + 2 * 4
    local padBottom = 10

    self.finish = ISButton:new((self:getWidth() / 2) - 100, self:getHeight() - 25, 100, 20, "Finish", self, NIM_DrawMapWindow.onOptionMouseDown);
    self.finish.internal = "FINISH";
    self.finish:initialise();
    self.finish:instantiate();
    self.finish.borderColor = {r=1, g=1, b=1, a=0.3};
    self.finish.enable = false;
    self:addChild(self.finish);

    self.cancel = ISButton:new((self:getWidth() / 2) + 5, self:getHeight() - 25, 100, 20, getText("UI_Cancel"), self, NIM_DrawMapWindow.onOptionMouseDown);
    self.cancel.internal = "CANCEL";
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=0, b=0, a=0.5};
    self:addChild(self.cancel);

    self.exit = ISButton:new(655, 5, 20, 20, "X", self, NIM_DrawMapWindow.onOptionMouseDown);
    self.exit.internal = "EXIT";
    self.exit:initialise();
    self.exit:instantiate();
    self.exit.borderColor = {r=1, g=1, b=1, a=0.3};
    self:addChild(self.exit);

    self.blackBtn = ISButton:new(515, 75, 150, 25, "", self, function() NIM_DrawMapWindow:onColorSelect(COLOR_BLACK) end);
    self.blackBtn.internal = "COLOR_BLACK";
    self.blackBtn:initialise();
    self.blackBtn:instantiate();
    self.blackBtn.borderColor = {r=1, g=1, b=1, a=0.3};
    self:addChild(self.blackBtn);

    self.redBtn = ISButton:new(515, 105, 150, 25, "", self, function() NIM_DrawMapWindow:onColorSelect(COLOR_RED) end);
    self.redBtn.internal = "COLOR_RED";
    self.redBtn:initialise();
    self.redBtn:instantiate();
    self.redBtn.backgroundColor = {r=1, g=0, b=0, a=0.8};
    self.redBtn.borderColor = {r=1, g=1, b=1, a=0.3};
    self:addChild(self.redBtn);

    self.blueBtn = ISButton:new(515, 135, 150, 25, "", self, function() NIM_DrawMapWindow:onColorSelect(COLOR_BLUE) end);
    self.blueBtn.internal = "COLOR_BLUE";
    self.blueBtn:initialise();
    self.blueBtn:instantiate();
    self.blueBtn.backgroundColor = {r=0, g=0, b=1, a=0.8};
    self.blueBtn.borderColor = {r=1, g=1, b=1, a=0.3};
    self:addChild(self.blueBtn);

    self.greenBtn = ISButton:new(515, 165, 150, 25, "", self, function() NIM_DrawMapWindow:onColorSelect(COLOR_GREEN) end);
    self.greenBtn.internal = "COLOR_GREEN";
    self.greenBtn:initialise();
    self.greenBtn:instantiate();
    self.greenBtn.backgroundColor = {r=0, g=1, b=0, a=0.8};
    self.greenBtn.borderColor = {r=1, g=1, b=1, a=0.3};
    self:addChild(self.greenBtn);

    self.pixelMatrix = {}
    self.pixelsToColor = 0

    local row = 0
    local column = 0

    local toColor = true

    for i = 1, 15 do
        column = 0
        toColor = false
        for j = 1, 19 do
            local randColorOffset = 0.0
            local randomFactor = ZombRand(4) == 0

            toColor = not toColor and randomFactor

            if toColor then
                randColorOffset = 0.2
            end

            table.insert(self.pixelMatrix, {
                x = column,
                y = row,
                r = 1 - randColorOffset,
                g = 1 - randColorOffset,
                b = 1 - randColorOffset,
                toColor = toColor,
                colored = false
            });
            column = column + 25;
        end
        row = row + 25
    end

    for i = 1, #self.pixelMatrix do
        if self.pixelMatrix[i].toColor then
            local newPixelToColor = ZombRand(6)

            if newPixelToColor == 0 then
                if i - 1 > 0 then
                    self.pixelMatrix[i-1].r = 0.8
                    self.pixelMatrix[i-1].g = 0.8
                    self.pixelMatrix[i-1].b = 0.8
                    self.pixelMatrix[i-1].toColor = true
                end
            end

            if newPixelToColor == 1 then
                if i + 1 < #self.pixelMatrix then
                    self.pixelMatrix[i+1].r = 0.8
                    self.pixelMatrix[i+1].g = 0.8
                    self.pixelMatrix[i+1].b = 0.8
                    self.pixelMatrix[i+1].toColor = true
                end
            end

            if newPixelToColor == 2 then
                if i - 19 > 0 then
                    self.pixelMatrix[i-19].r = 0.8
                    self.pixelMatrix[i-19].g = 0.8
                    self.pixelMatrix[i-19].b = 0.8
                    self.pixelMatrix[i-19].toColor = true
                end
            end

            if newPixelToColor == 3 then
                if i + 19 < #self.pixelMatrix then
                    self.pixelMatrix[i+19].r = 0.8
                    self.pixelMatrix[i+19].g = 0.8
                    self.pixelMatrix[i+19].b = 0.8
                    self.pixelMatrix[i+19].toColor = true
                end
            end
        end
    end

    self.coloredPixels = 0
end


function NIM_DrawMapWindow:close()
    NIM_DrawMapWindow.instance = nil
    ISPanel.close(self)
end


function NIM_DrawMapWindow:open()
    local modal = NIM_DrawMapWindow:new(
        Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTH/2 + 300, 
        Core:getInstance():getScreenHeight()/2 - 500/2,
        WINDOW_WIDTH, 
        WINDOW_HEIGHT
    )
    modal:initialise()
    modal:addToUIManager()
end


function NIM_DrawMapWindow:setVisible(visible)
    self.javaObject:setVisible(visible);
end


function NIM_DrawMapWindow:onOptionMouseDown(button, x, y)
    if button.internal == "FINISH" then
        local player = getPlayer()
        local playerInventory = player:getInventory()

        playerInventory:AddItem("Base.AreaSketch")
        
        local sketch = playerInventory:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.AreaSketch" end)
        local paper = playerInventory:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.SheetPaper2" end)

        playerInventory:Remove(paper)

        local playerCell = player:getCell()

        local zIndex = player:getZ()
        local outside = player:isOutside()
        
        local playerCanSeeOutside = player:getSquare():isAdjacentToWindow()

        local pencilColor = ""
        if self.pencilColor == COLOR_BLACK then
            pencilColor = "black"
        elseif self.pencilColor == COLOR_RED then
            pencilColor = "red"
        elseif self.pencilColor == COLOR_BLUE then
            pencilColor = "blue"
        else
            pencilColor = "green"
        end

        NIM_GenerateMap(sketch, playerCell, outside, playerCanSeeOutside, zIndex, pencilColor)
        

        self:setVisible(false);
        self:removeFromUIManager();
        self:close()
    end
    if button.internal == "CANCEL" or button.internal == "EXIT" then
        self:setVisible(false);
        self:removeFromUIManager();
        self:close()
    end
end


function NIM_DrawMapWindow:onColorSelect(color)
    local window = NIM_DrawMapWindow.instance

    window.pencilColor = color;
    window.canDraw = true;

    window.blackBtn.enable = false;
    window.redBtn.enable = false;
    window.blueBtn.enable = false;
    window.greenBtn.enable = false;
end


function NIM_DrawMapWindow:onTick()
    local window = NIM_DrawMapWindow.instance

    if window == nil then
        return
    end

    if not window.canDraw then
        return
    end

    local mouseX = window:getMouseX()
    local mouseY = window:getMouseY()

    local r, g, b

    if window.pencilColor == COLOR_BLACK then
        r = 0.2;
        g = 0.2;
        b = 0.2;
    elseif window.pencilColor == COLOR_RED then
        r = 1;
        g = 77/255;
        b = 77/255;
    elseif window.pencilColor == COLOR_BLUE then
        r = 51/255;
        g = 153/255;
        b = 1;
    else
        r = 102/255;
        g = 1;
        b = 102/255;
    end

    if window.pixelMatrix ~= nil then
        for i = 1, #window.pixelMatrix do
            if (mouseX > window.pixelMatrix[i].x + 20 and mouseX < window.pixelMatrix[i].x + 50) and 
            (mouseY > window.pixelMatrix[i].y + 40 and mouseY < window.pixelMatrix[i].y + 70) then
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
        window.finish.enable = true;
        window.canDraw = false;
    end
end

Events.OnTick.Add(NIM_DrawMapWindow.onTick)