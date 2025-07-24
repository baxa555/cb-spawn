-- # Necessary ------------------------------------------------------------------------------------

local Selected_Location = nil

-- # Open Event ------------------------------------------------------------------------------------

RegisterNetEvent('n-spawn-selector:client:open', function()
    local ply_ped = PlayerPedId()
    local server_data = {Day = Get_Day(), Time = GetClockHours()..":"..GetClockMinutes(), WindSpeed = GetWindSpeed(), Weather = Get_Weather(), Temperature = Get_Degree()}
    Selected_Location = 1
    DoScreenFadeOut(500) Wait(1000)
    Set_Camera("First")
    FreezeEntityPosition(ply_ped, true)
    SetEntityVisible(ply_ped, false)
    SendNUIMessage({type = "OpenMenu", Texts = Config.Locale, Server_Data = server_data, Spawns = Config.Spawns})
    SetNuiFocus(true, true)
    Wait(1000) DoScreenFadeIn(500)
end)

-- # Open from qb-spawn Event ------------------------------------------------------------------------------------

RegisterNetEvent('n-spawn-selector:client:openFromQBSpawn', function()
    local ply_ped = PlayerPedId()
    local server_data = {Day = Get_Day(), Time = GetClockHours()..":"..GetClockMinutes(), WindSpeed = GetWindSpeed(), Weather = Get_Weather(), Temperature = Get_Degree()}
    Selected_Location = 1
    DoScreenFadeOut(500) Wait(1000)
    Set_Camera("First")
    FreezeEntityPosition(ply_ped, true)
    SetEntityVisible(ply_ped, false)
    SendNUIMessage({type = "OpenMenu", Texts = Config.Locale, Server_Data = server_data, Spawns = Config.Spawns})
    SetNuiFocus(true, true)
    Wait(1000) DoScreenFadeIn(500)
end)

-- # New Location NUI Callback ------------------------------------------------------------------------------------

RegisterNUICallback('NewLocation', function(Data)
    local ply_ped = PlayerPedId()
    Selected_Location = Data.Selected
    Set_Camera("New", Data)
end) 

-- # Spawn Location NUI Callback ------------------------------------------------------------------------------------

RegisterNUICallback('SpawnLocation', function(Data)
    local ply_ped = PlayerPedId()
    local Framework = nil
    if Config.Settings['Framework'] == "qb" or Config.Settings['Framework'] == "oldqb" or Config.Settings['Framework'] == "qbx" then
        Framework = "qbcore"
    elseif Config.Settings['Framework'] == "esx" or Config.Settings['Framework'] == "oldesx" then
        Framework = "esx"
    elseif Config.Settings['Framework'] == "custom" then
        Framework = "custom"
    end
    if Config.Settings['Force_Last_Location_For_Dead'] == true then
        if Is_Player_Death(Framework) == true then
            TriggerEvent('n-spawn-selector:client:notify', Config.Locale['Dead_Error'], Config.Notify_Settings['Error_Type'])
            return
        end
    end
    SetNuiFocus(false, false)
    SendNUIMessage({type = "Loading", location = Data.Location})
    Wait(2000)
    DoScreenFadeOut(500) Wait(1000)
    SendNUIMessage({type = "CloseMenu"})
    Destroy_Camera()
    SetEntityCoords(ply_ped, Config.Spawns[Data.Location].Spawn_Coords.x, Config.Spawns[Data.Location].Spawn_Coords.y, Config.Spawns[Data.Location].Spawn_Coords.z, true, false, false, false)
    SetEntityVisible(ply_ped, true)
    FreezeEntityPosition(ply_ped, false)
    After_Spawn(Framework)
    Wait(2000) DoScreenFadeIn(500)
end) 

