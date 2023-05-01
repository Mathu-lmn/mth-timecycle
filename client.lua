local timecycle_menu = RageUI.CreateMenu("Timecycles", "Timecycle Menu")
timecycle_menu:SetStyleSize(200)
timecycle_menu:DisplayPageCounter(true)
local open = false
local selected_timecycle = "il"
local selected_strength = 1

timecycle_menu.Closed = function()
    ClearTimecycleModifier()
    open = false
end

local path_to_timecycles = "config.json"

local fileJson = LoadResourceFile(GetCurrentResourceName(), path_to_timecycles)
if fileJson then
    timecycles_list = json.decode(fileJson)
end

RegisterCommand("timecycles", function()
    OpenTimecycleMenu()
end)

CreateThread(function()
    -- run the list from the end to the beginning and if the timecycle is already in the list, remove it
    for i = #timecycles_list, 1, -1 do
        if IsDuplicate(timecycles_list[i].Name, i) then
            table.remove(timecycles_list, i)
        else
            timecycles_list[i].Index = 1
        end
    end
    -- sort the list by name
    table.sort(timecycles_list, function(a, b)
        return a.Name < b.Name
    end)
end)

function IsDuplicate(name, pos)
    for k, v in pairs(timecycles_list) do
        if k ~= pos then
            if v.Name == name then
                return true
            end
        end
    end
    return false
end

function OpenTimecycleMenu()
    if open then
        open = false
        RageUI.Visible(timecycle_menu, false)
        return
    else
        open = true
        selected_timecycle = "il"
        RageUI.Visible(timecycle_menu, true)
        CreateThread(function()
            while open do
                RageUI.IsVisible(timecycle_menu, function()
                    -- add a button to select a timecycle
                    for k, v in pairs(timecycles_list) do
                        RageUI.List(v.Name, CreateListForIndex(v.ModificationsCount), v.Index, nil, {}, true, {
                            onListChange = function(Index, Item)
                                v.Index = Index
                                SetTimecycleModifier(tostring(v.Name))
                                SetTimecycleModifierStrength((tonumber(Index) + 0.0)/#CreateListForIndex(v.ModificationsCount))
                            end,
                            onSelected = function(Index, Item)
                                v.Index = Index
                                SetTimecycleModifier(tostring(v.Name))
                                SetTimecycleModifierStrength((tonumber(Index) + 0.0)/#CreateListForIndex(v.ModificationsCount))
                            end
                        })
                    end
                end)
                Wait(0)
            end
        end)
    end
end

function CreateListForIndex(modifications)
    local list = {0}
    for i = 1, modifications do
        table.insert(list, i)
    end
    return list
end