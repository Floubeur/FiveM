ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('esx_mission_illegal:create_robber')
AddEventHandler('esx_mission_illegal:create_robber', function()

  local _source = source
	local xPlayer		= ESX.GetPlayerFromId(_source)
  local blackMoney	= xPlayer.getAccount('black_money').money

  if (Config.Price >= blackMoney) then
    TriggerClientEvent('esx:showNotification', _source, _U('no_money') ..Config.Price.. ' $')
  else
    MySQL.Async.execute(
    'INSERT INTO robber_mission (identifier) VALUES (@identifier)',
    {
      ['@identifier'] = xPlayer.identifier,
    })
    TriggerClientEvent('esx_mission_illegal:is_robber', _source)
    xPlayer.removeAccountMoney('black_money', Config.Price)
  end

end)

RegisterServerEvent('esx_mission_illegal:mission_win')
AddEventHandler('esx_mission_illegal:mission_win', function(reward, xp, caution)

  local _source = source
  local xPlayer		= ESX.GetPlayerFromId(_source)

  if caution ~= nil then 
    xPlayer.addMoney(caution)
  end 

  xPlayer.addAccountMoney('black_money', reward)
  TriggerClientEvent('esx:showNotification', _source, _U('Win')..reward.. ' $ et ' .. xp.. ' xp')
  Add_Mission(xp)
  
end)

RegisterServerEvent('esx_mission_illegal:remove_caution')
AddEventHandler('esx_mission_illegal:remove_caution', function(caution)

  local _source = source
  local xPlayer		= ESX.GetPlayerFromId(_source)
  
  xPlayer.removeMoney(caution)
  TriggerClientEvent('esx:showNotification', _source, _U('caution')..caution.. ' $')
  
end)
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
----------------------------------- FONCTION -----------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

function Add_Mission(xp)

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)

  MySQL.Async.fetchAll(
  'SELECT * FROM robber_mission WHERE identifier = @identifier',
  {
    ['@identifier'] = xPlayer.identifier
  },
  function(result)
    local Number_Mission = result[1].nub_mission
    local New_Nub_Mission = Number_Mission + 1

    local Number_xp = result[1].experience
    local new_xp = Number_xp + xp

    MySQL.Async.execute(
    'UPDATE robber_mission SET nub_mission = @nub_mission, experience = @experience ',
    {
      ['@nub_mission'] = New_Nub_Mission,
      ['experience']   = new_xp
    })

    local experience = result[1].experience

    if (experience >= Config.Max_Experience_LVL1) and (experience <= Config.Max_Experience_LVL2) then 
      MySQL.Async.execute(
      'UPDATE robber_mission SET lvl_robber = @lvl_robber, experience = @experience',
      {
        ['@lvl_robber'] = 1,
      })
    elseif  (experience >= Config.Max_Experience_LVL2) and (experience <= Config.Max_Experience_LVL3) then 
      MySQL.Async.execute(
      'UPDATE robber_mission SET lvl_robber = @lvl_robber, experience = @experience',
      {
        ['@lvl_robber'] = 2,
      })
    elseif  (experience >= Config.Max_Experience_LVL3) and (experience <= Config.Max_Experience_LVL4) then 
      MySQL.Async.execute(
      'UPDATE robber_mission SET lvl_robber = @lvl_robber, experience = @experience',
      {
        ['@lvl_robber'] = 3,
      }) 
    elseif  (experience >= Config.Max_Experience_LVL4) then 
      MySQL.Async.execute(
      'UPDATE robber_mission SET lvl_robber = @lvl_robber, experience = @experience',
      {
        ['@lvl_robber'] = 4,
      }) 
    end
  
  end)
end


--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
---------------------------- RegisterServerCallback ----------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------


ESX.RegisterServerCallback('esx_mission_illegal:is_robber', function(source, cb)

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  
  MySQL.Async.fetchAll(
  'SELECT * FROM  robber_mission WHERE identifier = @identifier',
  {
    ['@identifier'] = xPlayer.identifier
  },
  function(result)
    for i=1, #result, 1 do
      if result[i].identifier == xPlayer.identifier then
        if result[i].robber ~= false then
        cb(true)	
        end
      end
    end
  end)
end)

ESX.RegisterServerCallback('esx_mission_illegal:check_robber', function(source, cb)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.fetchAll(
  'SELECT * FROM robber_mission WHERE identifier = @identifier', 
  {
    ['@identifier'] = xPlayer.identifier
  },
  function(result)
    data = {}
    for i=1, #result, 1 do
      table.insert(data, {
      identifier  = xPlayer.identifier,
      lvl_robber  = result[i].lvl_robber,
      })
    end
    cb(data)
  end)
end)
