WeaponColorTemplates = WeaponColorTemplates or class()

function WeaponColorTemplates.setup_weapon_color_templates(tweak_data)
	local weapon_color_templates = {
		color_variation = WeaponColorTemplates._setup_color_variation_template(tweak_data),
		color_skin = WeaponColorTemplates._setup_color_skin_template(tweak_data)
	}

	return weapon_color_templates
end

function WeaponColorTemplates._setup_color_variation_template(tweak_data)
	local weapon_color_variation_template = {
		{
			base_foregrip = "base_metal",
			base_sights = "base_variation",
			base_vertical_grip = "base_variation",
			base_default = "base_default",
			base_stock = "base_variation",
			base_gadget = "base_variation",
			base_grip = "base_variation",
			base_magazine = "base_variation"
		},
		{
			base_sights = "base_variation",
			base_barrel = "base_variation",
			base_barrel_ext = "base_variation",
			base_default = "base_default",
			base_slide = "base_variation",
			base_gadget = "base_variation",
			base_grip = "base_variation",
			base_magazine = "base_variation"
		},
		{
			base_sights = "base_variation",
			base_gadget = "base_variation",
			base_magazine = "base_variation",
			base_default = "base_metal"
		},
		{
			base_sights = "base_variation",
			base_gadget = "base_variation",
			base_magazine = "base_variation",
			base_default = "base_plastic"
		},
		{
			base_sights = "base_variation",
			base_gadget = "base_variation",
			base_magazine = "base_variation",
			base_default = "base_half"
		},
		{
			base_sights = "base_variation",
			base_barrel_ext = "base_variation",
			base_default = "base_half_02",
			base_gadget = "base_variation",
			base_magazine = "base_variation"
		}
	}

	return weapon_color_variation_template
end

function WeaponColorTemplates._setup_color_skin_template(tweak_data)
	local weapon_color_skin_template = {
		base_gradient = "base_default",
		weapons = {},
		types = {},
		parts = {}
	}
	local types = weapon_color_skin_template.types
	types.sight = {
		base_gradient = "base_sights"
	}
	types.magazine = {
		base_gradient = "base_magazine"
	}
	types.grip = {
		base_gradient = "base_grip"
	}
	types.foregrip = {
		base_gradient = "base_foregrip"
	}
	types.vertical_grip = {
		base_gradient = "base_vertical_grip"
	}
	types.stock = {
		base_gradient = "base_stock"
	}
	types.gadget = {
		base_gradient = "base_gadget"
	}
	types.barrel = {
		base_gradient = "base_barrel"
	}
	types.barrel_ext = {
		base_gradient = "base_barrel_ext"
	}
	types.slide = {
		base_gradient = "base_slide"
	}

	return weapon_color_skin_template
end
