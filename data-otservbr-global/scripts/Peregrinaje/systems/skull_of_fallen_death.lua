dofile(CORE_DIRECTORY .. "/libs/systems/blessing.lua")

local ANKH_OF_FALLEN = 6561
local ANKH_OF_FALLEN_EXP_ATTR = 'LOST_EXP_ATTR'
local ANKH_OF_FALLEN_NAME_ATTR = 'OWNER_NAME_ATTR'
local ANKH_OF_FALLEN_COOLDOWN = 1*60*60
Storage.AnkhOfFallenCd = 65535

--skull use
local function fmtInt(n)
    local s = tostring(math.floor(tonumber(n) or 0))
    local neg = s:sub(1,1) == "-"
    if neg then s = s:sub(2) end
    local out = s:reverse():gsub("(%d%d%d)", "%1 ")
    out = out:reverse():gsub("^ ", "")
    return neg and ("-" .. out) or out
end

local function fmtTimeLeft(sec)
    sec = math.max(0, sec or 0)
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    if h > 0 then
        return string.format("%dh %dm", h, m)
    elseif m > 0 then
        return string.format("%dm %ds", m, s)
    else
        return string.format("%ds", s)
    end
end

local AnkhOfFallen = Action("AnkhOfFallen")

local frases = {
	"Pasa el canutito pero ya!",
	"Carlos\nGago\nBarreira",
	"Y otra",
	"Yo me lo guiso, yo me lo como",
	"Preguntale a Lebron James si es un juego maldito ignorante",
	"Ese Tibia es muy nuevo tio",
}
function AnkhOfFallen.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- owner check
    local ownerName = item:getCustomAttribute(ANKH_OF_FALLEN_NAME_ATTR)
    if type(ownerName) ~= "string" or ownerName == "" then
        player:sendCancelMessage("This skull is corrupted and has no owner.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return Blessings.checkBless(player)
    end
    if ownerName:lower() ~= player:getName():lower() then
        player:sendCancelMessage("You are not the owner of this skull.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return Blessings.checkBless(player)
    end

    -- cooldown
    local now = os.time()
    local nextUse = tonumber(player:getStorageValue(Storage.AnkhOfFallenCd)) or -1
    if nextUse ~= -1 and nextUse > now then
        player:sendCancelMessage("You can use another skull in " .. fmtTimeLeft(nextUse - now) .. ".")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return Blessings.checkBless(player)
    end

    -- exp recovery
    local recover = tonumber(item:getCustomAttribute(ANKH_OF_FALLEN_EXP_ATTR)) or 0
    recover = math.max(0, math.floor(recover))
    if recover <= 0 then
        player:sendCancelMessage("This skull does not contain any experience to recover.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return Blessings.checkBless(player)
    end

    local p = player:getPosition()
    p:sendMagicEffect(CONST_ME_HOLYAREA)
	local frase = frases[math.random(1,#frases)]
    player:say(frase, TALKTYPE_MONSTER_SAY)
    p:sendMagicEffect(CONST_ME_HOLYDAMAGE)

    -- give exp and remove skull
    player:addExperience(recover, true)
    item:remove(1)

    -- set cooldown
    player:setStorageValue(Storage.AnkhOfFallenCd, now + ANKH_OF_FALLEN_COOLDOWN)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You recover " .. fmtInt(recover) .. " experience points.")
    return true
end

AnkhOfFallen:id(ANKH_OF_FALLEN)
AnkhOfFallen:register()

logger.info("Ankh of fallen script loaded")