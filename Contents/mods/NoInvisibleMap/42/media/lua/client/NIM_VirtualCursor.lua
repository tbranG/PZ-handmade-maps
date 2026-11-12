NIM_VirtualCursor = NIM_VirtualCursor or {}

local CURSOR_SPEED = 700
local AXIS_DEADZONE = 0.2

function NIM_VirtualCursor.init(panel, x, y)
    panel.virtualCursor = {
        x = x,
        y = y,
        lastUpdate = getTimestampMs()
    }
end

function NIM_VirtualCursor.update(panel)
    local cursor = panel.virtualCursor
    local joypad = panel.joyfocus
    if not cursor or not joypad then return end

    local now = getTimestampMs()
    local delta = math.min(math.max((now - cursor.lastUpdate) / 1000, 0), 0.05)
    cursor.lastUpdate = now

    local axisX = getJoypadAimingAxisX(joypad.id)
    local axisY = getJoypadAimingAxisY(joypad.id)
    if math.abs(axisX) < AXIS_DEADZONE then axisX = 0 end
    if math.abs(axisY) < AXIS_DEADZONE then axisY = 0 end

    cursor.x = math.clamp(cursor.x + axisX * CURSOR_SPEED * delta, 0, panel.width)
    cursor.y = math.clamp(cursor.y + axisY * CURSOR_SPEED * delta, 0, panel.height)
end

function NIM_VirtualCursor.getPosition(panel)
    if panel.joyfocus and panel.virtualCursor then
        return panel.virtualCursor.x, panel.virtualCursor.y
    end
    return panel:getMouseX(), panel:getMouseY()
end

function NIM_VirtualCursor.render(panel)
    local cursor = panel.virtualCursor
    if not cursor or not panel.joyfocus then return end

    local size = 22
    panel:drawRectBorder(cursor.x - size / 2, cursor.y - size / 2, size, size, 1, 0.15, 0.15, 0.15)
    panel:drawRectBorder(cursor.x - size / 2 - 2, cursor.y - size / 2 - 2, size + 4, size + 4, 1, 1, 1, 1)
end

function NIM_VirtualCursor.restoreFocus(panel)
    if panel.joyfocus then
        setJoypadFocus(panel.joyfocus.player, panel.prevFocus)
    end
end
