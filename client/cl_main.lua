ImHUI = {}
Guis = {}

function ImHUI.create(gid, title, content)
    if not content then
        content = {}
    end
    local gui = {
        id = gid,
        settings = {
            title = title,
            active = true,
            id = gid
        },
        content = content,
        localContentUpdate = {}
    }
    Guis[gid] = gui
    return {
        text = function(id, value, json)
            local element = { id = id, method = 'text', value = value }
            if json then
                element.data = { 'json', 'childstyle' }
            end
            table.insert(Guis[gid].content, element)
        end,
        coloredText = function(id, color, value)
            table.insert(Guis[gid].content,
                { id = id, method = 'textColored', value = color, defaultValue = value }
            )
        end,
        button = function(id, value, event)
            table.insert(Guis[gid].content,
                { id = id, method = 'button', value = value, defaultValue = event }
            )
        end,
        switchButton = function(id, default, event)
            table.insert(Guis[gid].content,
                { id = id, method = 'switchButton', value = default, data = { event } }
            )
        end,
        separator = function()
            table.insert(Guis[gid].content,
                { id = GetGameTimer(), method = 'separator' })
        end,
        slider = function(id, value, default, min, max)
            table.insert(Guis[gid].content,
                { id = id, method = 'sliderFloat', value = value, defaultValue = 1, data = { min, max } })
        end,
        input = function(id, value, default)
            table.insert(Guis[gid].content,
                { id = id, method = 'inputText', value = value, defaultValue = default })
        end,
        graph = function(id, value, default, data, min, max)
            table.insert(Guis[gid].content,
                { id = id, method = 'plotLines', value = value, defaultValue = data, data = { min, max } })
        end,
        color = function(id, value, default)
            local rgba = {}
            for i, v in ipairs(default) do
                table.insert(rgba, v / 255)
            end
            table.insert(Guis[gid].content, { id = id, method = 'colorEdit4', value = value, defaultValue = rgba })
        end,
        beginChild = function()
            table.insert(Guis[gid].content, { id = GetGameTimer(), method = 'beginChild' })
        end,
        endChild = function()
            table.insert(Guis[gid].content, { id = GetGameTimer(), method = 'endChild' })
        end,
        beginWrapper = function(value)
            if not value then
                value = 'value-line'
            end
            table.insert(Guis[gid].content, { id = GetGameTimer(), method = 'beginWrapper', value = value })
        end,
        endWrapper = function()
            table.insert(Guis[gid].content, { id = GetGameTimer(), method = 'endWrapper' })
        end,
        open = function()
            SendNUIMessage({
                type = 'create',
                gui = Guis[gid]
            })
        end,
        close = function()
            SendNUIMessage({
                type = 'destroy',
                gui = Guis[gid]
            })
        end
    }
end

