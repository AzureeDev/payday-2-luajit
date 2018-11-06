core:import("CoreOverlayEffectManager")

OverlayEffectManager = OverlayEffectManager or class(CoreOverlayEffectManager.OverlayEffectManager)
OverlayEffectManager.CAMERA_HEIGHT = 140

function OverlayEffectManager:init()
	OverlayEffectManager.super.init(self)

	if _G.IS_VR then
		self._ws:set_pinned_screen(true)
		self:reset_hmd_orientation()

		self._enable_hmd_tracking = true
	end

	for name, setting in pairs(tweak_data.overlay_effects) do
		self:add_preset(name, setting)
	end
end

local zero_rotation = Rotation(0, 0, 0)
local zero_vector3 = Vector3(0, 0, 0)

function OverlayEffectManager:reset_hmd_orientation()
	local pos, rot = VRManager:hmd_pose()
	self._hmd_position = pos

	mvector3.set_z(self._hmd_position, OverlayEffectManager.CAMERA_HEIGHT)

	self._hmd_rotation = Rotation:yaw_pitch_roll(rot:yaw(), 0, 0):inverse()
end

function OverlayEffectManager:update(t, dt)
	if _G.IS_VR then
		if self._enable_hmd_tracking then
			local pos, rot = VRManager:hmd_pose()

			mvector3.subtract(pos, self._hmd_position)
			self._overlay_camera:set_position(pos)
			self._overlay_camera:set_rotation(rot)
		else
			self._overlay_camera:set_position(zero_vector3)
			self._overlay_camera:set_rotation(zero_rotation)
		end
	end

	OverlayEffectManager.super.update(self, t, dt)
end

function OverlayEffectManager:paused_update(t, dt)
	if _G.IS_VR then
		self._overlay_camera:set_position(zero_vector3)
		self._overlay_camera:set_rotation(zero_rotation)
	end

	OverlayEffectManager.super.paused_update(self, t, dt)
end

function OverlayEffectManager:set_hmd_tracking(tracking)
	self._enable_hmd_tracking = tracking

	self:reset_hmd_orientation()
end

function OverlayEffectManager:viewport()
	return self._vp_overlay
end

CoreClass.override_class(CoreOverlayEffectManager.OverlayEffectManager, OverlayEffectManager)
