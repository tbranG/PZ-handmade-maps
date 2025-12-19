function Patch_RV_isInside()
    local rvModData = ModData.get("modPROJECTRVInterior")
    local rvPlayerId = getPlayer():getModData().projectRV_playerId

    if not rvModData then return false end

    local rvData = rvModData.Players and rvModData.Players[rvPlayerId]

    if not rvPlayerId or not rvData then return false end

    local isInside = rvData.ActualRoom ~= nil and rvData.RoomType ~= nil
    return isInside
end