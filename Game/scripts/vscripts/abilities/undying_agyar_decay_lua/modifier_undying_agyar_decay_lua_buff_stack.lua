modifier_undying_agyar_decay_lua_buff_stack = class({})
local tempTable = require("utils/tempTable")
--------------------------------------------------------------------------------
-- Classifications
function modifier_undying_agyar_decay_lua_buff_stack:IsHidden()
	return true
end

function modifier_undying_agyar_decay_lua_buff_stack:IsPurgable()
	return false
end

function modifier_undying_agyar_decay_lua_buff_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_undying_agyar_decay_lua_buff_stack:OnCreated( kv )
	if IsServer() then
		self.modifier = tempTable:RetATValue( kv.modifier )
	end
end

function modifier_undying_agyar_decay_lua_buff_stack:OnRemoved()
	if IsServer() then
		-- decrement stack
		if not self.modifier:IsNull() then
			self.modifier:DecrementStackCount()
		end
	end
end

function modifier_undying_agyar_decay_lua_buff_stack:OnDestroyed()

end