-- #  BURAYA BIDAHA BAK ------------------------------------------------------------------------------------
RegisterNUICallback('SpawnLastLocation', function()
    local ply_ped = PlayerPedId()
    local Framework = nil
    if Config.Settings ['Framework'] == "qb" or Config.Settings['Framework'] == "oldqb" or Config.Settings['Framework'] == "qbx" then
        Framework = "qbcore"
    elseif Config.Settings['Framework'] == "esx" or Config.Settings['Framework'] == "oldesx" then
        Framework = "esx"
    elseif Config.Settings['Framework'] == "custom" then 
        Framework = "custom"
    end
    SetNuiFocus(false,false)
    DoScreenFadeOut(500) Wait(1000)
    SendNUIMessage({type = "CloseMenu"})
    Destroy_Camera()
    
    -- Son lokasyonu al ve kontrol et
    local coords = Get_Last_Location(Framework)
    if coords and coords.x and coords.y and coords.z then
        -- Koordinatları doğru şekilde ayarla
        SetEntityCoords(ply_ped, coords.x, coords.y, coords.z, true, false, false, false)
        -- Eğer heading varsa onu da ayarla
        if coords.w or coords.heading then
            local heading = coords.w or coords.heading
            SetEntityHeading(ply_ped, heading)
        end
    else
        -- Eğer son lokasyon bulunamazsa varsayılan spawn noktasına git
        SetEntityCoords(ply_ped, Config.Spawns[1].Spawn_Coords.x, Config.Spawns[1].Spawn_Coords.y, Config.Spawns[1].Spawn_Coords.z, true, false, false, false)
    end
    
    SetEntityVisible(ply_ped, true)
    FreezeEntityPosition(ply_ped, false)
    After_Spawn(Framework)
    Wait(2000) DoScreenFadeIn(500)
end)


local QBCore = exports['qb-core']:GetCoreObject()
local camZPlus1 = 1500
local camZPlus2 = 50
local pointCamCoords = 75
local pointCamCoords2 = 0
local cam1Time = 500
local cam2Time = 1000
local choosingSpawn = false
local Houses = {}
local cam = nil
local cam2 = nil

-- Functions

local function SetDisplay(bool)
    local translations = {}
    for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
        if k:sub(0, #'ui.') then
            translations[k:sub(#'ui.' + 1)] = Lang:t(k)
        end
    end
    choosingSpawn = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = 'showUi',
        status = bool,
        translations = translations
    })
end

-- Events

RegisterNetEvent('qb-spawn:client:openUI', function(value)
    -- Eski spawn sistemini devre dışı bırakıp n-spawn-selector'ı aç
    TriggerEvent('n-spawn-selector:client:openFromQBSpawn')
end)

RegisterNetEvent('qb-houses:client:setHouseConfig', function(houseConfig)
    Houses = houseConfig
end)

RegisterNetEvent('qb-spawn:client:setupSpawns', function(cData, new, apps)
    -- Eski spawn setup'ını devre dışı bırak
    -- n-spawn-selector kendi spawn'larını kullanacak
    if not new then
        -- Yeni oyuncu için n-spawn-selector'ı aç
        TriggerEvent('n-spawn-selector:client:openFromQBSpawn')
    elseif new then
        -- Yeni oyuncu için n-spawn-selector'ı aç
        TriggerEvent('n-spawn-selector:client:openFromQBSpawn')
    end
end)

-- NUI Callbacks

RegisterNUICallback('exit', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'showUi',
        status = false
    })
    choosingSpawn = false
    cb('ok')
end)

local function SetCam(campos)
    cam2 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', campos.x, campos.y, campos.z + camZPlus1, 300.00, 0.00, 0.00, 110.00, false, 0)
    PointCamAtCoord(cam2, campos.x, campos.y, campos.z + pointCamCoords)
    SetCamActiveWithInterp(cam2, cam, cam1Time, true, true)
    if DoesCamExist(cam) then
        DestroyCam(cam, true)
    end
    Wait(cam1Time)

    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', campos.x, campos.y, campos.z + camZPlus2, 300.00, 0.00, 0.00, 110.00, false, 0)
    PointCamAtCoord(cam, campos.x, campos.y, campos.z + pointCamCoords2)
    SetCamActiveWithInterp(cam, cam2, cam2Time, true, true)
    SetEntityCoords(PlayerPedId(), campos.x, campos.y, campos.z, true, false, false, false)
