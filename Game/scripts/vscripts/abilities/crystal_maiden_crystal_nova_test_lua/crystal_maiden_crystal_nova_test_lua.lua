crystal_maiden_crystal_nova_test_lua = class({})
LinkLuaModifier( "modifier_crystal_maiden_crystal_nova_test_lua", "abilities/crystal_maiden_crystal_nova_test_lua/modifier_crystal_maiden_crystal_nova_test_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- AOE Radius
function crystal_maiden_crystal_nova_test_lua:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
function crystal_maiden_crystal_nova_test_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local damage = self:GetSpecialValueFor("nova_damage")
	local radius = self:GetSpecialValueFor("radius")
	local debuffDuration = self:GetSpecialValueFor("duration")

	local vision_radius = self:GetSpecialValueFor("radius")
	local vision_duration = self:GetSpecialValueFor("vision_duration")

	-- Find Units in Radius
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		point,	-- point, center point
		nil,	-- handle, cacheUnit. (idk what the f*ck is this tbh) - spells on GitHub have it
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter || FRIENDLY / ENEMY / BOTH
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache [set this to true if you want some rando shit happening around min 40]
	)

	-- Precache damage	 
	local damageTable = {
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}

	for _,enemy in pairs(enemies) do
		-- Apply damage
		damageTable.victim = enemy
		ApplyDamage(damageTable)

		-- Add modifier 
		enemy:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_crystal_maiden_crystal_nova_test_lua", -- modifier name
			{ duration = debuffDuration } -- kv
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
		0,	-- int, flag filter
		0,	-- int, order filter
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
			"modifier_crystal_maiden_crystal_nova_test_lua", -- modifier name
			{ duration = debuffDuration } -- kv
		)
		end
	end

--------------------------------------------------------------------------------
	AddFOWViewer( self:GetCaster():GetTeamNumber(), point, vision_radius, vision_duration, true )

	self:PlayEffects( point, radius, debuffDuration )
end

--------------------------------------------------------------------------------
-- Ability Considerations
function crystal_maiden_crystal_nova_test_lua:AbilityConsiderations()
	-- Scepter
	local bScepter = caster:HasScepter()

	-- Linken & Lotus
	local bBlocked = target:TriggerSpellAbsorb( self )

	-- Break
	local bBroken = caster:PassivesDisabled()

	-- Advanced Status
	local bInvulnerable = target:IsInvulnerable()
	local bInvisible = target:IsInvisible()
	local bHexed = target:IsHexed()
	local bMagicImmune = target:IsMagicImmune()

	-- Illusion Copy
	local bIllusion = target:IsIllusion()
end

--------------------------------------------------------------------------------
function crystal_maiden_crystal_nova_test_lua:PlayEffects( point, radius, duration )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf"
	local sound_cast = "Hero_Crystal.CrystalNova"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, duration, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( point, sound_cast, self:GetCaster() )
end