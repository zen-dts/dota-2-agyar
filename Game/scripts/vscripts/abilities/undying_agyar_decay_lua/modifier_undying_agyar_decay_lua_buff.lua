modifier_undying_agyar_decay_lua_buff = class({})
local tempTable = require("utils/tempTable") -- This calls on the tempTable which is needed for temporary effects
--------------------------------------------------------------------------------
-- Classifications | These classifications must be used with all modifiers.
function modifier_undying_agyar_decay_lua_buff:IsHidden()
	return false
end

function modifier_undying_agyar_decay_lua_buff:IsBuff()
	return true
end

function modifier_undying_agyar_decay_lua_buff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_undying_agyar_decay_lua_buff:OnCreated( kv )
	-- when the modifier is added to target firt time
	if IsServer() then
	
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.str_steal = self:GetAbility():GetSpecialValueFor( "str_steal" )
		self.model_scale_caster = self:GetAbility():GetSpecialValueFor( "model_scale_caster" )
		
		local buffDuration = self:GetAbility():GetSpecialValueFor( "decay_duration" )

		local buffed = tempTable:AddATValue( self )
		self:GetParent():AddNewModifier(
			self:GetCaster(),
			self,
			"modifier_undying_agyar_decay_lua_buff_stack",
			{
				duration = buffDuration,
				modifier = buffed,
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
function modifier_undying_agyar_decay_lua_buff:OnRefresh( kv )
	
	self.str_steal = self:GetAbility():GetSpecialValueFor( "str_steal" )

	if IsServer() then
		local buffDuration = self:GetAbility():GetSpecialValueFor( "decay_duration" )

		-- add stack
		local buffed = tempTable:AddATValue( self )
		self:GetParent():AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_undying_agyar_decay_lua_buff_stack", -- modifier name
			{
				duration = buffDuration,
				modifier = buffed,
			} -- kv
		)
		
		-- increment stack
		self:IncrementStackCount()
	end
end

--------------------------------------------------------------------------------
-- Nothing happens when OnRemoved
function modifier_undying_agyar_decay_lua_buff:OnRemoved()

end

function modifier_undying_agyar_decay_lua_buff:OnDestroy()

end

--------------------------------------------------------------------------------
-- Modifier Effects || What modifiers happen during decay | STR Modifier and Model scale change
function modifier_undying_agyar_decay_lua_buff:DeclareFunctions()
	
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
	return funcs
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_undying_agyar_decay_lua_buff:OnIntervalThink()
	-- The following function steals strength from affected targets
	function modifier_undying_agyar_decay_lua_buff:GetModifierBonusStats_Strength()
		return self:GetStackCount() * self.str_steal
	end

	-- The following function increases caster scale
	function modifier_undying_agyar_decay_lua_buff:GetModifierModelScale()
	
		if ( self:GetParent():GetModelScale() * ( self.model_scale_caster ^ self:GetStackCount() ) ) < 220 then
			return self:GetParent():GetModelScale() * ( self.model_scale_caster ^ self:GetStackCount() )
		else
			return 220
		end
	end
end