core:module("CorePointPicker")
core:import("CoreClass")
core:import("CoreEvent")
core:import("CoreDebug")

PointPicker = PointPicker or CoreClass.mixin(CoreClass.class(), CoreEvent.BasicEventHandling)

function PointPicker:init(viewport, slotmask)
	self.__viewport = viewport
	self.__enabled = false
	self.__slotmask = slotmask or World:make_slot_mask(1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 22, 23, 24, 26, 27, 30, 34, 37, 38, 39)
end

function PointPicker:update(time, delta_time)
	if self.__enabled then
		local camera = self.__viewport:camera()
		local start_position = managers.editor:cursor_pos():with_z(camera:near_range())
		local end_position = start_position:with_z(camera:far_range())
		local ray_start = camera:screen_to_world(start_position)
		local ray_end = camera:screen_to_world(end_position)
		local raycast = World:raycast("ray", ray_start, ray_end, "slot_mask", self.__slotmask)
		local mouse_event = EWS:MouseEvent("EVT_MOTION")

		if mouse_event then
			if mouse_event:left_is_down() then
				self:_mouse_left_down(raycast)
			else
				self:_mouse_moved(raycast)
			end
		end
	end
end

function PointPicker:start_picking()
	self.__enabled = true
end

function PointPicker:stop_picking()
	self.__enabled = false
end

function PointPicker:_mouse_moved(raycast)
	self:_send_event("EVT_PICKING", raycast)
end

function PointPicker:_mouse_left_down(raycast)
	self:_send_event("EVT_FINISHED_PICKING", raycast)
	self:stop_picking()
end
