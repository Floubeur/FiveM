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

local GUI               = {}
local currentlyfast		= false
local secondsRemaining 	= 0
local PlayingAnim 		= false
local ped				= {}
local StartGoFast 		= false
local HaveDrug			= true
local HaveMission 		= false
local FailsGofast		= false
local LastZone          = nil
local CurrentAction     = nil
local CurrentActionMsg  = ''
local CurrentActionData = {}
GUI.Time                = 0

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local coords 		= GetEntityCoords(GetPlayerPed(-1))
		local minute 		= math.floor(secondsRemaining / 60)
		local lastvehicule 	= GetVehiclePedIsIn(GetPlayerPed(-1),false)

		if currentlyfast then
			drawTxt(0.66, 1.44, 1.0,1.0,0.4, _U('Time_1') .. minute .. _U('Time_2') .. secondsRemaining , 255, 255, 255, 255)
		end

		DistanceFinish = GetDistanceBetweenCoords(x,y,z, GetEntityCoords(GetPlayerPed(-1)))

		if DistanceFinish <= 2.5 and currentlyfast then 

			headsUp(_U('press_Touch'))

			if IsControlJustPressed(1, Keys["E"]) then
				if lastvehicule == plyCar then
					RemoveBlip(localisation)
					FinishActionPed()
				else
					TaskCombatPed(FinalPed, GetPlayerPed(-1), 0, 16)
					ESX.ShowNotification(_U('no_plycar'))
				end
			end

		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if currentlyfast then
			Citizen.Wait(1000)
			if(secondsRemaining > 0)then
				secondsRemaining = secondsRemaining - 1
			else
				FailGoFast()
				currentlyfast = false
			end
		end
	end
end)

RegisterNetEvent('esx_mission_illegal:start')
AddEventHandler('esx_mission_illegal:start', function()
	CreateVehicule()
end)

AddEventHandler('esx_mission_illegal:hasEnteredMarker', function(zone)
	
	for i=1, #Config.ChargePed, 1 do
		if zone == 'ChargePed' .. i  and HaveDrug == false then
		  CurrentAction     = 'charge_car'
		  CurrentActionMsg  = _U('charge_car')
		  CurrentActionData = {}
		end
	end
   
end)

Citizen.CreateThread(function()
    while true do
	  Citizen.Wait(10)
  
		if CurrentAction ~= nil then
			
			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)
	
			if IsControlPressed(0,  Keys['E']) and (GetGameTimer() - GUI.Time) > 150 then
	
				if CurrentAction == 'charge_car' then
					ChargePed()
				end

				CurrentAction = nil
				GUI.Time      = GetGameTimer()
			end
		end
  end
end)

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(10)

		local coords = GetEntityCoords(GetPlayerPed(-1))

		if StartGoFast and HaveDrug == false then
			for k,v in pairs(Config.Charge) do
				if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b , 100, false, true, 2, false, false, false, false)
				end
			end
		end

		if HaveDrug and StartGoFast then
			for k,v in pairs(Config.Finish) do
				if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, x,y,z, true) < Config.DrawDistance) then
					DrawMarker(v.Type, x,y,z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b , 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
	  Citizen.Wait(10)
   
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		local currentZone = nil
  
		if HaveMission then
			for k,v in pairs(Config.Charge) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 1.5) then
					isInMarker  = true
					currentZone = k
				end
			end
		end

		if HaveDrug and StartGoFast then
			for k,v in pairs(Config.Finish) do
				if(GetDistanceBetweenCoords(coords, x,y,z, true) < 1.5) then
					isInMarker  = true
					currentZone = k
				end
			end
		end
  
		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
		  HasAlreadyEnteredMarker = true
		  LastZone                = currentZone
		  TriggerEvent('esx_mission_illegal:hasEnteredMarker', currentZone)
		end
  
		if not isInMarker and HasAlreadyEnteredMarker then
		  HasAlreadyEnteredMarker = false
		  TriggerEvent('esx_mission_illegal:hasExitedMarker', LastZone)
		end
	end
end)

AddEventHandler('esx_mission_illegal:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--  /$$$$$$                                 /$$     /$$                    	 --
-- /$$__  $$                               | $$    |__/                    	 -- 
-- | $$  \__//$$   /$$ /$$$$$$$   /$$$$$$$ /$$$$$$   /$$  /$$$$$$  /$$$$$$$  --
-- | $$$$   | $$  | $$| $$__  $$ /$$_____/|_  $$_/  | $$ /$$__  $$| $$__  $$ --
-- | $$_/   | $$  | $$| $$  \ $$| $$        | $$    | $$| $$  \ $$| $$  \ $$ --
-- | $$     | $$  | $$| $$  | $$| $$        | $$ /$$| $$| $$  | $$| $$  | $$ --
-- | $$     |  $$$$$$/| $$  | $$|  $$$$$$$  |  $$$$/| $$|  $$$$$$/| $$  | $$ --
-- |__/      \______/ |__/  |__/ \_______/   \___/  |__/ \______/ |__/  |__/ --
--------------------------------------------------------------------------------
																   

function headsUp(text)
	SetTextComponentFormat('STRING')
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)
	SetTextFont(0)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	if(outline)then
	SetTextOutline()
	end
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x - width/2, y - height/2 + 0.005)
end

