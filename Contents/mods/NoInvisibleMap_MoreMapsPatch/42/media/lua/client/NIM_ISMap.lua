require "ISUI/Maps/ISWorldMapSymbols"

-- needed vanilla data
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_HANDWRITTEN = getTextManager():getFontHeight(UIFont.Handwritten)
local BUTTON_HGT = FONT_HGT_SMALL + 6
local UI_BORDER_SPACING = 10

function NIM_ISMapOverrides()
    -- function override
    -- we need to disable key button, so the panel is no longer acessible
    function ISMap:createChildren()
        local symbolsWidth = ISWorldMapSymbols.RequiredWidth()
        self.symbolsUI = ISWorldMapSymbols:new(self.width - UI_BORDER_SPACING - symbolsWidth - 1, UI_BORDER_SPACING, symbolsWidth, 200, self)
        self:addChild(self.symbolsUI)
        self.symbolsUI:setVisible(false)
    
        self.mapKey = ISWorldMapKey:new(UI_BORDER_SPACING, UI_BORDER_SPACING, 10, 200, self)
        self:addChild(self.mapKey)
        self.mapKey:setVisible(false)
    
        local btnWidth = UI_BORDER_SPACING*2+getTextManager():MeasureStringX(UIFont.Small, getText("UI_Close"))
        self.ok = ISButton:new(UI_BORDER_SPACING+1, self.height - BUTTON_HGT - UI_BORDER_SPACING - 1, btnWidth, BUTTON_HGT, getText("UI_Close"), self, ISMap.onButtonClick);
        self.ok.internal = "OK";
        self.ok:initialise();
        self.ok:instantiate();
        self.ok.borderColor = {r=1, g=1, b=1, a=0.4};
        self:addChild(self.ok);
    
        -- btnWidth = UI_BORDER_SPACING*2+getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_Map_Key"))
        -- self.showMapKey = ISButton:new(self.ok:getRight() + UI_BORDER_SPACING, self.ok.y, btnWidth, BUTTON_HGT, getText("IGUI_Map_Key"), self, ISMap.onButtonClick);
        -- self.showMapKey.internal = "KEY";
        -- self.showMapKey:initialise();
        -- self.showMapKey:instantiate();
        -- self.showMapKey.borderColor = {r=1, g=1, b=1, a=0.4};
        -- self:addChild(self.showMapKey);
    
        btnWidth = UI_BORDER_SPACING*2+getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_Map_EditMarkings"))
        self.editSymbolsBtn = ISButton:new(self.ok:getRight() + UI_BORDER_SPACING, self.ok.y, btnWidth, BUTTON_HGT, getText("IGUI_Map_EditMarkings"), self, ISMap.onButtonClick);
        self.editSymbolsBtn.internal = "SYMBOLS";
        self.editSymbolsBtn:initialise();
        self.editSymbolsBtn:instantiate();
        self.editSymbolsBtn.borderColor = {r=1, g=1, b=1, a=0.4};
        self:addChild(self.editSymbolsBtn);
    
        btnWidth = UI_BORDER_SPACING*2+getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_Map_Scale"))
        self.scaleBtn = ISButton:new(self.editSymbolsBtn:getRight() + UI_BORDER_SPACING, self.ok.y, btnWidth, BUTTON_HGT, getText("IGUI_Map_Scale"), self, ISMap.onButtonClick);
        self.scaleBtn.internal = "SCALE";
        self.scaleBtn:initialise();
        self.scaleBtn:instantiate();
        self.scaleBtn.borderColor = {r=1, g=1, b=1, a=0.4};
        self:addChild(self.scaleBtn);
    
        -- Joypad only
        btnWidth = UI_BORDER_SPACING*2+getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_Map_PlaceSymbol"))
        self.placeSymbBtn = ISButton:new(self.editSymbolsBtn:getRight() + UI_BORDER_SPACING, self.ok.y, btnWidth, BUTTON_HGT, getText("IGUI_Map_PlaceSymbol"), self, ISMap.onButtonClick);
        self.placeSymbBtn.internal = "PLACESYMBOL";
        self.placeSymbBtn:initialise();
        self.placeSymbBtn:instantiate();
        self.placeSymbBtn.borderColor = {r=1, g=1, b=1, a=0.4};
        self.placeSymbBtn:setVisible(false)
        self:addChild(self.placeSymbBtn);
    end
    
    -- function override
    -- disabling shortcuts to open the key panel
    function ISMap:onButtonClick(button)
        local player = self.character:getPlayerNum()
        if button.internal == "OK" then
            self.wrap:onKeyPress(Keyboard.KEY_ESCAPE)
            self.wrap:onKeyRelease(Keyboard.KEY_ESCAPE)
        end
        if button.internal == "SYMBOLS" then
            if JoypadState.players[player+1] then
                if self.symbolsUI:isVisible() then
                    setJoypadFocus(player, self.symbolsUI)
                else
                    self.symbolsUI:setVisible(true)
                    setJoypadFocus(player, self.symbolsUI)
                end
                return
            end
            if self.symbolsUI:isVisible() then
                self.symbolsUI:undisplay()
                self.symbolsUI:setVisible(false)
            else
                self.symbolsUI:setVisible(true)
            end
        end
        -- if button.internal == "KEY" then
        --     if JoypadState.players[player+1] then
        --         if self.mapKey:isVisible() then
        --         else
        --             self.mapKey:setVisible(true)
        --         end
        --         return
        --     end
        --     if self.mapKey:isVisible() then
        --         self.mapKey:undisplay()
        --         self.mapKey:setVisible(false)
        --     else
        --         self.mapKey:setVisible(true)
        --     end
        -- end
        if button.internal == "SCALE" then
            self.mapAPI:resetView()
        end
        if button.internal == "REMOVALL" then
            self.mapAPI:getSymbolsAPI():clear()
        end
        if button.internal == "PLACESYMBOL" then
            -- Joypad only
            self.symbolsUI:onJoypadDownInMap(Joypad.AButton, self.joyfocus)
        end
    end

    -- function override
    -- disabling showKey button
    function ISMap:updateButtons()
        self.editSymbolsBtn.enable = self:canWrite() or self:canErase()
        if self.symbolsUI.currentTool then
            self.ok:setTitle(getText("UI_Cancel"))
        else
            self.ok:setTitle(getText("UI_Close"))
        end
        local text = self.symbolsUI:getJoypadAButtonText()
        if text then
            self.placeSymbBtn.enable = true
            self.placeSymbBtn:setTitle(text)
        else
            self.placeSymbBtn.enable = false
        end
        if not self.editSymbolsBtn.enable then
            self.editSymbolsBtn.tooltip = getText("Tooltip_Map_CantWrite");
        else
            self.editSymbolsBtn.tooltip = nil;
        end

        local isMouse = (self.playerNum == 0) and (getJoypadData(self.playerNum) == nil or wasMouseActiveMoreRecentlyThanJoypad())
        self.ok:setVisible(isMouse)
        -- self.showMapKey:setVisible(isMouse)
        self.editSymbolsBtn:setVisible(isMouse)
        self.scaleBtn:setVisible(isMouse)
        self.placeSymbBtn:setVisible(isMouse)
    end
end

Events.OnGameStart.Add(NIM_ISMapOverrides)