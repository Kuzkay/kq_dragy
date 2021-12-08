local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local dragyShown = false

local units = 'km/h'
local distanceUnits = 'm'

local multiplier = 3.6

local time0 = nil
local startCoords = nil

if Config.useImperial then
    units = 'mph'
    distanceUnits = 'ft'
    multiplier = 2.236936
end

function ToggleDragy()
    dragyShown = not dragyShown
    SendNUIMessage({
        event = "show",
        state = dragyShown,
    })
    if not dragyShown then
        RestartDragy()
    end
end

function RestartDragy()
    SendNUIMessage({
        event = "reset",
    })

    time0 = nil
    for k, time in pairs(Config.times) do
        time.time = nil
    end
end

function SetDragyTime(time)
    if time0 then
        SendNUIMessage({
            event = "time",
            label = time.speed .. ' ' .. units,
            time = (time.time - time0) / 1000,
            speed = time.speed,
        })
    end
end
function SetDragyDistance(time)
    if time0 then
        SendNUIMessage({
            event = "distance",
            label = time.distance .. distanceUnits,
            time = (time.time - time0) / 1000,
        })
    end
end

RegisterCommand('dragy', function(source, args)
    ToggleDragy()
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000

        if dragyShown then
            sleep = 0
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed) then
                local veh = GetVehiclePedIsIn(playerPed)
                local speed = math.floor(GetEntitySpeed(veh) * multiplier)

                if speed < 1 then
                    if not time0 then
                        SendNUIMessage({
                            event = "ready",
                        })
                    end
                    time0 = GetGameTimer()
                    startCoords = GetEntityCoords(playerPed)
                end

                if time0 then
                    for k, time in pairs(Config.times) do
                        if speed >= time.speed and time.time == nil then
                            time.time = GetGameTimer()
                            SetDragyTime(time)
                        end
                    end

                    local distanceTravelled = GetDistanceBetweenCoords(startCoords, GetEntityCoords(playerPed))
                    for k, distance in pairs(Config.distances) do
                        if distanceTravelled >= (distance.distance + 0.0) and distance.time == nil then
                            distance.time = GetGameTimer()
                            SetDragyDistance(distance)
                        end
                    end

                    if IsControlJustReleased(0, Keys['DOWN']) then
                        RestartDragy()
                    end
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000

        if dragyShown then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed) then
                local veh = GetVehiclePedIsIn(playerPed)
                local speed = math.floor(GetEntitySpeed(veh) * multiplier)

                SendNUIMessage({
                    event = "speed",
                    speed = speed,
                    time = GetGameTimer(),
                })
            end
        end
        Citizen.Wait(sleep)
    end
end)

