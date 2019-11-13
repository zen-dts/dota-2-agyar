-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_huskar_burning_spear_lua = class({})
local tempTable = require("utils/tempTable")

--------------------------------------------------------------------------------
-- Classifications
function modifier_huskar_burning_spear_lua:IsHidden()
	return false
end

function modifier_huskar_burning_spear_lua:IsDebuff()
	return true
end

function modifier_huskar_burning_spear_lua:IsStunDebuff()
	return false
end

function modifier_huskar_burning_spear_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_huskar_burning_spear_lua:OnCreated( kv )
	-- references
	self.dps = self:GetAbility():GetSpecialValueFor( "burn_damage" )
	self.str_loss = -self:GetAbility():GetSpecialValueFor( "str_loss" )


	if IsServer() then
		local duration = self:GetAbility():GetDuration()
		
		-- add stack modifier
		local flames = tempTable:AddATValue( self )
		self:GetParent():AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_huskar_burning_spear_lua_stack", -- modifier name
			{
				duration = duration,
				modifier = flames,
			} -- kv
		)

		-- increment stack
		self:IncrementStackCount()

		-- precache damage
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			-- damage = 500,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
		}

		-- start interval
		self:StartIntervalThink( 1 )
	end
end

function modifier_huskar_burning_spear_lua:OnRefresh( kv )
	-- references
	self.dps = self:GetAbility():GetSpecialValueFor( "burn_damage" )
	self.str_loss = -self:GetAbility():GetSpecialValueFor( "str_loss" )

	if IsServer() then
		local duration = self:GetAbility():GetDuration()

		-- add stack
		local flames = tempTable:AddATValue( self )
		self:GetParent():AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_huskar_burning_spear_lua_stack", -- modifier name
			{
				duration = duration,
				modifier = flames,
			} -- kv
		)
		
		-- increment stack
		self:IncrementStackCount()
	end
end

function modifier_huskar_burning_spear_lua:OnRemoved()
	-- stop effects
	local sound_cast = "Hero_Huskar.Burning_Spear"
	StopSoundOn( sound_cast, self:GetParent() )

	
	if self:DecrementStackCount() then
		self:GetParent():ModifyHealth( 
			self:GetParent():GetHealth() - 19*self.str_loss,
			self:GetAbility(),
			true,
			DOTA_DAMAGE_FLAG_NONE
			)
	end

end

function modifier_huskar_burning_spear_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- STR modifier
function modifier_huskar_burning_spear_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
	return funcs
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_huskar_burning_spear_lua:OnIntervalThink()
	-- apply str modifier
	function modifier_huskar_burning_spear_lua:GetModifierBonusStats_Strength()
		return self:GetStackCount() * self.str_loss
	end
	-- reduce health by 20 per strength str_loss | i don't even need this shit tbh, i fixed the hp issue by adding intervals
	--[[self:GetParent():ModifyHealth(
			self:GetParent():GetHealth() + self:GetStackCount()*20*self.str_loss,
			self:GetAbility(),
			true,
			DOTA_DAMAGE_FLAG_NONE
			) --]]

	-- apply dot damage
	self.damageTable.damage = self:GetStackCount() * self.dps
	ApplyDamage( self.damageTable )

end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_huskar_burning_spear_lua:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_huskar_burning_spear_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

-- function modifier_huskar_burning_spear_lua:GetStatusEffectName()
-- 	return "status/effect/here.vpcf"
-- end

-- function modifier_huskar_burning_spear_lua:PlayEffects()
-- 	-- Get Resources
-- 	local particle_cast = "particles/units/heroes/hero_heroname/heroname_ability.vpcf"
-- 	local sound_cast = "string"

-- 	-- Get Data

-- 	-- Create Particle
-- 	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_NAME, hOwner )
-- 	ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
-- 	ParticleManager:SetParticleControlEnt(
-- 		effect_cast,
-- 		iControlPoint,
-- 		hTarget,
-- 		PATTACH_NAME,
-- 		"attach_name",
-- 		vOrigin, -- unknown
-- 		bool -- unknown, true
-- 	)
-- 	ParticleManager:SetParticleControlForward( effect_cast, iControlPoint, vForward )
-- 	SetParticleControlOrientation( effect_cast, iControlPoint, vForward, vRight, vUp )
-- 	ParticleManager:ReleaseParticleIndex( effect_cast )

-- 	-- buff particle
-- 	self:AddParticle(
-- 		effect_cast,
-- 		false, -- bDestroyImmediately
-- 		false, -- bStatusEffect
-- 		-1, -- iPriority
-- 		false, -- bHeroEffect
-- 		false -- bOverheadEffect
-- 	)

-- 	-- Create Sound
-- 	EmitSoundOnLocationWithCaster( vTargetPosition, sound_location, self:GetCaster() )
-- 	EmitSoundOn( sound_target, target )
-- end