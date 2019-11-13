BUTTINGS = {
	-- These will be the default settings shown on the Team Select screen.

	GAME_TITLE = "Dota 2 but...",       -- change me! :) :)

	GAME_MODE = "AP",                   -- "AR" "AP" All Random/ All Pick
	ALLOW_SAME_HERO_SELECTION = 0,      -- 0 = everyone must pick a different hero, 1 = can pick same
	HERO_BANNING = 1,                   -- 0 = no banning, 1 = banning phase
	USE_BOTS = 0, -- TODO
	MAX_LEVEL = 25,                     -- (default = 25) the max level a hero can reach

	UNIVERSAL_SHOP_MODE = 1,            -- 0 = normal, 1 = you can buy every item in every shop (secret/side/base).
	COOLDOWN_PERCENTAGE = 100,          -- (default = 100) factor for all cooldowns
	GOLD_GAIN_PERCENTAGE = 100,         -- (default = 100) factor for gold income
	GOLD_PER_MINUTE = 90,               -- (default =  90) passive gold
	RESPAWN_TIME_PERCENTAGE = 100,      -- (default = 100) factor for respawn time
	XP_GAIN_PERCENTAGE = 100,           -- (default = 100) factor for xp income

	TOMBSTONE = 0,                      -- 0 = normal, 1 = You spawn a tombstone when you die. Teammates can ressurect you by channeling it.
	CLASSIC_ARMOR = 0,                  -- 0 = normal, 1 = Old armor formula (pre 7.20)
	                                    -- set this to 1, if your game mode will feature high amounts of armor or agility
	                                    -- otherwise the physical resistance can go to 100% making things immune to physical damage
	
	NO_UPHILL_MISS = 0,                 -- 0 = normal, 1 = 0% uphill muss chance
	FREE_COURIER = 1,                   -- 0 = normal, 1 = every team starts with a free courier
	XP_PER_MINUTE = 0,                  -- (normal dota = 0) everyone gets passive experience (like the passive gold)
	COMEBACK_TIMER = 30,                -- timer (minutes) to start comeback XP / gold 
	COMEBACK_GPM = 60,                  -- passive gold for the poorest team
	COMEBACK_XPPM = 120,                -- passive experience for the lowest team
	SHARED_GOLD_PERCENTAGE = 0,         -- all gold (except passive) is shared with teammates
	SHARED_XP_PERCENTAGE = 0,           -- all experience (except passive) is shared with teammates

	ALT_WINNING = 0,                    -- 0 = normal, 1 = use these alternative winning conditions
	ALT_KILL_LIMIT = 100,               -- Kills for alternative winnning
	ALT_TIME_LIMIT = 60,                -- Timer for alternative winning

}

function BUTTINGS.ALTERNATIVE_XP_TABLE()	-- xp values if MAX_LEVEL is different than 25
	local ALTERNATIVE_XP_TABLE = {		
		0,
		240,
		600,
		1080,
		1680,
		2300,
		2940,
		3600,
		4280,
		5080,
		5900,
		6740,
		7640,
		8865,
		10115,
		11390,
		12690,
		14015,
		15415,
		16905,
		18505,
		20405,
		22605,
		25105,
		27800,
	} for i = #ALTERNATIVE_XP_TABLE + 1, BUTTINGS.MAX_LEVEL do ALTERNATIVE_XP_TABLE[i] = ALTERNATIVE_XP_TABLE[i - 1] + (300 * ( i - 15 )) end
	return ALTERNATIVE_XP_TABLE
end

BUTTINGS_DEFAULT = table.copy(BUTTINGS)