NIM_DrawMapWindow = ISPanel:derive("NIM_DrawMapWindow");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

local WINDOW_WIDTH = 680
local WINDOW_HEIGHT = 460


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
    self:drawRectBorder(sketchBorderX + 495, sketchBorderY, sketchBorderWidth / 3, sketchBorderHeight, 1, 0.7, 0.7, 0.7)
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

    self.pixelMatrix = {}

    local row = 0
    local column = 0

    local toColor = true

    for i = 1, 15 do
        column = 0
        toColor = false
        for j = 1, 19 do
            local randColorOffset = 0.0
            local randomFactor = ZombRand(2) == 0

            toColor = not toColor and i % 2 == 1
            if toColor and not randomFactor then
                randColorOffset = 0.2
            end

            table.insert(self.pixelMatrix, {
                x = column,
                y = row,
                r = 1 - randColorOffset,
                g = 1 - randColorOffset,
                b = 1 - randColorOffset,
                toColor = toColor and not randomFactor,
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
    if button.internal == "CANCEL" or button.internal == "EXIT" then
        self:setVisible(false);
        self:removeFromUIManager();
        self:close()
    end
end


function NIM_DrawMapWindow:onTick()
    local window = NIM_DrawMapWindow.instance

    if window == nil then
        return
    end

    local mouseX = window:getMouseX()
    local mouseY = window:getMouseY()

    if window.pixelMatrix ~= nil then
        for i = 1, #window.pixelMatrix do
            if (mouseX > window.pixelMatrix[i].x + 20 and mouseX < window.pixelMatrix[i].x + 50) and 
            (mouseY > window.pixelMatrix[i].y + 40 and mouseY < window.pixelMatrix[i].y + 70) then
                if window.pixelMatrix[i].toColor and not window.pixelMatrix[i].colored then
                    window.pixelMatrix[i].r = 1
                    window.pixelMatrix[i].g = 0
                    window.pixelMatrix[i].b = 0
                    window.pixelMatrix[i].colored = true
                end
            end
        end
    end
end

Events.OnTick.Add(NIM_DrawMapWindow.onTick)