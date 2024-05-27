local setting = {
	-- At what level can do the quest?
	requiredLevel = 100,
	-- Can it be done daily? true = yes, false = no
	daily = false,
	-- Do not change from here down
	centerDemonRoomPosition = { x = 33221, y = 31659, z = 13 },
	demonsPositions = {
		{ x = 33219, y = 31657, z = 13 },
		{ x = 33221, y = 31657, z = 13 },
		{ x = 33223, y = 31659, z = 13 },
		{ x = 33224, y = 31659, z = 13 },
		{ x = 33220, y = 31661, z = 13 },
		{ x = 33222, y = 31661, z = 13 },
	},
	playersPositions = {
		{ fromPos = { x = 33225, y = 31671, z = 13 }, toPos = { x = 33222, y = 31659, z = 13 } },
		{ fromPos = { x = 33224, y = 31671, z = 13 }, toPos = { x = 33221, y = 31659, z = 13 } },
		{ fromPos = { x = 33223, y = 31671, z = 13 }, toPos = { x = 33220, y = 31659, z = 13 } },
		{ fromPos = { x = 33222, y = 31671, z = 13 }, toPos = { x = 33219, y = 31659, z = 13 } },
	},
}

local lever = Action()
local experienced = false
function lever.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	experienced = false
	if item.itemid == 2772 then
		-- Checks if you have the 4 players and if they have the required level
		for i = 1, #setting.playersPositions do
			local creature = Tile(setting.playersPositions[i].fromPos):getTopCreature()
			if creature and creature:getLevel() < setting.requiredLevel then
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "All the players need to be level " .. setting.requiredLevel .. " or higher.")
				return true
			end
			local player_to_check = creature and creature:getPlayer()
			if creature and creature:getLevel() > setting.requiredLevel * 1.5 or player_to_check and player_to_check:getStorageValue(Storage.Quest.U7_24.TheAnnihilator.Reward) == 1 then
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Someone is so experienced for this!")
				experienced = true
			end
			if player_to_check then
				player_to_check:setStorageValue(Storage.Quest.U7_24.TheAnnihilator.Reward, nil)
			end
		end

		-- Checks if there are still players inside the room, if so, return true
		if roomIsOccupied(setting.centerDemonRoomPosition, true, 4, 4) then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "A team is already inside the quest room.")
			return true
		end

		-- Create monsters
		for i = 1, #setting.demonsPositions do
			if experienced then
				Game.createMonster("Very Angry Demon", setting.demonsPositions[i])
			else
				Game.createMonster("Angry Demon", setting.demonsPositions[i])
			end
		end

		-- Get players from the tiles "playersPositions" and teleport to the demons room if all of the above requirements are met
		for i = 1, #setting.playersPositions do
			local creature = Tile(setting.playersPositions[i].fromPos):getTopCreature()
			if creature and creature:isPlayer() then
				creature:teleportTo(setting.playersPositions[i].toPos)
				creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			end
		end
		item:transform(2773)
	elseif item.itemid == 2773 then
		-- If it has "daily = true" then it will execute this function
		if setting.daily then
			player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
			return true
		end
		-- Not be able to push the lever back if someone is still inside the monsters room
		if roomIsOccupied(setting.centerDemonRoomPosition, true, 4, 4) then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "A team is already inside the quest room.")
			return true
		end
		-- Removes all monsters so that the next team can enter
		if Position.removeMonster(setting.centerDemonRoomPosition, 4, 4) then
			return true
		end
		item:transform(2772)
	end
	return true
end

lever:uid(30025)
lever:register()

local activate_hotkeys = MoveEvent()
function activate_hotkeys.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if player then
		player:setStorageValue(Storage.Quest.U7_24.TheAnnihilator.Reward, 1)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You can now use hotkeys to use items.")
	end
	return true
end
activate_hotkeys:uid(65526)
activate_hotkeys:register()
