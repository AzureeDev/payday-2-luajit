_G.IS_VR = _G.SystemInfo ~= nil and getmetatable(_G.SystemInfo).is_vr ~= nil and SystemInfo:is_vr()

require("core/lib/setups/CoreLoadingSetup")
require("lib/utils/LevelLoadingScreenGuiScript")
require("lib/managers/menu/MenuBackdropGUI")
require("core/lib/managers/CoreGuiDataManager")
require("core/lib/utils/CoreMath")
require("core/lib/utils/CoreEvent")

if _G.IS_VR then
	require("lib/utils/VRLoadingEnvironment")
end

function fake_inspect(val)
	if val == nil or type(val) ~= "table" then
		return tostring(val)
	end

	local rtn = "---\n"

	for k, v in pairs(val) do
		rtn = rtn .. "| " .. tostring(k) .. " = " .. tostring(v) .. "\n"
	end

	rtn = rtn .. "---\n"

	return rtn
end

LevelLoadingSetup = LevelLoadingSetup or class(CoreLoadingSetup)

function LevelLoadingSetup:init()
	if _G.IS_VR then
		self:_init_vr_camera()
	end

	self._camera = Scene:create_camera()

	LoadingViewport:set_camera(self._camera)
	print("LevelLoadingSetup:init")
	print(fake_inspect(arg.load_level_data))

	self._gui_wrapper = LevelLoadingScreenGuiScript:new(Scene:gui(), arg.res, -1, arg.layer)

	if _G.IS_VR then
		self._vr_loading_environment = VRLoadingEnvironment:new(arg.vr_overlays)

		self._vr_loading_environment:resume()
	end
end

function LevelLoadingSetup:update(t, dt)
	if _G.IS_VR then
		self:_update_vr_camera()
		self._vr_loading_environment:update(t, dt)
	end

	self._gui_wrapper:update(-1, t, dt)
end

function LevelLoadingSetup:destroy()
	LevelLoadingSetup.super.destroy(self)
	Scene:delete_camera(self._camera)
end

function LevelLoadingSetup:_init_vr_camera()
	local pos, rot = VRManager:hmd_pose()
	self._initial_pose = {
		position = Vector3(pos.x, pos.y, 140)
	}

	VRManager:set_output_scaling(1, 1)
end

function LevelLoadingSetup:_update_vr_camera()
	local pos, rot = VRManager:hmd_pose()

	mvector3.subtract(pos, self._initial_pose.position)
	self._camera:set_position(pos)
	self._camera:set_rotation(rot)
end

setup = setup or LevelLoadingSetup:new()

setup:make_entrypoint()