function ImHUI.update(gid)
    Guis[gid].localContentUpdate = {}
    return {
        text = function(id, value, json)
            local element = { id = id, method = 'text', value = value }
            if json then
                element.data = { 'json', 'childstyle' }
            end
            table.insert(Guis[gid].localContentUpdate, element)
        end,
        coloredText = function(id, color, value)
            table.insert(Guis[gid].localContentUpdate,
                { id = id, method = 'textColored', value = color, defaultValue = value }
            )
        end,
        button = function(id, value, event)
            table.insert(Guis[gid].localContentUpdate,
                { id = id, method = 'button', value = value, defaultValue = event }
            )
        end,
        switchButton = function(id, default, event)
            table.insert(Guis[gid].localContentUpdate,
                { id = id, method = 'switchButton', value = default, data = { event } }
            )
        end,
        separator = function()
            table.insert(Guis[gid].localContentUpdate,
                { id = GetGameTimer(), method = 'separator' })
        end,
        slider = function(id, value, default, min, max)
            table.insert(Guis[gid].localContentUpdate,
                { id = id, method = 'sliderFloat', value = value, defaultValue = 1, data = { min, max } })
        end,
        input = function(id, value, default)
            table.insert(Guis[gid].localContentUpdate,
                { id = id, method = 'inputText', value = value, defaultValue = default })
        end,
        graph = function(id, value, default, data, min, max)
            table.insert(Guis[gid].localContentUpdate,
                { id = id, method = 'plotLines', value = value, defaultValue = data, data = { min, max } })
        end,
        color = function(id, value, default)
            local rgba = {}
            for i, v in ipairs(default) do
                table.insert(rgba, v / 255)
            end
            table.insert(Guis[gid].localContentUpdate,
                { id = id, method = 'colorEdit4', value = value, defaultValue = rgba })
        end,
        beginChild = function()
            table.insert(Guis[gid].localContentUpdate, { id = GetGameTimer(), method = 'beginChild' })
        end,
        endChild = function()
            table.insert(Guis[gid].localContentUpdate, { id = GetGameTimer(), method = 'endChild' })
        end,
        beginWrapper = function(value)
            if not value then
                value = 'value-line'
            end
            table.insert(Guis[gid].localContentUpdate, { id = GetGameTimer(), method = 'beginWrapper', value = value })
        end,
        endWrapper = function()
            table.insert(Guis[gid].localContentUpdate, { id = GetGameTimer(), method = 'endWrapper' })
        end,
        open = function()
            SendNUIMessage({
                type = 'create',
                gui = Guis[gid]
            })
        end,
        update = function()
            SendNUIMessage({
                type = 'update',
                gui = Guis[gid]
            })
            Guis[gid].localContentUpdate = {}
        end,
        close = function()
            SendNUIMessage({
                type = 'destroy',
                gui = Guis[gid]
            })
        end
    }
end

function ImHUI.getGui(id)
    return Guis[id]
end

exports('getImHUI', function()
    return ImHUI
end)

RegisterNUICallback('clickedButton', function(data, cb)
    TriggerEvent(data.event, data.guiId, data.elementId, data.elementsData)
    cb(true)
end)

RegisterNUICallback('clickedSwitchButton', function(data, cb)
    TriggerEvent(data.event, data.guiId, data.elementId, data.state)
    cb(true)
end)

RegisterNUICallback('windowClosed', function(data, cb)
    TriggerEvent('imhui:windowClosed', data.guiId, data.elementsData)
end)

RegisterNUICallback('clicked', function(data)
    TriggerEvent("screen2world:luaImHUI")
end)

local debugMode = false
RegisterKeyMapping('imhui-focus', 'ImHUI Focus', 'keyboard', 'Z')
RegisterCommand('imhui-focus', function()
    if not debugMode then
        debugMode = true
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)
    else
        debugMode = false
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(true)
    end

    while debugMode do
        if not IsDisabledControlPressed(0, 21) then
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
        end

        DisableControlAction(0, 24, true) -- Attack
        DisableControlAction(0, 142, true) -- MeleeAttackAlternate
        DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
        DisableControlAction(0, 14, true) -- INPUT_WEAPON_WHEEL_NEXT
        DisableControlAction(0, 15, true) -- INPUT_WEAPON_WHEEL_PREV
        DisableControlAction(0, 16, true) -- INPUT_SELECT_NEXT_WEAPON
        DisableControlAction(0, 17, true) -- INPUT_SELECT_PREV_WEAPON
        DisableControlAction(0, 99, true) -- INPUT_VEH_SELECT_NEXT_WEAPON
        DisableControlAction(0, 100, true) -- INPUT_VEH_SELECT_PREV_WEAPON
        DisableControlAction(0, 81, true) -- INPUT_VEH_NEXT_RADIO
        DisableControlAction(0, 82, true) -- INPUT_VEH_PREV_RADIO
        DisableControlAction(0, 24, true) -- INPUT_ATTACK
        DisableControlAction(0, 25, true) -- INPUT_AIM
        DisableControlAction(1, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
        DisableControlAction(1, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
        DisableControlAction(1, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
        DisableControlAction(0, 200, true) -- ESC

        DisablePlayerFiring(PlayerId(), true)
        SetMouseCursorVisibleInMenus(false)

        Citizen.Wait(0)
    end
end)
