ESX          = nil
local IsDead = false
local IsAnimated = false
local IsAlreadyDrunk = false
local DrunkLevel     = -1

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('esx_basicneeds:resetStatus', function()
	TriggerEvent('esx_status:set', 'hunger', 500000)
	TriggerEvent('esx_status:set', 'thirst', 500000)
	TriggerEvent('esx_status:set', 'pee', 0)
	TriggerEvent('esx_status:set', 'health', 1000000)

end)

AddEventHandler('playerSpawned', function()

	if IsDead then
		TriggerEvent('esx_basicneeds:resetStatus')
	end

	IsDead = false
end)

AddEventHandler('esx_status:loaded', function(status)

	TriggerEvent('esx_status:registerStatus', 'hunger', 1000000, '#ff00c8', -- amarelo
	--TriggerEvent('esx_status:registerStatus', 'hunger', 1000000, '#CFAD0F',
		function(status)
			return true
		end,
		function(status)
			status.remove(200)
		end
	)

	TriggerEvent('esx_status:registerStatus', 'thirst', 1000000, '#0000ff', -- azul
	--TriggerEvent('esx_status:registerStatus', 'thirst', 1000000, '#0C98F1',
		function(status)
			return true
		end,
		function(status)
			status.remove(250)
		end
	)
	
	TriggerEvent('esx_status:registerStatus', 'pee', 0, '#ffff00', -- azul
	--TriggerEvent('esx_status:registerStatus', 'thirst', 1000000, '#0C98F1',
		function(status)
			return true
		end,
		function(status)
			status.add(50)
		end
	)
	
	TriggerEvent('esx_status:registerStatus', 'health', 1000000, '#03b017', -- azul
	--TriggerEvent('esx_status:registerStatus', 'thirst', 1000000, '#0C98F1',
		function(status)
			return true
		end,
		function(status)
			status.remove(0)
		end
	)

	Citizen.CreateThread(function()

		while true do

			Wait(1000)

			local playerPed  = GetPlayerPed(-1)
			local prevHealth = GetEntityHealth(playerPed)
			local health     = prevHealth

			TriggerEvent('esx_status:getStatus', 'hunger', function(status)
				
				if status.val == 0 then
					TriggerEvent('esx_status:remove', 'health', 500)
				end
			end)

			TriggerEvent('esx_status:getStatus', 'thirst', function(status)
				
				if status.val == 0 then
					TriggerEvent('esx_status:remove', 'health', 500)
				end
			end)			
			
			TriggerEvent('esx_status:getStatus', 'pee', function(status)
				
				if status.val == 1000000 then
					TriggerEvent('esx_status:remove', 'health', 500)
				end
			end)			
			
			TriggerEvent('esx_status:getStatus', 'health', function(status)
				
				if status.val == 0 then

					if prevHealth <= 150 then
						health = health - 5
					else
						health = health - 1
					end
				end
			end)

			if health ~= prevHealth then
				SetEntityHealth(playerPed,  health)
			end

		end

	end)

	Citizen.CreateThread(function()

		while true do

			Wait(0)

			local playerPed = GetPlayerPed(-1)
			
			if IsEntityDead(playerPed) and not IsDead then
				IsDead = true
			end

		end

	end)

end)

AddEventHandler('esx_basicneeds:isEating', function(cb)
	cb(IsAnimated)
end)

RegisterNetEvent('esx_basicneeds:onEat')
AddEventHandler('esx_basicneeds:onEat', function(prop_name)
    if not IsAnimated then
		local prop_name = prop_name or 'prop_cs_burger_01'
    	IsAnimated = true
	    local playerPed = GetPlayerPed(-1)
	    Citizen.CreateThread(function()
	        local x,y,z = table.unpack(GetEntityCoords(playerPed))
	        prop = CreateObject(GetHashKey(prop_name), x, y, z+0.2,  true,  true, true)
	        AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 18905), 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
	        RequestAnimDict('mp_player_inteat@burger')
	        while not HasAnimDictLoaded('mp_player_inteat@burger') do
	            Wait(0)
	        end
	        TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
	        Wait(3000)
	        IsAnimated = false
	        ClearPedSecondaryTask(playerPed)
	        DeleteObject(prop)
	    end)
	end
end)

RegisterNetEvent('esx_basicneeds:onDrink')
AddEventHandler('esx_basicneeds:onDrink', function(prop_name)
	if not IsAnimated then
		local prop_name = prop_name or 'prop_ld_flow_bottle'
		IsAnimated = true
		local playerPed = GetPlayerPed(-1)
		Citizen.CreateThread(function()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			prop = CreateObject(GetHashKey(prop_name), x, y, z+0.2,  true,  true, true)			
	        AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 18905), 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
			RequestAnimDict('mp_player_intdrink')  
			while not HasAnimDictLoaded('mp_player_intdrink') do
				Wait(0)
			end
			TaskPlayAnim(playerPed, 'mp_player_intdrink', 'loop_bottle', 1.0, -1.0, 2000, 0, 1, true, true, true)
			Wait(3000)
	        IsAnimated = false
	        ClearPedSecondaryTask(playerPed)
			DeleteObject(prop)
		end)
	end
end)

-- Cigarrett
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx_cigarett:startSmoke')
AddEventHandler('esx_cigarett:startSmoke', function(source)
	SmokeAnimation()
end)

function SmokeAnimation()
	local playerPed = GetPlayerPed(-1)
	
	Citizen.CreateThread(function()
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING", 0, true)               
	end)
end

-- Optionalneeds
function Drunk(level, start)
  
  Citizen.CreateThread(function()

    local playerPed = GetPlayerPed(-1)

    if start then
      DoScreenFadeOut(800)
      Wait(1000)
    end

    if level == 0 then

      RequestAnimSet("move_m@drunk@slightlydrunk")
      
      while not HasAnimSetLoaded("move_m@drunk@slightlydrunk") do
        Citizen.Wait(0)
      end

      SetPedMovementClipset(playerPed, "move_m@drunk@slightlydrunk", true)

    elseif level == 1 then

      RequestAnimSet("move_m@drunk@moderatedrunk")
      
      while not HasAnimSetLoaded("move_m@drunk@moderatedrunk") do
        Citizen.Wait(0)
      end

      SetPedMovementClipset(playerPed, "move_m@drunk@moderatedrunk", true)

    elseif level == 2 then

      RequestAnimSet("move_m@drunk@verydrunk")
      
      while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
        Citizen.Wait(0)
      end

      SetPedMovementClipset(playerPed, "move_m@drunk@verydrunk", true)

    end

    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(playerPed, true)
    SetPedIsDrunk(playerPed, true)

    if start then
      DoScreenFadeIn(800)
    end

  end)

end

function Reality()

  Citizen.CreateThread(function()

    local playerPed = GetPlayerPed(-1)

    DoScreenFadeOut(800)
    Wait(1000)

    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(playerPed, 0)
    SetPedIsDrunk(playerPed, false)
    SetPedMotionBlur(playerPed, false)

    DoScreenFadeIn(800)

  end)

end

AddEventHandler('esx_status:loaded', function(status)

  TriggerEvent('esx_status:registerStatus', 'drunk', 0, '#8F15A5', 
    function(status)
      if status.val > 0 then
        return true
      else
        return false
      end
    end,
    function(status)
      status.remove(1500)
    end
  )

	Citizen.CreateThread(function()

		while true do

			Wait(1000)

			TriggerEvent('esx_status:getStatus', 'drunk', function(status)
				
				if status.val > 0 then
					
          local start = true

          if IsAlreadyDrunk then
            start = false
          end

          local level = 0

          if status.val <= 250000 then
            level = 0
          elseif status.val <= 500000 then
            level = 1
          else
            level = 2
          end

          if level ~= DrunkLevel then
            Drunk(level, start)
          end

          IsAlreadyDrunk = true
          DrunkLevel     = level
				end

				if status.val == 0 then
          
          if IsAlreadyDrunk then
            Reality()
          end

          IsAlreadyDrunk = false
          DrunkLevel     = -1

				end

			end)

		end

	end)

end)

RegisterNetEvent('esx_optionalneeds:onDrink')
AddEventHandler('esx_optionalneeds:onDrink', function()
  
  local playerPed = GetPlayerPed(-1)
  
  TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_DRINKING", 0, 1)
  Citizen.Wait(1000)
  ClearPedTasksImmediately(playerPed)

end)

RegisterNetEvent('esx_basicneeds:pee')
AddEventHandler('esx_basicneeds:pee', function()
	ped = GetPlayerPed(-1)
	local hashSkin = GetHashKey("mp_m_freemode_01")
	if IsPedInAnyVehicle(GetPlayerPed(-1), true) == false then
		if ped then
			if(GetEntityModel(GetPlayerPed(-1)) ~= hashSkin) then
				Citizen.CreateThread(function()
					RequestAnimDict('missfbi3ig_0')
					local pedid = PlayerPedId()
					TaskPlayAnim(pedid, 'missfbi3ig_0', 'shit_loop_trev', 8.0, 8, -1, 0, 0, 0, 0, 0)
					ClearPedTasks(ped)
				end)
			else
				Citizen.CreateThread(function()
					RequestAnimDict('misscarsteal2peeing')
					local pedid = PlayerPedId()
					TaskPlayAnim(pedid, 'misscarsteal2peeing', 'peeing_intro', 8.0, -8, -1, 0, 0, 0, 0, 0)
					Citizen.Wait(GetAnimDuration('misscarsteal2peeing', 'peeing_intro'))
					TaskPlayAnim(pedid, 'misscarsteal2peeing', 'peeing_loop', 8.0, -8, -1, 0, 0, 0, 0, 0)
					Citizen.Wait(GetAnimDuration('misscarsteal2peeing', 'peeing_loop'))
					TaskPlayAnim(pedid, 'misscarsteal2peeing', 'peeing_outro', 8.0, -8, -1, 0, 0, 0, 0, 0)
					ClearPedTasks(ped)
				end)
			end
			TriggerEvent('esx_status:set', 'pee', 0)
		end
	else
		--TriggerEvent("es_freeroam:notify", "CHAR_MP_STRIPCLUB_PR", 1, "Mairie", false, "ca serai pas mieux en dehors du vehicule?")
	end
end)