

Citizen.CreateThread(function()
	while true do
	    Citizen.Wait(0)
        
        if MissionKillNPC == true then

            local playerPed     = GetPlayerPed(-1)
            local Health        = GetEntityHealth(playerPed)
            local Health_Ped    = GetEntityHealth(Ped)
            local Health_Ped2   = GetEntityHealth(Ped2)
            local coords 		= GetEntityCoords(Ped)
            local coords2 		= GetEntityCoords(Ped2)

            if(GetDistanceBetweenCoords(GetEntityCoords(playerPed), x,y,z, true) < 25) then
                DrawMarker(6, coords.x , coords.y, coords.z+1 , 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 0, 0 , 100, false, true, 2, false, false, false, false)
                DrawMarker(6, coords2.x , coords2.y, coords2.z+1 , 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 0, 0 , 100, false, true, 2, false, false, false, false)
            end

            if Health <= 0 then 
                Fail_Kill_Mission_NPC()
            end
            if Health_Ped <= 0 and Health_Ped2 <= 0 then 
                Win_Kill_Mission_NPC()
            end
        end 	
	end
end)

function StartKillNPC ()

    MissionKillNPC = true 
    local mult 			= 10^(n or 0)
    local randomSpawn   = math.random(#Config.MissionKillNPC)
    local localped 		= GetPlayerPed(-1)
	local coords 		= GetEntityCoords(localped)

	x,y,z= Config.MissionKillNPC[randomSpawn][1], Config.MissionKillNPC[randomSpawn][2], Config.MissionKillNPC[randomSpawn][3]
    localisation = AddBlipForCoord(x,y,z)
    distancereward = GetDistanceBetweenCoords(x,y,z, coords, true)
	reward = (math.floor(((distancereward * math.random(5, 9)) / 100) * mult + 0.5) / mult ) * 15

	SetBlipAsFriendly(localisation, 1)
	SetBlipCategory(localisation, 3)
	SetBlipRoute(localisation,  true)
    TriggerEvent('esx_mission_illegal:annonce',_U('Start_KillNPC'), _U('Title_KillNPC'), _U('Warning') )
    PedKiller()

end

function Fail_Kill_Mission_NPC()

    MissionKillNPC = false
    RemoveBlip(localisation)
    TriggerEvent('esx_mission_illegal:finish_mission')

end

function Win_Kill_Mission_NPC()

    local xp = Config.Npc_killer_xp
    MissionKillNPC = false
    RemoveBlip(localisation)
    TriggerEvent('esx_mission_illegal:annonce',_U('Win_KillNPC'), _U('Title_KillNPC'), _U('Win') .. reward .. ' $' )
    TriggerEvent('esx_mission_illegal:finish_mission')
    TriggerServerEvent('esx_mission_illegal:mission_win', reward, xp)	

end


function PedKiller()

	local localped 		    = GetPlayerPed(-1)
	local Weapon    	    = 453432689
	local GroupHandle       = CreateGroup(0)
    local nmbrennemis       = 0
    local cords_distance    = 0 

	while nmbrennemis ~=  6 do

        Ped = CreatePed(28, 'G_M_Y_BallaOrig_01', x + cords_distance,y + cords_distance,z, 0, true, false)	
        Ped2 = CreatePed(28, 'G_M_Y_BallaOrig_01', x + cords_distance,y + cords_distance,z, 0, true, false)	
        SetPedAsGroupLeader(Ped, GroupHandle)
        SetPedAsGroupMember(Ped, GroupHandle)
        SetPedNeverLeavesGroup(Ped, true)
        SetPedCanBeTargetted(Ped, false)
        SetPedAsGroupMember(Ped2, GroupHandle)
        SetPedNeverLeavesGroup(Ped2, true)
        SetPedCanBeTargetted(Ped2, false)
        SetGroupSeparationRange(GroupHandle,999999.9)
        SetPedFleeAttributes(Ped, 0, 0)
        SetPedFleeAttributes(Ped, 2, 0)
        SetPedFleeAttributes(Ped, 64, 0)
        SetPedFleeAttributes(Ped, 128, 0)
        SetPedFleeAttributes(Ped, 8, 0)
        SetPedFleeAttributes(Ped, 1, 0)
        SetPedFleeAttributes(Ped, 32, 0)
        SetPedDiesWhenInjured(Ped, false)
        SetPedDropsWeaponsWhenDead(Ped, false)
        GiveWeaponToPed(Ped, Weapon, 2800, false, true)
        SetCurrentPedWeapon(Ped, Weapon,true)
        SetPedDiesWhenInjured(Ped2, false)
        SetPedDropsWeaponsWhenDead(Ped2, false)
        GiveWeaponToPed(Ped2, Weapon, 2800, false, true)
        SetCurrentPedWeapon(Ped2, Weapon,true)
        nmbrennemis = nmbrennemis + 2
        cords_distance = cords_distance + 2
        ESX.ShowNotification(nmbrennemis)
        
    end  
end