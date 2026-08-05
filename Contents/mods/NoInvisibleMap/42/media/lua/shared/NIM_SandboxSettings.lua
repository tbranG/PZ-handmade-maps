-- Init mod config data
NIM = NIM or {}
NIM.Config = {}

local function NIM_LoadSandboxConfig()
    if SandboxVars then
        NIM.Config.disable_minigames = SandboxVars.NIM_disable_minigames
        NIM.Config.auto_open_map = SandboxVars.NIM_auto_open_map
        NIM.Config.lvl_one_area = SandboxVars.NIM_lvl_one_area
        NIM.Config.lvl_two_area = SandboxVars.NIM_lvl_two_area
        NIM.Config.lvl_three_area = SandboxVars.NIM_lvl_three_area
    else
        NIM.Config.disable_minigames = false
        NIM.Config.auto_open_map = true
        NIM.Config.lvl_one_area = 1.5
        NIM.Config.lvl_two_area = 2.0
        NIM.Config.lvl_three_area = 2.5
    end
end

Events.OnInitGlobalModData.Add(NIM_LoadSandboxConfig)
