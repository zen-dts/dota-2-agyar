modifier_undying_agyar_decay_lua_debuff = class({})
local tempTable = require("utils/tempTable") -- This calls on the tempTable which is needed for temporary effects
--------------------------------------------------------------------------------
-- Classifications | These classifications must be used with all modifiers.
function modifier_undying_agyar_decay_lua_debuff:IsHidden()
	return false
end

function modifier_undying_agyar_decay_lua_debuff:IsDebuff()
	return true
end

function modifier_undying_agyar_decay_lua_debuff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations -- when the modifier is added to target firt time
function modifier_undying_agyar_decay_lua_debuff:OnCreated( kv )
		
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.str_loss = -self:GetAbility():GetSpecialValueFor( "str_steal" )
	self.model_scale_enemy = self:GetAbility():GetSpecialValueFor( "model_scale_enemy" )

	if IsServer() then
		local buffDuration = self:GetAbility():GetSpecialValueFor( "decay_duration" )

		-- add stack modifier
		local decayed = tempTable:AddATValue( self )
		self:GetParent():AddNewModifier(
			self:GetCaster(),
			self,
			"modifier_undying_agyar_decay_lua_debuff_stack",
			{
				duration = buffDuration,
				modifier = decayed,
			}
		)

		-- add +1 to stacks -> (1 stack means that it steals "str_steal")
		self:IncrementStackCount()

		-- Start interval thinking
		self:StartIntervalThink( 1 )
	end
end

--------------------------------------------------------------------------------
-- Refreshing or with other words recasting the spell | It should keep adding stacks,
-- but also remove expired ones
function modifier_undying_agyar_decay_lua_debuff:OnRefresh( kv )

	self.str_loss = -self:GetAbility():GetSpecialValueFor( "str_steal" )

	if IsServer() then
		local buffDuration = self:GetAbility():GetSpecialValueFor( "decay_duration" )

		-- add stack
		local decayed = tempTable:AddATValue( self )
		self:GetParent():AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_undying_agyar_decay_lua_buff_stack", -- modifier name
			{
				duration = buffDuration,
				modifier = decayed,
			} -- kv
		)
		
		-- increment stack
		self:IncrementStackCount()	
	end
end

--------------------------------------------------------------------------------
-- Removing a stack (or when duration expires) should give 19 HP / str gained back to target
function modifier_undying_agyar_decay_lua_debuff:OnRemoved()

	if self:DecrementStackCount() then
		self:GetParent():ModifyHealth( 
			self:GetParent():GetHealth() - 19*self.str_loss,
			self:GetAbility(),
			true,
			DOTA_DAMAGE_FLAG_NONE
			)
	end
end

function modifier_undying_agyar_decay_lua_debuff:OnDestroy()

end

--------------------------------------------------------------------------------
-- Modifier Effects || What modifiers happen during decay | STR Modifier and Model scale change
function modifier_undying_agyar_decay_lua_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
	return funcs
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_undying_agyar_decay_lua_debuff:OnIntervalThink()
	-- The following function steals strength from affected targets
	function modifier_undying_agyar_decay_lua_debuff:GetModifierBonusStats_Strength()
		return self:GetStackCount() * self.str_loss
	end

	-- The following function reduces enemy scale
	function modifier_undying_agyar_decay_lua_debuff:GetModifierModelScale()

		if ( -self:GetParent():GetModelScale() * ( self.model_scale_enemy ^ self:GetStackCount() ) ) > -100 then
			return -self:GetParent():GetModelScale() * ( self.model_scale_enemy ^ self:GetStackCount() )
		else
			return -100
		end
	end		
end
--------------------------------------------------------------------------------