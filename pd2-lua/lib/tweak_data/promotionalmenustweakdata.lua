PromotionalMenusTweakData = PromotionalMenusTweakData or class()

function PromotionalMenusTweakData:init(tweak_data)
	self.menus = {}
	self.themes = {}

	self:_init_raid(tweak_data)
end

function PromotionalMenusTweakData:_init_raid(tweak_data)
	self.menus.raid = {
		size = 0.8,
		padding = 5,
		layout = {
			x = 4,
			y = 6
		},
		buttons = {
			{
				type = "RaidPromotionalMenuButton",
				callback = "launch_raid",
				position = {
					1,
					1
				},
				size = {
					3,
					2
				},
				title = {
					name_id = "menu_raid_beta_play",
					font = "large",
					font_size = "large",
					color = Color(1, 0, 0, 0)
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/play_raid_header_df"
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "open_raid_preorder_menu",
				position = {
					4,
					1
				},
				size = {
					1,
					2
				},
				title = {
					name_id = "menu_raid_preorder",
					font = "medium",
					font_size = "medium"
				},
				subtitle = {
					name_id = "menu_raid_preorder_desc",
					font = "small",
					font_size = "small",
					color = Color(1, 0, 0, 0)
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/preorder"
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "open_raid_weapons_menu",
				position = {
					1,
					3
				},
				size = {
					2,
					2
				},
				title = {
					name_id = "menu_raid_beta_weapons",
					font = "medium",
					font_size = "medium"
				},
				subtitle = {
					name_id = "menu_raid_beta_weapons_desc",
					font = "small",
					font_size = "small"
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/pd2_weaponpack_df"
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "open_raid_trailer",
				position = {
					3,
					3
				},
				size = {
					1,
					2
				},
				title = {
					name_id = "menu_raid_cinematic_trailer",
					font = "medium",
					font_size = "medium"
				},
				subtitle = {
					name_id = "menu_raid_cinematic_trailer_desc",
					font = "small",
					font_size = "small"
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/cinematic_trailer_df"
				},
				overlay = {
					w = 102.4,
					image = "guis/dlcs/aru/textures/pd2/play_button",
					h = 102.4,
					center = {
						0.5,
						0.35
					}
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "open_dev_diary_trailer",
				position = {
					4,
					3
				},
				size = {
					1,
					2
				},
				title = {
					name_id = "menu_raid_dev_diary",
					font = "medium",
					font_size = "medium"
				},
				subtitle = {
					name_id = "menu_raid_dev_diary_desc",
					font = "small",
					font_size = "small"
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/dev_diary"
				},
				overlay = {
					w = 102.4,
					image = "guis/dlcs/aru/textures/pd2/play_button",
					h = 102.4,
					center = {
						0.5,
						0.35
					}
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "open_raid_gang",
				position = {
					1,
					5
				},
				size = {
					2,
					1
				},
				title = {
					name_id = "menu_raid_meet_gang",
					font = "medium",
					font_size = "medium"
				},
				subtitle = {
					name_id = "menu_raid_meet_gang_desc",
					font = "small",
					font_size = "small"
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/meet_the_gang"
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "open_raid_feedback",
				position = {
					1,
					6
				},
				size = {
					2,
					1
				},
				title = {
					name_id = "menu_raid_feedback",
					font = "medium",
					font_size = "medium"
				},
				subtitle = {
					name_id = "menu_raid_feedback_desc",
					font = "small",
					font_size = "small"
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/feedback"
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "open_gameplay_trailer",
				position = {
					3,
					5
				},
				size = {
					1,
					2
				},
				title = {
					name_id = "menu_raid_gameplay_trailer",
					font = "medium",
					font_size = "medium"
				},
				subtitle = {
					name_id = "menu_raid_gameplay_trailer_desc",
					font = "small",
					font_size = "small"
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/gameplay_trailer"
				},
				overlay = {
					w = 102.4,
					image = "guis/dlcs/aru/textures/pd2/play_button",
					h = 102.4,
					center = {
						0.5,
						0.35
					}
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "open_raid_special_edition_menu",
				position = {
					4,
					5
				},
				size = {
					1,
					1
				},
				title = {
					name_id = "menu_raid_special_edition",
					font = "medium",
					font_size = "medium"
				},
				subtitle = {
					name_id = "menu_raid_special_edition_desc",
					font = "small",
					font_size = "small"
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/special_edition"
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "open_raid_twitch",
				position = {
					4,
					6
				},
				size = {
					1,
					1
				},
				title = {
					name_id = "menu_raid_twitch",
					font = "medium",
					font_size = "medium"
				},
				subtitle = {
					name_id = "menu_raid_twitch_desc",
					font = "small",
					font_size = "small"
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/twitch"
				},
				overlay = {
					w = 64,
					image = "guis/dlcs/aru/textures/pd2/twitch_overlay",
					h = 64,
					align = {
						"right",
						"top"
					}
				}
			}
		}
	}
	self.menus.raid_weapons = {
		size = 0.8,
		layout = {
			x = 12,
			y = 11
		},
		buttons = {
			{
				type = "PromotionalMenuSeperatorRaid",
				position = {
					1,
					1
				},
				size = {
					12,
					1
				},
				title = {
					name_id = "bm_menu_primaries",
					font = "medium",
					vertical = "bottom",
					font_size = "medium",
					align = "left"
				},
				background = {
					color = true,
					blend_mode = "normal"
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "preview_ching",
				position = {
					1,
					2
				},
				size = {
					12,
					3
				},
				title = {
					name_id = "bm_w_ching",
					font = "large",
					vertical = "bottom",
					font_size = "large",
					align = "left",
					color = Color(1, 1, 1, 1)
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/weapon_ching"
				}
			},
			{
				type = "PromotionalMenuSeperatorRaid",
				position = {
					1,
					5
				},
				size = {
					8,
					1
				},
				title = {
					name_id = "bm_menu_secondaries",
					font = "medium",
					vertical = "bottom",
					font_size = "medium",
					align = "left"
				},
				background = {
					color = true,
					blend_mode = "normal"
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "preview_erma",
				position = {
					1,
					6
				},
				size = {
					8,
					3
				},
				title = {
					name_id = "bm_w_erma",
					font = "medium",
					vertical = "bottom",
					font_size = "medium",
					align = "left",
					color = Color(1, 1, 1, 1)
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/weapon_erma"
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "preview_breech",
				position = {
					1,
					9
				},
				size = {
					8,
					3
				},
				title = {
					name_id = "bm_w_breech",
					font = "medium",
					vertical = "bottom",
					font_size = "medium",
					align = "left",
					color = Color(1, 1, 1, 1)
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/weapon_breech"
				}
			},
			{
				type = "PromotionalMenuSeperatorRaid",
				position = {
					9,
					5
				},
				size = {
					4,
					1
				},
				title = {
					name_id = "bm_menu_melee_weapons",
					font = "medium",
					vertical = "bottom",
					font_size = "medium",
					align = "left"
				},
				background = {
					color = true,
					blend_mode = "normal"
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "preview_push",
				position = {
					9,
					6
				},
				size = {
					4,
					3
				},
				title = {
					name_id = "bm_melee_push",
					font = "medium",
					vertical = "bottom",
					font_size = "medium",
					align = "left",
					color = Color(1, 1, 1, 1)
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/weapon_push"
				}
			},
			{
				type = "RaidPromotionalMenuButton",
				callback = "preview_grip",
				position = {
					9,
					9
				},
				size = {
					4,
					3
				},
				title = {
					name_id = "menu_community_item",
					font = "medium",
					vertical = "bottom",
					font_size = "medium",
					align = "left",
					color = Color(255, 222, 74, 62) / 255
				},
				subtitle = {
					name_id = "bm_melee_grip",
					color = Color(1, 1, 1, 1),
					offset = {
						0,
						6
					}
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/weapon_grip"
				}
			}
		}
	}
	self.menus.raid_special = {
		size = 0.8,
		layout = {
			x = 1,
			y = 1
		},
		buttons = {
			{
				type = "RaidPromotionalMenuFloatingButton",
				callback = "open_raid_special_edition",
				position = {
					1,
					1
				},
				size = {
					1,
					1
				},
				floating_position = {
					400,
					270
				},
				floating_size = {
					128,
					128
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/preorder_now_button"
				}
			},
			{
				type = "PromotionalMenuUnselectableButton",
				zoom_factor = 1,
				can_be_selected = false,
				position = {
					1,
					1
				},
				size = {
					1,
					1
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/preorder_special_edition"
				}
			}
		}
	}
	self.menus.raid_preorder = {
		size = 0.8,
		layout = {
			x = 1,
			y = 1
		},
		buttons = {
			{
				type = "PromotionalMenuUnselectableButton",
				zoom_factor = 1,
				can_be_selected = false,
				position = {
					1,
					1
				},
				size = {
					1,
					1
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/raid_preorder"
				}
			},
			{
				type = "RaidPromotionalMenuFloatingButton",
				callback = "open_raid_preorder",
				position = {
					1,
					1
				},
				size = {
					1,
					1
				},
				floating_position = {
					260,
					350
				},
				floating_size = {
					256,
					64
				},
				background = {
					image = "guis/dlcs/aru/textures/pd2/raid_preorder_button"
				}
			}
		}
	}
	self.themes.payday = {
		selection_corners = Color.white,
		selection_outline = Color.white,
		background_unselected = Color(40, 0, 170, 255) / 255,
		background_selected = Color(80, 77, 198, 255) / 255,
		font = {
			small = tweak_data.menu.pd2_small_font,
			medium = tweak_data.menu.pd2_medium_font,
			large = tweak_data.menu.pd2_large_font,
			massive = tweak_data.menu.pd2_massive_font
		},
		font_size = {
			small = tweak_data.menu.pd2_small_font_size,
			medium = tweak_data.menu.pd2_medium_font_size,
			large = tweak_data.menu.pd2_large_font_size,
			massive = tweak_data.menu.pd2_massive_font_size
		}
	}
	self.themes.raid = {
		backgrounds = {
			{
				video = "movies/raid_anim_bg",
				blend_mode = "normal",
				type = "video",
				color = Color(1, 1, 1, 1)
			},
			{
				blend_mode = "add",
				h = 727.04,
				type = "image",
				w = 1454.08,
				image = "guis/dlcs/aru/textures/pd2/main_bg_img"
			},
			{
				y = 300,
				h = 204.8,
				type = "image",
				w = 409.6,
				image = "guis/dlcs/aru/textures/pd2/raid_logo",
				x = 140
			},
			{
				y = 480,
				h = 102.4,
				type = "image",
				w = 409.6,
				image = "guis/dlcs/aru/textures/pd2/beta_logo",
				x = 140
			}
		},
		selection_corners = Color(255, 222, 74, 62) / 255,
		selection_outline = Color(255, 222, 74, 62) / 255,
		selection_outline_sides = {
			sides = {
				2,
				2,
				2,
				2
			}
		},
		background_unselected = Color(100, 43, 48, 55) / 255,
		background_selected = Color(200, 59, 64, 68) / 255,
		title = Color(255, 222, 74, 62) / 255,
		subtitle = Color(1, 1, 1, 1),
		font = {
			small = tweak_data.menu.pd2_small_font,
			medium = tweak_data.menu.pd2_medium_font,
			large = tweak_data.menu.pd2_large_font,
			massive = tweak_data.menu.pd2_massive_font
		},
		font_size = {
			small = tweak_data.menu.pd2_small_font_size * 0.7,
			medium = tweak_data.menu.pd2_medium_font_size * 0.7,
			large = tweak_data.menu.pd2_large_font_size,
			massive = tweak_data.menu.pd2_massive_font_size
		}
	}
end