function StartPedAnim()
	TriggerServerEvent('esx_mission_illegal:checkstartmission')	
end


function CreateVehicule()
	local playerPed		= GetPlayerPed(-1)
	local model			= Config.Vehicles[GetRandomIntInRange(1,  #Config.Vehicles)]
	local RandomPed 	= Config.Peds[GetRandomIntInRange(1,  #Config.Peds)]
	local Weapon		= 1649403952
	local mult 			= 10^(n or 0)

	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(1)
	end

	HaveMission = true 	
	StartGoFast = true
	HaveDrug = false
    TriggerEvent('esx_mission_illegal:annonce',_U('Start_Gofast'), _U('Title_Gofast'), _U('Warning') )
	plyCar = CreateVehicle(model, Config.Zones.VehSpawnAction.Pos.x, Config.Zones.VehSpawnAction.Pos.y, Config.Zones.VehSpawnAction.Pos.z, Config.Zones.VehSpawnAction.Pos.h, 175, true, false)
	RandomVehiculeStat()
	SetVehicleOnGroundProperly(plyCar)
	SetModelAsNoLongerNeeded(plyCar)
	ChargeBlip = AddBlipForCoord(Config.Zones.PosPed.Pos.x, Config.Zones.PosPed.Pos.y, Config.Zones.PosPed.Pos.z)
	SetBlipAsFriendly(ChargeBlip, 1)
	SetBlipCategory(ChargeBlip, 3)
	SetBlipRoute(ChargeBlip,  true)
	chargingped = CreatePed(28, 'G_M_Y_BallaOrig_01', Config.Zones.PosPed.Pos.x, Config.Zones.PosPed.Pos.y, Config.Zones.PosPed.Pos.z, Config.Zones.PosPed.Pos.h, false, false)
	distancereward = GetDistanceBetweenCoords(Config.Zones.PosPed.Pos.x, Config.Zones.PosPed.Pos.y, Config.Zones.PosPed.Pos.z, Config.Zones.VehSpawnAction.Pos.x, Config.Zones.VehSpawnAction.Pos.y, Config.Zones.VehSpawnAction.Pos.z, true)
	secondsRemaining = math.floor(((distancereward / 10 ) / 2) * mult + 0.5 ) / mult
	currentlyfast = true
--	TriggerServerEvent('esx_mission_illegal:notif_police')

end

function ChargePed()

	local coordsPed 	= GetEntityCoords(missionped)
	local boneIndex 	= GetPedBoneIndex(missionped, 28422)
	local coords		= GetEntityCoords(GetPlayerPed(-1))
	local lastvehicule 	= GetVehiclePedIsIn(GetPlayerPed(-1),false)

	RemoveBlip(ChargeBlip)

	if lastvehicule == plyCar then
		HaveDrug = true
		TriggerEvent('esx_mission_illegal:annonce',_U('Step_1_Gofast'), _U('Title_Gofast'), _U('Warning') )
		StartRunFinish()
	else
		StartGoFast 			= false
		HaveDrug				= true
		HaveMission 			= false	
		currentlyfast			= false
		ESX.ShowNotification(_U('no_plycar'))
	end
	
end

function StartRunFinish()

	local mult 			= 10^(n or 0)
	local randomSpawn   = math.random(#Config.MissionLocations)
	
	x,y,z= Config.MissionLocations[randomSpawn][1], Config.MissionLocations[randomSpawn][2], Config.MissionLocations[randomSpawn][3]
	localisation = AddBlipForCoord(x,y,z)
	FinalPed = CreatePed(28, 'G_M_Y_BallaOrig_01', x,y,z, 0, true, false)	
	reward = (math.floor(((distancereward * math.random(5, 9)) / 100) * mult + 0.5) / mult ) * 15
	caution = math.floor((reward / math.random(3, 6)) * mult + 0.5) / mult
	distancereward = GetDistanceBetweenCoords(Config.Zones.PosPed.Pos.x, Config.Zones.PosPed.Pos.y, Config.Zones.PosPed.Pos.z, x,y,z, true)
	secondsRemaining = math.floor(((distancereward / 10 ) / 2) * mult + 0.5 ) / mult
	SetBlipAsFriendly(localisation, 1)
	SetBlipCategory(localisation, 3)
	SetBlipRoute(localisation,  true)
	TriggerServerEvent('esx_mission_illegal:remove_caution', caution)
	currentlyfast		= true

end

function FinishActionPed()

	local seat 		= 0
	local Weapon 	= 453432689
	local xp 		= Config.Go_Fast_xp 

	for i=4, 0, 1 do
		if IsVehicleSeatFree(plyCar,  seat) then
			seat = i
			break
		end
	end

	TriggerServerEvent('esx_mission_illegal:mission_win', reward, xp, caution)
	TaskLeaveVehicle(GetPlayerPed(-1),GetVehiclePedIsIn(GetPlayerPed(-1)),1)
	Citizen.Wait(1000)
	SetPedDropsWeaponsWhenDead(FinalPed, false)
	GiveWeaponToPed(FinalPed, Weapon, 2800, false, true)
	SetCurrentPedWeapon(FinalPed, Weapon,true)
	TaskEnterVehicle(FinalPed,  plyCar,  -1,  seat,  2.0,  0)
	TaskVehicleDriveWander(FinalPed, plyCar, 220.0, 1074528293)
	TaskVehicleDriveWander(FinalPed, plyCar, 220.0, 2883621)
 	TaskVehicleDriveWander(FinalPed, plyCar, 220.0, 5)
	TaskVehicleDriveWander(FinalPed, plyCar, 220.0, 786468)
	TaskVehicleDriveWander(FinalPed, plyCar, 220.0, 4194304)
	TaskVehicleDriveWander(FinalPed, plyCar, 220.0, 6)
	DeleteEntity(chargingped)
	StartGoFast 			= false
	HaveDrug				= true
	HaveMission 			= false
	currentlyfast			= false
    TriggerEvent('esx_mission_illegal:finish_mission')
	TriggerEvent('esx_mission_illegal:annonce',_U('Step_Finish_Gofast'), _U('Title_Gofast'), _U('Win').. reward .. ' $' )
	TriggerEvent("esx_blanchisseur:notify", "CHAR_LESTER_DEATHWISH", 1, _U('Title_Name_PNJ'), false, _U('notify_text_win_go_fast'))

	
end

function FailGoFast()

	local model 		= "BestiaGTS"
	local localped 		= GetPlayerPed(-1)
	local coords 		= GetEntityCoords(localped)
	local Weapon    	= 453432689
	local nmbrennemis 	= 0
	local RandomPed 	= Config.Peds[GetRandomIntInRange(1,  #Config.Peds)]
  
	FailsGofast = true 

	RemoveBlip(localisation)
	RemoveBlip(ChargeBlip)
	DeleteEntity(chargingped)
    TriggerEvent('esx_mission_illegal:finish_mission')

	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(10)
	end

	RequestModel(RandomPed)
	while ( not HasModelLoaded(RandomPed) ) do
		Citizen.Wait(10)
	end

	TriggerEvent('esx_mission_illegal:annonce',_U('Step_2_Gofast'), _U('Title_Gofast'), _U('Fails') )
	TriggerEvent("esx_blanchisseur:notify", "CHAR_LESTER_DEATHWISH", 1, _U('Title_Name_PNJ'), false, _U('notify_text_go_fast'))

	carrevange  =   CreateVehicle(model,  coords.x ,coords.y+5,coords.z ,175, true, false	)
	SetVehicleOnGroundProperly(carrevange)
	pedrevance  =   CreatePedInsideVehicle(carrevange, 4, RandomPed, -1, true, 0)
	SetPedNeverLeavesGroup(pedrevance, true)
	SetPedCanBeTargetted(pedrevance, false)
	SetPedFleeAttributes(pedrevance, 0, 0)
	SetPedFleeAttributes(pedrevance, 2, 0)
	SetPedFleeAttributes(pedrevance, 64, 0)
	SetPedFleeAttributes(pedrevance, 128, 0)
	SetPedFleeAttributes(pedrevance, 8, 0)
	SetPedFleeAttributes(pedrevance, 1, 0)
	SetPedFleeAttributes(pedrevance, 32, 0)
	SetPedDiesWhenInjured(pedrevance, false)
	SetPedDropsWeaponsWhenDead(pedrevance, false)
	GiveWeaponToPed(pedrevance, Weapon, 2800, false, true)
	SetCurrentPedWeapon(pedrevance, Weapon,true)
	TaskFollowToOffsetOfEntity(pedrevance, localped, coords.x ,coords.y, coords.z, 2, 500, 0, true )
	TaskVehicleDriveWander(pedrevance, carrevange, 220.0, 1074528293)
	TaskVehicleDriveWander(pedrevance, carrevange, 220.0, 2883621)
	TaskVehicleDriveWander(pedrevance, carrevange, 220.0, 5)
	TaskVehicleDriveWander(pedrevance, carrevange, 220.0, 786468)
	TaskVehicleDriveWander(pedrevance, carrevange, 220.0, 4194304)
	TaskVehicleDriveWander(pedrevance, carrevange, 220.0, 6)
	TaskCombatPed(pedrevance,GetPlayerPed(-1), 0, 16)
	nmbrennemis = nmbrennemis + 1
	StartGoFast 	= false
	currentlyfast 	= false

end

function RandomVehiculeStat()
	SetVehicleColours(plyCar, math.random(0 , 5) , math.random(0 , 4) )
	SetVehicleWindowTint(plyCar, 1)
	SetVehicleWindowTint(plyCar, 1)
	SetVehicleNumberPlateText(plyCar, ".......")
	ToggleVehicleMod(plyCar, 18, true)
end