end

RegisterNUICallback('setCam', function(data, cb)
    local location = tostring(data.posname)
    local type = tostring(data.type)
    DoScreenFadeOut(200)
    Wait(500)
    DoScreenFadeIn(200)
    if DoesCamExist(cam) then DestroyCam(cam, true) end
    if DoesCamExist(cam2) then DestroyCam(cam2, true) end
    if type == 'current' then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            SetCam(PlayerData.position)
        end)
    elseif type == 'house' then
        SetCam(Houses[location].coords.enter)
    elseif type == 'normal' then
        SetCam(QB.Spawns[location].coords)
    elseif type == 'appartment' then
        SetCam(Apartments.Locations[location].coords.enter)
    end
    cb('ok')
end)

RegisterNUICallback('chooseAppa', function(data, cb)
    local ped = PlayerPedId()
    local appaYeet = data.appType
    SetDisplay(false)
    DoScreenFadeOut(500)
    Wait(5000)
    TriggerServerEvent('apartments:server:CreateApartment', appaYeet, Apartments.Locations[appaYeet].label, true)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    FreezeEntityPosition(ped, false)
    RenderScriptCams(false, true, 500, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    SetCamActive(cam2, false)
    DestroyCam(cam2, true)
    SetEntityVisible(ped, true)
    cb('ok')
end)

local function PreSpawnPlayer()
    SetDisplay(false)
    DoScreenFadeOut(500)
    Wait(2000)
end

local function PostSpawnPlayer(ped)
    FreezeEntityPosition(ped, false)
    RenderScriptCams(false, true, 500, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    SetCamActive(cam2, false)
    DestroyCam(cam2, true)
    SetEntityVisible(PlayerPedId(), true)
    Wait(500)
    DoScreenFadeIn(250)
end

RegisterNUICallback('spawnplayer', function(data, cb)
    local location = tostring(data.spawnloc)
    local type = tostring(data.typeLoc)
    local ped = PlayerPedId()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local insideMeta = PlayerData.metadata['inside']
    if type == 'current' then
        PreSpawnPlayer()
        QBCore.Functions.GetPlayerData(function(pd)
            ped = PlayerPedId()
            SetEntityCoords(ped, pd.position.x, pd.position.y, pd.position.z, true, false, false, false)
            SetEntityHeading(ped, pd.position.a)
            FreezeEntityPosition(ped, false)
        end)

        if insideMeta.house ~= nil then
            local houseId = insideMeta.house
            TriggerEvent('qb-houses:client:LastLocationHouse', houseId)
        elseif insideMeta.apartment.apartmentType ~= nil or insideMeta.apartment.apartmentId ~= nil then
            local apartmentType = insideMeta.apartment.apartmentType
            local apartmentId = insideMeta.apartment.apartmentId
            TriggerEvent('qb-apartments:client:LastLocationHouse', apartmentType, apartmentId)
        end
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        PostSpawnPlayer()
    elseif type == 'house' then
        PreSpawnPlayer()
        TriggerEvent('qb-houses:client:enterOwnedHouse', location)
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
        TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
        PostSpawnPlayer()
    elseif type == 'normal' then
        local pos = QB.Spawns[location].coords
        PreSpawnPlayer()
        SetEntityCoords(ped, pos.x, pos.y, pos.z, true, false, false, false)
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
        TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
        Wait(500)
        SetEntityCoords(ped, pos.x, pos.y, pos.z, true, false, false, false)
        SetEntityHeading(ped, pos.w)
        PostSpawnPlayer()
    end
    cb('ok')
end)

-- Threads

CreateThread(function()
    while true do
        Wait(0)
        if choosingSpawn then
            DisableAllControlActions(0)
        else
            Wait(1000)
        end
    end
end)