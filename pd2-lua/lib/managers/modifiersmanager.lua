require("lib/modifiers/BaseModifier")
require("lib/modifiers/ModifierCivilianAlarm")
require("lib/modifiers/ModifierCloakerKick")
require("lib/modifiers/ModifierEnemyDamage")
require("lib/modifiers/ModifierEnemyHealth")
require("lib/modifiers/ModifierEnemyHealthAndDamage")
require("lib/modifiers/ModifierExplosionImmunity")
require("lib/modifiers/ModifierHeavies")
require("lib/modifiers/ModifierLessConcealment")
require("lib/modifiers/ModifierLessPagers")
require("lib/modifiers/ModifierMoreSpecials")
require("lib/modifiers/ModifierMoreDozers")
require("lib/modifiers/ModifierNoHurtAnims")
require("lib/modifiers/ModifierShieldReflect")
require("lib/modifiers/ModifierSkulldozers")
require("lib/modifiers/ModifierHealSpeed")
require("lib/modifiers/ModifierMoreMedics")
require("lib/modifiers/ModifierAssaultExtender")
require("lib/modifiers/ModifierCloakerArrest")
require("lib/modifiers/ModifierCloakerTearGas")
require("lib/modifiers/ModifierDozerMedic")
require("lib/modifiers/ModifierDozerMinigun")
require("lib/modifiers/ModifierDozerRage")
require("lib/modifiers/ModifierHeavySniper")
require("lib/modifiers/ModifierMedicAdrenaline")
require("lib/modifiers/ModifierMedicDeathwish")
require("lib/modifiers/ModifierMedicRage")
require("lib/modifiers/ModifierShieldPhalanx")
require("lib/modifiers/ModifierTaserOvercharge")
require("lib/modifiers/ModifierEnemyHealthAndDamageByWave")
require("lib/modifiers/boosts/GageModifier")
require("lib/modifiers/boosts/GageModifierMaxHealth")
require("lib/modifiers/boosts/GageModifierMaxArmor")
require("lib/modifiers/boosts/GageModifierMaxStamina")
require("lib/modifiers/boosts/GageModifierMaxAmmo")
require("lib/modifiers/boosts/GageModifierMaxLives")
require("lib/modifiers/boosts/GageModifierMaxBodyBags")
require("lib/modifiers/boosts/GageModifierMaxDeployables")
require("lib/modifiers/boosts/GageModifierMaxThrowables")
require("lib/modifiers/boosts/GageModifierQuickReload")
require("lib/modifiers/boosts/GageModifierQuickSwitch")
require("lib/modifiers/boosts/GageModifierQuickPagers")
require("lib/modifiers/boosts/GageModifierQuickLocks")
require("lib/modifiers/boosts/GageModifierFastCrouching")
require("lib/modifiers/boosts/GageModifierDamageAbsorption")
require("lib/modifiers/boosts/GageModifierExplosionImmunity")
require("lib/modifiers/boosts/GageModifierPassivePanic")
require("lib/modifiers/boosts/GageModifierMeleeInvincibility")
require("lib/modifiers/boosts/GageModifierLifeSteal")

ModifiersManager = ModifiersManager or class()

function ModifiersManager:init()
	self._modifiers = {}
end

function ModifiersManager:add_modifier(modifier, category)
	category = category or "common"
	local category_table = self._modifiers[category] or {}
	self._modifiers[category] = category_table

	table.insert(category_table, modifier)
end

function ModifiersManager:modify_value(id, value, ...)
	for _, category in pairs(self._modifiers) do
		for _, modifier in ipairs(category) do
			if modifier.modify_value then
				local new_value, override = modifier:modify_value(id, value, ...)

				if new_value ~= nil or override then
					value = new_value
				end
			end
		end
	end

	return value
end

function ModifiersManager:run_func(func_name, ...)
	for _, category in pairs(self._modifiers) do
		for _, modifier in ipairs(category) do
			if modifier[func_name] then
				modifier[func_name](modifier, ...)
			end
		end
	end
end
