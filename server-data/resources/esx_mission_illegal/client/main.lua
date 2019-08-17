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

local PlayerData                = {}
local GUI                       = {}
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local isDead                    = false
local IsRobber				          = false
local Mission_Active            = false

ESX                             = nil
GUI.Time                        = 0

Citizen.CreateThread(function()

  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(10)
  end

  ESX.TriggerServerCallback('esx_mission_illegal:is_robber', function(data)
    if data == true then
      IsRobber = true
    end
  end)

  Citizen.Wait(5000)
  PlayerData = ESX.GetPlayerData()
  
end)


function OpenRobberMenu()
  
  local elements = {}

  ESX.TriggerServerCallback('esx_mission_illegal:check_robber', function(data)
    for i=1, #data, 1 do
      local data = data[i]
      table.insert(elements, 	{label = _U('lvl_robber') .. '<span style="color:green;">'..data.lvl_robber..' ', value = 'test'})
      table.insert(elements, 	{label = _U('mission_1'), value = 'mission_1'}) 
      table.insert(elements, 	{label = _U('mission_2'), value = 'mission_2'}) 
    --  table.insert(elements, 	{label = _U('mission_3'), value = 'mission_3'}) 
    --  table.insert(elements, 	{label = _U('mission_4'), value = 'mission_4'}) 
    --  table.insert(elements, 	{label = _U('mission_5'), value = 'mission_5'}) 
      
      ESX.UI.Menu.CloseAll()

      ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'menu_actions',
        {
          elements = elements
        },
        function(data, menu)

          if data.current.value == 'mission_1' then 
            CreateVehicule()
            Mission_Active = true 
          end 
          if data.current.value == 'mission_2' then 
            StartKillNPC()
            Mission_Active = true 
          end 

        end,
        function(data, menu)
          menu.close()
          CurrentAction     = 'robber_actions_menu'
          CurrentActionMsg  = _U('press_to_open')
          CurrentActionData = {}
        end
      )
    end
  end)
end

function OpenCreateRobberMenu ()

  local elements = {}
  table.insert(elements, 	{label = _U('create_robber') .. '<span style="color:red;">'.. Config.Price ..' $', value = 'Create_robber'})

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'menu_actions',
    {
      elements = elements
    },
    function(data, menu)

      if data.current.value == 'Create_robber' then 
        TriggerServerEvent('esx_mission_illegal:create_robber')
        menu.close()
      end 

    end,
    function(data, menu)
      menu.close()
      CurrentAction     = 'robber_actions_menu'
      CurrentActionMsg  = _U('press_to_open')
      CurrentActionData = {}
    end
  )
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

AddEventHandler('esx_mission_illegal:hasEnteredMarker', function(zone)
  if zone == 'IllegalZone' then
    CurrentAction     = 'robber_actions_menu'
    CurrentActionMsg  = _U('press_to_open')
    CurrentActionData = {}
  end
end)

AddEventHandler('esx_mission_illegal:hasExitedMarker', function(zone)
  ESX.UI.Menu.CloseAll()
  CurrentAction = nil
end)


-- Display markers
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(10)

      local coords = GetEntityCoords(GetPlayerPed(-1))

      for k,v in pairs(Config.Zones) do
        if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
          DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 100, false, true, 2, false, false, false, false)
        end
      end
  end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(10)

      local coords      = GetEntityCoords(GetPlayerPed(-1))
      local isInMarker  = false
      local currentZone = nil

      for k,v in pairs(Config.Zones) do
        if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.Size.x) then
          isInMarker  = true
          currentZone = k
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


-- Key Controls
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(10)
    if CurrentAction ~= nil then

      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlPressed(0,  Keys['E']) and (GetGameTimer() - GUI.Time) > 300 then

        if CurrentAction == 'robber_actions_menu' then
          if Mission_Active == false then 
            if IsRobber == true then 
              OpenRobberMenu()
            else 
              OpenCreateRobberMenu()
            end
          else
            ESX.ShowNotification(_U('error'))
          end 
        end
        CurrentAction = nil
        GUI.Time      = GetGameTimer()
      end
    end
  end
end)


AddEventHandler('esx:onPlayerDeath', function()
  isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
  isDead = false
end)


RegisterNetEvent('esx_mission_illegal:is_robber')
AddEventHandler('esx_mission_illegal:is_robber', function()
  IsRobber = true
end)


RegisterNetEvent('esx_mission_illegal:finish_mission')
AddEventHandler('esx_mission_illegal:finish_mission', function()
  Mission_Active = false
end)


--------------------------------------------------------------------------------
--------------------------------- TEXT MISSION ---------------------------------
--------------------------------------------------------------------------------

RegisterNetEvent("esx_mission_illegal:notify")
AddEventHandler("esx_mission_illegal:notify", function(icon, type, sender, title, text)
  Citizen.CreateThread(function()
		Citizen.Wait(1)
		SetNotificationTextEntry("STRING");
		AddTextComponentString(text);
		SetNotificationMessage(icon, icon, true, type, sender, title, text);
		DrawNotification(false, true);
  end)
end)


function Message()
	Citizen.CreateThread(function()
    while messagenotfinish do
    		Citizen.Wait(1)

			DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 100)
		    while (UpdateOnscreenKeyboard() == 0) do
		        DisableAllControlActions(0);
		       Citizen.Wait(1)
		    end
		    if (GetOnscreenKeyboardResult()) then
		        local result = GetOnscreenKeyboardResult()
		        messagenotfinish = false	        
		    end
		end
	end)
	
end

RegisterNetEvent('esx_mission_illegal:annonce')
AddEventHandler('esx_mission_illegal:annonce', function(text, title, other)
    texteafiche = text
    title_mission = title
    other_text  = other
 		affichenews = true	
end) 

RegisterNetEvent('esx_mission_illegal:annoncestop')
AddEventHandler('esx_mission_illegal:annoncestop', function()
  Wait(5000)
 	affichenews = false	
end) 

function DrawAdvancedTextCNN (x,y ,w,h,sc, text, r,g,b,a,font,jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1+w, y - 0.02+h)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)    		
		if (affichenews == true) then
			DrawRect(0.494, 0.227, 5.185, 0.118, 0, 0, 0, 150)
			DrawAdvancedTextCNN(0.588, 0.14, 0.005, 0.0028, 0.8, title_mission, 255, 255, 255, 255, 1, 0)
			DrawAdvancedTextCNN(0.586, 0.199, 0.005, 0.0028, 0.6, texteafiche, 255, 255, 255, 255, 7, 0)
      DrawAdvancedTextCNN(0.588, 0.246, 0.005, 0.0028, 0.4, other_text, 255, 255, 255, 255, 0, 0)
      TriggerEvent('esx_mission_illegal:annoncestop')
		end                
	end
end)
