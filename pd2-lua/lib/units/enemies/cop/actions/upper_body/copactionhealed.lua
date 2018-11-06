CopActionHealed = CopActionHealed or class()
local tmp_vec1 = Vector3()

function CopActionHealed:init(action_desc, common_data)
	self._common_data = common_data
	self._ext_movement = common_data.ext_movement
	self._ext_inventory = common_data.ext_inventory
	self._ext_anim = common_data.ext_anim
	self._body_part = action_desc.body_part
	self._unit = common_data.unit
	self._machine = common_data.machine
	self._attention = common_data.attention
	self._action_desc = action_desc

	if not self._unit:base():char_tweak().ignore_medic_revive_animation then
		self._ext_movement:play_redirect("use_syringe")
	end

	self._unit:sound():say("hr01")

	self._healed = false

	if self._unit:contour() then
		self._unit:contour():add("medic_heal", true)
		self._unit:contour():flash("medic_heal", 0.2)
	end

	return true
end

function CopActionHealed:on_exit()
end

function CopActionHealed:update(t)
	if not self._unit:anim_data().heal then
		self._healed = true

		self._ext_movement:play_redirect("idle")
		self._ext_movement:action_request({
			body_part = 2,
			type = "idle"
		})
	end
end

function CopActionHealed:type()
	return "healed"
end

function CopActionHealed:expired()
	return self._expired
end

function CopActionHealed:chk_block(action_type, t)
	if action_type == "heavy_hurt" or action_type == "hurt" or action_type == "death" then
		return false
	end

	return not self._healed
end

function CopActionHealed:on_attention(attention)
	self._attention = attention
end

function CopActionHealed:body_part()
	return self._body_part
end

function CopActionHealed:need_upd()
	return true
end

function CopActionHealed:save(save_data)
	for i, k in pairs(self._action_desc) do
		if type_name(k) ~= "Unit" or alive(k) then
			save_data[i] = k
		end
	end
end
