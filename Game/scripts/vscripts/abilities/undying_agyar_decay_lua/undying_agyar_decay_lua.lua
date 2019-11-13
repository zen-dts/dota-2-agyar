-------------------------------------------------------------------------------
-- Undying: Decay (AGYAR)
-- Ability Checklist / What does the ability do?
-- Casts Ability in AoE 
-- --	Ability has:
-- -- -- -- cast point (can be altered in DD txt file) "AbilityCastPoint"	"0.45"
-- -- -- -- radius (x) 
-- -- -- -- mana cost (can be altered in DD txt file)
-- -- -- -- cooldown (can be altered in DD txt file)
-- -- -- -- damage (x)
-- -- -- -- debuff / buff duration (x)
-- -- -- -- modifier for: STRENGTH exchange (loss / gain); SCALE (+)
-- -- -- -- targets: Enemy and Friendly Units (x)
-- -- -- -- scepter upgrade: bScepter = caster:HasScepter (+)
-- --  Has Particle and Sound on Cast
-- -- -- Particles fly towards Undying when heroes are hit
-------------------------------------------------------------------------------


undying_agyar_decay_lua = class({}) -- This is also the name in .txt file


-------------------------------------------------------------------------------
-- Passive Modifier || LUA files linked to this spell, such as modifiers, stacks / debuffs || ALWAYS LinkLuaModifier if there is modifier
LinkLuaModifier( "modifier_undying_agyar_decay_lua_buff", "abilities/undying_agyar_decay_lua/modifier_undying_agyar_decay_lua_buff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_undying_agyar_decay_lua_debuff", "abilities/undying_agyar_decay_lua/modifier_undying_agyar_decay_lua_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_undying_agyar_decay_lua_buff_stack", "abilities/undying_agyar_decay_lua/modifier_undying_agyar_decay_lua_buff_stack", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_undying_agyar_decay_lua_debuff_stack", "abilities/undying_agyar_decay_lua/modifier_undying_agyar_decay_lua_debuff_stack", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
-- 

--------------------------------------------------------------------------------
-- AOE Radius
function undying_agyar_decay_lua:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Start | Main function of a spell
function undying_agyar_decay_lua:OnSpellStart()
	-- unit identifier -- who casts? is it point target or unit?
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

--	Load data such as damage / radius / duration
	local damage = self:GetSpecialValueFor( "decay_damage" )
	local radius = self:GetSpecialValueFor( "radius" )
	local buffDuration = self:GetSpecialValueFor( "decay_duration" )
	-- local str_steal = self:GetSpecialValueFor( "str_steal" )
	

--	Local vision yes / no | spells don't give vison on default
	local vision_radius = radius
	local vision_duration = 1

--	AddFOWViewer ( self:GetCaster():GetTeamNumber(), point, vision_radius, vision_duration, true )

-- Find Units in said Radius | TARGET_TEAM_BOTH means it damage both allied and enemy heroes
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		point,	-- point, center point
		nil,	-- handle, cacheUnit. (idk what the f*ck is this tbh) - spells on GitHub have it
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter || FRIENDLY / ENEMY / BOTH
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
		FIND_ANY_ORDER,	-- int, order filter
		false	-- bool, can grow cache [set this to true if you want some rando shit happening around min 40]
	)

	-- Precache damage	 
	local damageTable = {
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, 
	}

	for _,enemy in pairs(enemies) do
		-- Apply damage
		damageTable.victim = enemy
		ApplyDamage(damageTable)

		-- Add modifier 
		enemy:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_undying_agyar_decay_lua_debuff", -- modifier name, haló válaszolsz?
			{ duration = buffDuration } -- kv
		)

		caster:AddNewModifier(
			caster,
			self,
			"modifier_undying_agyar_decay_lua_buff",
			{ duration = buffDuration }
		)
	end

--------------------------------------------------------------------------------
-- Don't damage friends, yet apply modiifier
	local friends = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		point,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
		FIND_ANY_ORDER,	-- int, order filter
		false	-- bool, can grow cache
	)

	local frienddamageTable = {
		attacker = caster,
		damage = 0,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self,
	}

	for _,friend in pairs(friends) do
		-- Apply damage
		frienddamageTable.victim = friend
		ApplyDamage(frienddamageTable)

		-- Add modifier 
		if friend ~= caster then
			friend:AddNewModifier(
				caster, -- player source
				self, -- ability source
				"modifier_undying_agyar_decay_lua_debuff", -- modifier name
				{ duration = buffDuration } -- k, v
			)
		
			caster:AddNewModifier(
				caster,
				self,
				"modifier_undying_agyar_decay_lua_buff",
				{ duration = buffDuration }
			)
		end
	end

	-- play effect_cast
	self:PlayEffects( point, vision_radius, vision_duration )
end

--------------------------------------------------------------------------------
-- Ability Considerations
--function undying_agyar_decay_lua:AbilityConsiderations()
--	-- Scepter
--	local bScepter = caster:HasScepter()
--end

--------------------------------------------------------------------------------
-- Particles & Sounds
function undying_agyar_decay_lua:PlayEffects( point, vision_radius, vision_duration )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_undying/undying_decay.vpcf"
	local sound_cast = "Undying_Agyar_Decay_Anyad" -- corresponding file is to be found in [content/soundevents/custom_sounds.vsndevts] !! How to link this??
	

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, vision_duration, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )
end