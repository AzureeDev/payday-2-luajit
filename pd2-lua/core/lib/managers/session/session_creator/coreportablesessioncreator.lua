core:module("CorePortableSessionCreator")
core:import("CoreFakeSessionCreator")

if SystemInfo:platform() == Idstring("X360") then
	Creator = CoreFakeSessionCreator.Creator
elseif SystemInfo:platform() == Idstring("WIN32") then
	Creator = CoreFakeSessionCreator.Creator
elseif SystemInfo:platform() == Idstring("PS3") then
	Creator = CoreFakeSessionCreator.Creator
elseif SystemInfo:platform() == Idstring("XB1") then
	Creator = CoreFakeSessionCreator.Creator
elseif SystemInfo:platform() == Idstring("PS4") then
	Creator = CoreFakeSessionCreator.Creator
end
