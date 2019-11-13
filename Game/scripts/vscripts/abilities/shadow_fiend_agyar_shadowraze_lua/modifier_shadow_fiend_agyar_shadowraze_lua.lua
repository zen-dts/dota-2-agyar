modifier_shadow_fiend_shadowraze_lua = class({})

--------------------------------------------------------------------------------

function modifier_shadow_fiend_shadowraze_lua:IsHidden()
	return false
end

function modifier_shadow_fiend_shadowraze_lua:IsDebuff()
	return true
end

function modifier_shadow_fiend_shadowraze_lua:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_shadow_fiend_shadowraze_lua:OnCreated( kv )
	if not IsServer() then 
	end

	self:SetStackCount(1)

	self.ms_slow		= -self:GetAbility():GetSpecialValueFor( "ms_slow" )
	self.tr_slow		= -self:GetAbility():GetSpecialValueFor( "tr_slow" )
end

function modifier_shadow_fiend_shadowraze_lua:OnRefresh( kv )

end

function modifier_shadow_fiend_shadowraze_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
	}	
end

function modifier_shadow_fiend_shadowraze_lua:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow
end

function modifier_shadow_fiend_shadowraze_lua:GetModifierTurnRate_Percentage()
	return self.tr_slow
end

--------------------------------------------------------------------------------

function modifier_shadow_fiend_shadowraze_lua:GetEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end

function modifier_shadow_fiend_shadowraze_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
--------------------------------------------------------------------------------


-- Add a modifier similar to Batrider sticky napalm, that increases the turn rate of heroes
-- This should be done by modifying the properties of the said hero in correlation with the acquired stacks
-- Every stack should add a 1/2/3/4/5% turn rate debuff ?? Values are subject to change 
-- GetEffectAttachType !!
-- Getmodifier ms, turnrate
-- getmodifierturnrate_percentage() function
-- getmodifiermovespeedbonus_percentage() a function that works as getstackcount * self ms
-- before all we need to declarefunctions: modifier_property_movespeed_bonus_percentage, modifier_property_turn_rate_percentage


