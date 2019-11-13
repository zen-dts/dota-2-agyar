LinkLuaModifier("modifier_item_tango_agyar", "items/item_tango_agyar.lua", LUA_MODIFIER_MOTION_NONE)

item_tango_agyar = class({})

function item_tango_agyar:GetIntrinsicModifiername()
	return "modifier_item_tango_agyar"
end

function item_tango_agyar:GetCharges()
	return self:GetSpecialValueFor( "tango_charges" )
end

function item_tango_agyar:GetCastRange( location, target )
	if target and target:IsOther() then
		return self:GetSpecialValueFor( "cast_range_ward" )
	else
		return self.BaseClass.GetCastRange( self, location, target )
	end
end

function item_tango_agyar:GetCooldown()
	return
end

function item_tango_agyar:OnSpellStart()
	if IsServer() then 
		local caster = self:GetCaster()
		local target_point = self:GetCursorPosition()
		local target = self:GetCursorPoint()
		local MennyitSebezAFakiragas = RandomInt( self:GetSpecialValueFor( "dmg_pct_min" ), self:GetSpecialValueFor( "dmg_pct_max" ) )
		local buff_duration = self:GetSpecialValueFor( "buff_duration" )
	--	local treant = target:IsCreep() and ()

		-- play audio queue
		self:GetCursorTarget():EmitSound( "DOTA_ITEM.Tango.Activate" )

		-- destroy targeted tree 
		GridNav:DestroyTreesAroundPoint( target_point, 1, false )

		if target:IsWardOrBomb() then 
			target:Kill( self, caster )
		end
		-- let's check if it works with treant
		if target:IsHero() and ( string.find( target:GetName(), "npc_dota_hero_treant" ) ) then

			local damageTable = {
			victim	= self:GetCursorTarget(),
			damage = self:GetCursorTarget():GetHealth() * MennyitSebezAFakiragas * 0.01,
			damage_type	= DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
			attacker = self:GetCaster(),
			ability = self
			}

			ApplyDamage( damageTable )
		end
	end
end
		--self:SetCooldown():GetSpecialValueFor( "alt_tango_cd" ) 

--------------------
-- TANGO MODIFIER --
--------------------

modifier_item_tango_agyar = class({
	IsHidden	= function() return false end,
	IsBuff 		= function() return true end,
	IsPurgable 	= function() return false end

})

function modifier_item_tango_agyar:DeclareFunctions()
	return {
		MOIDIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end

function modifier_item_tango_agyar:OnCreated()
	if not IsServer() then return end

	self.health_regen = self:GetAbility():GetSpecialValueFor( "health_regen" ) 
end

function modifier_item_tango_agyar:GetModifierConstantHealthRegen()
	return self.health_regen
end