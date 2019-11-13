LinkLuaModifier( "modifier_shadow_fiend_shadowraze_lua", "abilities/shadow_fiend_agyar_shadowraze_lua/modifier_shadow_fiend_agyar_shadowraze_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadow_raze_combo", "abilities/shadow_fiend_agyar_shadowraze_lua/shadow_fiend_agyar_shadowraze_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadow_raze_prevention", "abilities/shadow_fiend_agyar_shadowraze_lua/shadow_fiend_agyar_shadowraze_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
shadow_fiend_shadowraze_a_lua = class({})
shadow_fiend_shadowraze_b_lua = class({})
shadow_fiend_shadowraze_c_lua = class({})

function shadow_fiend_shadowraze_a_lua:OnSpellStart()
	shadowraze.OnSpellStart( self )
end
function shadow_fiend_shadowraze_b_lua:OnSpellStart()
	shadowraze.OnSpellStart( self )
end
function shadow_fiend_shadowraze_c_lua:OnSpellStart()
	shadowraze.OnSpellStart( self )
end

--------------------------------------------------------------------------------

if shadowraze==nil then
	shadowraze = {}
end

function shadowraze.OnSpellStart( this )
	-- get references
	local distance = this:GetSpecialValueFor( "shadowraze_range" )
	local front = this:GetCaster():GetForwardVector():Normalized()
	local target_pos = this:GetCaster():GetOrigin() + front * distance
	local target_radius = this:GetSpecialValueFor( "shadowraze_radius" )
	local base_damage = this:GetSpecialValueFor( "shadowraze_damage" )
	local stack_damage = this:GetSpecialValueFor( "stack_bonus_damage" )
	local stack_duration = this:GetSpecialValueFor( "duration" )

	local modifier_combo = "modifier_shadow_raze_combo"
	local modifier_prevention = "modifier_shadow_raze_prevention"
	local shadow_combo_duration = this:GetSpecialValueFor( "shadow_combo_duration" )

	-- get affected enemies
	local enemies = FindUnitsInRadius(
		this:GetCaster():GetTeamNumber(),
		target_pos,
		nil,
		target_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	-- for each affected enemies
	for _,enemy in pairs(enemies) do
		-- Get Stack
		local modifier = enemy:FindModifierByNameAndCaster("modifier_shadow_fiend_shadowraze_lua", this:GetCaster())
		local stack = 0
		if modifier~=nil then
			stack = modifier:GetStackCount()
		end

		-- Apply damage
		local damageTable = {
			victim = enemy,
			attacker = this:GetCaster(),
			damage = base_damage + stack*stack_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = this,
		}
		ApplyDamage( damageTable )

		-- Add stack
		if modifier==nil then
			enemy:AddNewModifier(
				this:GetCaster(),
				this,
				"modifier_shadow_fiend_shadowraze_lua",
				{duration = stack_duration}
			)
		else
			modifier:IncrementStackCount()
			modifier:ForceRefresh()
		end
	end

	if #enemies > 0 then
		-- Apply a shadow combo modifier to caster if it doesn't have it. Regardless, add a stack and refresh
		if not this:GetCaster():HasModifier(modifier_combo) and not this:GetCaster():HasModifier(modifier_prevention) then
			this:GetCaster():AddNewModifier(this:GetCaster(), this, modifier_combo, {duration = shadow_combo_duration})
		end

		local modifier_combo_handler = this:GetCaster():FindModifierByName(modifier_combo)
		if modifier_combo_handler then
			modifier_combo_handler:IncrementStackCount()
			modifier_combo_handler:ForceRefresh()
		end
	end

	-- Effects
	shadowraze.PlayEffects( this, target_pos, target_radius )
end

function shadowraze.PlayEffects( this, position, radius )
	-- get resources
	local particle_cast = "particles/heroes/nevermore/nevermore_shadowraze_green.vpcf"
	local sound_cast = "Hero_Nevermore.Shadowraze"

	-- create particle
	-- local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, position )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, 1, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	
	-- create sound
	EmitSoundOnLocationWithCaster( position, sound_cast, this:GetCaster() )
end

--------------------------------------------------------------------------------
-- Shadow Combo Modifier
modifier_shadow_raze_combo = modifier_shadow_raze_combo or class({})

function modifier_shadow_raze_combo:OnCreated()
	if IsServer() then
		-- Ability properties
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.razes = {}
		self.razes[1] = "shadow_fiend_shadowraze_a_lua"
		self.razes[2] = "shadow_fiend_shadowraze_b_lua"
		self.razes[3] = "shadow_fiend_shadowraze_c_lua"
		self.modifier_prevention = "modifier_shadow_raze_prevention"

		-- Ability specials
		self.combo_prevention_duration = self.ability:GetSpecialValueFor("combo_prevention_duration")
		self.combo_threshold = self.ability:GetSpecialValueFor("combo_threshold")
	end
end

function modifier_shadow_raze_combo:IsHidden() return false end
function modifier_shadow_raze_combo:IsPurgable() return false end

function modifier_shadow_raze_combo:OnStackCountChanged()
	if IsServer() then
		-- Get stack count
		local stacks = self:GetStackCount()

		-- If the caster has the prevention modifier, do nothing
		if self.caster:HasModifier(self.modifier_prevention) then
			return nil
		end

		-- If the stack count below the threshold, do nothing
		if stacks < self.combo_threshold then
			return nil
		end

		-- Waits one frame to refresh
		Timers:CreateTimer(FrameTime(), function()
			-- Otherwise, find all caster's razes and refresh their cooldowns
			for i = 1, #self.razes do
				if self.caster:HasAbility(self.razes[i]) then
					self.raze_close_handler = self.caster:FindAbilityByName(self.razes[i])
					if self.raze_close_handler then
						self.raze_close_handler:EndCooldown()
					end
				end
			end
		end)

		-- Give the caster the prevention modifier
		self.caster:AddNewModifier(self.caster, self.ability, self.modifier_prevention, {duration = self.combo_prevention_duration})
		self:Destroy()
	end
end

--------------------------------------------------------------------------------
-- Shadow Combo prevention modifier
modifier_shadow_raze_prevention = modifier_shadow_raze_prevention or class({})

function modifier_shadow_raze_prevention:IsHidden() return false end
function modifier_shadow_raze_prevention:IsPurgable() return false end
function modifier_shadow_raze_prevention:IsDebuff() return true end