core:module("CoreSessionHandler")

Session = Session or class()

function Session:joined_session()
	cat_print("debug", "Joined Session!")
end

function Session:session_ended()
	cat_print("debug", "Session Ended")
end

function Session:session_started()
	cat_print("debug", "Session Started!")
end
