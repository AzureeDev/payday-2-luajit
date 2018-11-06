core:module("CoreFakeSession")
core:import("CoreSession")

Session = Session or class()

function Session:init()
end

function Session:delete_session()
	cat_print("debug", "FakeSession: delete_session")
end

function Session:start_session()
	cat_print("debug", "FakeSession: start_session")
end

function Session:end_session()
	cat_print("debug", "FakeSession: end_session")
end

function Session:join_local_user(local_user)
	cat_print("debug", "FakeSession: Local user:'" .. local_user:gamer_name() .. "' joined!")
end

function Session:join_remote_user(remote_user)
	cat_print("debug", "FakeSession: Remote user:'" .. remote_user:gamer_name() .. "' joined!")
end
