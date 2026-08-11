require "TimedActions/ISBaseTimedAction"

ReadNIMWorldMap = ISBaseTimedAction:derive("ReadNIMWorldMap");

function ReadNIMWorldMap:isValid()
	return ISWorldMap.IsAllowed()
end

function ReadNIMWorldMap:update()
end

function ReadNIMWorldMap:start()
	self:setAnimVariable("ReadType", "newspaper")
	self:setActionAnim(CharacterActionAnims.Read)
    self:setOverrideHandModelsString(nil, "MapInHand");
--	self.character:reportEvent("EventRead")
	self.character:playSoundLocal("MapOpen")
end

function ReadNIMWorldMap:stop()
	ISBaseTimedAction.stop(self)
end

function ReadNIMWorldMap:perform()
	NIM_WorldMap.ShowWorldMap(self.playerNum, self.centerX, self.centerY, self.zoom)

	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ReadNIMWorldMap:new(character, centerX, centerY, zoom)
	local o = ISBaseTimedAction.new(self, character)
	o.maxTime = 50
	if character:isTimedActionInstant() then
		o.maxTime = 1
	end
	o.playerNum = character:getPlayerNum()
	o.centerX = centerX
	o.centerY = centerY
	o.zoom = zoom
	return o
end

