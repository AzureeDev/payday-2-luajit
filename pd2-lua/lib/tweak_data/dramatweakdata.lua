DramaTweakData = DramaTweakData or class()

function DramaTweakData:init()
	self:_create_table_structure()

	self.drama_actions = {
		criminal_hurt = 0.5,
		criminal_dead = 0.2,
		criminal_disabled = 0.1
	}
	self.decay_period = 30
	self.max_dis = 6000
	self.max_dis_mul = 0.5
	self.low = 0.1
	self.peak = 0.95
	self.assault_fade_end = 0.25
end

function DramaTweakData:_create_table_structure()
end
