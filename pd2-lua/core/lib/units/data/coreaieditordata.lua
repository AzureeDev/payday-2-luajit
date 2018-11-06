CoreAiEditorData = CoreAiEditorData or class()

function CoreAiEditorData:init(unit)
	self.visibilty_exlude_filter = {}
	self.visibilty_include_filter = {}
	self.location_id = "location_unknown"
	self.suspicion_mul = 1
	self.detection_mul = 1
end
