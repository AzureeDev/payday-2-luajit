_G.IS_VR = _G.SystemInfo ~= nil and getmetatable(_G.SystemInfo).is_vr ~= nil and SystemInfo:is_vr()

require("core/lib/setups/CoreLoadingSetup")
require("lib/utils/LightLoadingScreenGuiScript")

if _G.IS_VR then
	require("lib/utils/VRLoadingEnvironment")
end

LightLoadingSetup = LightLoadingSetup or class(CoreLoadingSetup)

function LightLoadingSetup:init()
	if _G.IS_VR then
		self:_init_vr_camera()
	end

	self._camera = Scene:create_camera()

	LoadingViewport:set_camera(self._camera)

	self._gui_wrapper = LightLoadingScreenGuiScript:new(Scene:gui(), arg.res, -1, arg.layer, arg.is_win32)

	if _G.IS_VR then
		self._vr_loading_environment = VRLoadingEnvironment:new(arg.vr_overlays)

		self._vr_loading_environment:resume()
	end
end

function LightLoadingSetup:update(t, dt)
	if _G.IS_VR then
		self:_update_vr_camera()
		self._vr_loading_environment:update(t, dt)
	end

	self._gui_wrapper:update(-1, dt)
end

function LightLoadingSetup:destroy()
	LightLoadingSetup.super.destroy(self)
	Scene:delete_camera(self._camera)
end

function LightLoadingSetup:_init_vr_camera()
	local pos, rot = VRManager:hmd_pose()
	self._initial_pose = {
		position = Vector3(pos.x, pos.y, 140)
	}

	VRManager:set_output_scaling(1, 1)
end

function LightLoadingSetup:_update_vr_camera()
	local pos, rot = VRManager:hmd_pose()

	mvector3.subtract(pos, self._initial_pose.position)
	self._camera:set_position(pos)
	self._camera:set_rotation(rot)
end

setup = setup or LightLoadingSetup:new()

setup:make_entrypoint()
