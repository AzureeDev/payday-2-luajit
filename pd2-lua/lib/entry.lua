require("lib/utils/Version")

local selected_setup = nil
selected_setup = Global.load_level and require("lib/setups/NetworkGameSetup") or Global.load_start_menu and require("lib/setups/MenuSetup") or Application:editor() and require("lib/setups/NetworkGameSetup") or require("lib/setups/MenuSetup")
setup = setup or selected_setup:new()

setup:make_entrypoint()

