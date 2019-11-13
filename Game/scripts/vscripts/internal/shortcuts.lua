if (not IsInToolsMode()) then return end

local vUserIds = {}
local cheatStart

ListenToGameEvent("player_connect_full", function(keys)
	local entIndex = keys.index + 1
	local ply = EntIndexToHScript(keys.index + 1)
	local userID = keys.userid
	vUserIds[userID] = EntIndexToHScript(keys.index + 1)
end, nil)

ListenToGameEvent("player_chat", function(keys)
	local teamonly = keys.teamonly
	local userID = keys.userid
	local playerID = vUserIds[userID] and vUserIds[userID]:GetPlayerID() -- attempt to index a nil value
	local hero = playerID and PlayerResource:GetSelectedHeroEntity(playerID)
	local text = keys.text
	if ("-mods"==text) and (playerID) then
		if (hero) then
			for m,mod in pairs(hero:FindAllModifiers()) do
				print(mod:GetName())
			end
		end
	elseif ("-courier"==text) and (playerID) then
		TeamList:GetFreeCouriers()
	elseif ("-start"==text) and (playerID) then
		cheatStart()
	elseif ("-entities"==text) and (playerID) then
		local iter = Entities:First()
		while(iter) do
			if (iter:GetName()~="") then print("Entities:",iter:GetName(),iter:entindex()) end
			iter = Entities:Next(iter)
		end
	elseif ("-abils"==text) and (playerID) then
		for k,v in pairs(hero:GetAllAbilities()) do
			print(k,v,v:GetName())
		end
	elseif ("-entmods"==text) and (playerID) then
		for _,ent in pairs(Entities:FindAllInSphere(hero:GetAbsOrigin(),800)) do
			if ent.FindAllModifiers then
				for _,mod in pairs(ent:FindAllModifiers()) do
					print(ent:GetName(),mod:GetName())
				end
			end
		end
	end
end, nil)

local l2 = CustomGameEventManager:RegisterListener("butt_on_clicked", function(_,kv)
	local name = kv.button
	if ("CHEAT_QUICK"==name) then
		cheatStart()
	end
end)

function cheatStart()
	GameRules:SetStrategyTime(0)
	GameRules:SetShowcaseTime(0)
	GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_furion")
	Tutorial:SelectHero("npc_dota_hero_furion")
	PlayerResource:SetGold(0, 9876, true)
	GameRules:ResetToHeroSelection()
	Tutorial:ForceGameStart()
	GameRules:GetGameModeEntity():SetThink(
		(function()
			local hero = PlayerResource:GetSelectedHeroEntity(0)
			if (not hero) then return 0.3 end
			hero:GetAbilityByIndex(0):SetLevel(1)
			hero:GetAbilityByIndex(1):SetLevel(1)
			hero:GetAbilityByIndex(2):SetLevel(1)
			hero:GetAbilityByIndex(5):SetLevel(1)
			hero:SetAbilityPoints(-3)
			hero:AddItemByName("item_courier"):CastAbility()
			return nil
		end), 0
	)
end