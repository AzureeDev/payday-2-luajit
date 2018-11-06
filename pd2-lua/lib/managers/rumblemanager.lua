core:module("RumbleManager")
core:import("CoreRumbleManager")
core:import("CoreClass")

RumbleManager = RumbleManager or class(CoreRumbleManager.RumbleManager)

function RumbleManager:init()
	RumbleManager.super.init(self)
	_G.tweak_data:add_reload_callback(self, callback(self, self, "setup_preset_rumbles"))
	self:setup_preset_rumbles()
end

function RumbleManager:setup_preset_rumbles()
	self:add_preset_rumbles("weapon_fire", {
		sustain = 0.1,
		peak = 0.5,
		release = 0.05,
		cumulative = false,
		engine = "both"
	})
	self:add_preset_rumbles("land", {
		sustain = 0.1,
		peak = 0.5,
		release = 0.1,
		cumulative = false,
		engine = "both"
	})
	self:add_preset_rumbles("hard_land", {
		sustain = 0.3,
		peak = 1,
		release = 0.1,
		cumulative = false,
		engine = "both"
	})
	self:add_preset_rumbles("electrified", {
		peak = 0.5,
		engine = "both",
		release = 0.05,
		cumulative = false
	})
	self:add_preset_rumbles("electric_shock", {
		sustain = 0.2,
		peak = 1,
		release = 0.1,
		cumulative = true,
		engine = "both"
	})
	self:add_preset_rumbles("incapacitated_shock", {
		sustain = 0.2,
		peak = 0.75,
		release = 0.1,
		cumulative = true,
		engine = "both"
	})
	self:add_preset_rumbles("damage_bullet", {
		sustain = 0.2,
		peak = 1,
		release = 0,
		cumulative = true,
		engine = "both"
	})
	self:add_preset_rumbles("bullet_whizby", {
		sustain = 0.075,
		peak = 1,
		release = 0,
		cumulative = true,
		engine = "both"
	})
	self:add_preset_rumbles("melee_hit", {
		sustain = 0.15,
		peak = 1,
		release = 0,
		cumulative = true,
		engine = "both"
	})
	self:add_preset_rumbles("mission_triggered", {
		sustain = 0.3,
		engine = "both",
		release = 2.1,
		cumulative = true,
		attack = 0.1,
		peak = 1
	})
	self:add_preset_rumbles("reloaded", {
		sustain = 0.1,
		engine = "both",
		release = 0.1,
		cumulative = true,
		attack = 0.05,
		peak = 0.7
	})
end

CoreClass.override_class(CoreRumbleManager.RumbleManager, RumbleManager)
