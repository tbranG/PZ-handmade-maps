require "TimedActions/ISBaseTimedAction"
require "ISUI/ISMap"

SketchDrawingAction = ISBaseTimedAction:derive("SketchDrawingAction");

function SketchDrawingAction:isValid()
    return true -- Checks if character can do the action
end

function SketchDrawingAction:start()
    self:setAnimVariable("ReadType", "newspaper")
	self:setActionAnim(CharacterActionAnims.Read)
    self:setOverrideHandModelsString(nil, "MapInHand");
	self.character:playSoundLocal("MapOpen")
end

function SketchDrawingAction:perform()
    if self.mapItem then
        local autoOpen = NIM.Config.auto_open_map
        if autoOpen then
            local x = getCore():getScreenWidth() / 6;
            local y = getCore():getScreenHeight() / 6;
    
            local playerNum = self.character:getPlayerNum()
            local ui = ISMap:new(x, y, 1280, 720, self.mapItem, playerNum);
            ui:initialise();
            ui:addToUIManager();
    
            local wrap = ui:wrapInCollapsableWindow(self.mapItem:getName(), false, ISMapWrapper);
            wrap:setInfo(getText("IGUI_Map_Info"));
            wrap:setWantKeyEvents(true);
            ui.wrap = wrap;
            wrap.mapUI = ui;
            
            --self.mapItem:doBuildingStash();
            wrap:setVisible(true);
            wrap:addToUIManager();
            
            local joypadData = JoypadState.players[playerNum + 1]
            
            if joypadData then
                ui.prevFocus = joypadData.focus
                joypadData.focus = ui
            end
        end


        self.character:addReadMap(self.mapItem)
    end

    ISBaseTimedAction.perform(self)
end

function SketchDrawingAction:stop()
    ISBaseTimedAction.stop(self);
end

function SketchDrawingAction:new(character, time, map)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = time -- Anim. frames (30 frames = 1 second)
    o.mapItem = map
    return o
end

-- Action registration for multiplayer
--_G[SketchDrawingAction.Type] = SketchDrawingAction

-- return SketchDrawingAction
