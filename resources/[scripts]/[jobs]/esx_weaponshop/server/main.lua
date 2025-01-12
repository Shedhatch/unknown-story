ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_weaponshop:buyLicense', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= Config.LicensePrice then
		xPlayer.removeMoney(Config.LicensePrice)

		TriggerEvent('esx_license:addLicense', source, 'weapon', function()
			cb(true)
		end)
	else
		TriggerClientEvent('esx:showNotification', source, _U('not_enough'))
		cb(false)
	end
end)

ESX.RegisterServerCallback('esx_weaponshop:buyWeapon', function(source, cb, weaponName, type, componentNum, zone, max)
	local xPlayer = ESX.GetPlayerFromId(source)
	local _, selectedWeapon = Config.Zones[zone].Items
	

	for _,v in ipairs(Config.Zones[zone].Items) do
		if v.weapon == weaponName then
			selectedWeapon = v
			break
		end
	end
	if not selectedWeapon then
		print(('esx_weaponshop: %s attempted to buy an invalid weapon.'):format(xPlayer.identifier))
		cb(false)
	end
	if zone == 'GunShop' then
		-- Weapon
		if type == 1 then
			if xPlayer.getMoney() >= selectedWeapon.price then
				xPlayer.removeMoney(selectedWeapon.price)
				xPlayer.addWeapon(weaponName, 0)

				cb(true)
			else
				cb(false)
			end
		-- Weapon Component
		elseif type == 2 then
			local price = selectedWeapon.components[componentNum]
			local _, weapon = ESX.GetWeapon(weaponName)

			local component = weapon.components[componentNum]

			if component then
				if xPlayer.getMoney() >= price then
					xPlayer.removeMoney(price)
					xPlayer.addWeaponComponent(weaponName, component.name)

					cb(true)
				else
					cb(false)
				end
			else
				print(('esx_weaponshop: %s attempted to buy an invalid weapon component.'):format(xPlayer.identifier))
				cb(false)
			end
			--Weapon Ammo
		elseif type == 3 then
			if xPlayer.getMoney() >= selectedWeapon.ammoPrice and not max then
				xPlayer.removeMoney(selectedWeapon.ammoPrice)
				cb(true)
			else
				cb(false)
			end
		end
	else
		-- Weapon
		if type == 1 then
			if xPlayer.getAccount('black_money').money >= selectedWeapon.price then
				xPlayer.removeAccountMoney('black_money', selectedWeapon.price)
				xPlayer.addWeapon(weaponName, 0)
				cb(true)
			else
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_black'))
				cb(false)
			end
		-- Weapon Component
		elseif type == 2 then
			local price = selectedWeapon.components[componentNum]
			local _, weapon = ESX.GetWeapon(weaponName)
			local component = weapon.components[componentNum]

			if component then
				if xPlayer.getAccount('black_money').money >= price then
					xPlayer.removeAccountMoney('black_money', price)
					xPlayer.addWeaponComponent(weaponName, component.name)
					cb(true)
				else
					TriggerClientEvent('esx:showNotification', source, _U('not_enough_black'))
					cb(false)
				end
			else
				print(('esx_weaponshop: %s attempted to buy an invalid weapon component.'):format(xPlayer.identifier))
				cb(false)
			end
			--Weapon Ammo
		elseif type == 3 then
			if xPlayer.getAccount('black_money').money >= selectedWeapon.ammoPrice and not max then
				xPlayer.removeAccountMoney('black_money', selectedWeapon.ammoPrice)
				cb(true)
			else
				if not max then
					TriggerClientEvent('esx:showNotification', source, _U('not_enough_black'))
				end
				cb(false)
			end
		end
	end
end)
