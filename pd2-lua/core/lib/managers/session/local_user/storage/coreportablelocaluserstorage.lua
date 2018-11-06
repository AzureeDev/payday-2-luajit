core:module("CorePortableLocalUserStorage")
core:import("CoreFakeLocalUserStorage")

if SystemInfo:platform() == Idstring("X360") then
	Storage = CoreFakeLocalUserStorage.Storage
elseif SystemInfo:platform() == Idstring("WIN32") then
	Storage = CoreFakeLocalUserStorage.Storage
elseif SystemInfo:platform() == Idstring("PS3") then
	Storage = CoreFakeLocalUserStorage.Storage
elseif SystemInfo:platform() == Idstring("XB1") then
	Storage = CoreFakeLocalUserStorage.Storage
elseif SystemInfo:platform() == Idstring("PS4") then
	Storage = CoreFakeLocalUserStorage.Storage
end
