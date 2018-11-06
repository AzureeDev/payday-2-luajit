local enum = 0

local function set_enum()
	enum = enum + 1

	return enum
end

Message = {
	OnHeadShot = set_enum(),
	OnAmmoPickup = set_enum(),
	OnSwitchWeapon = set_enum(),
	OnEnemyKilled = set_enum(),
	EscapeTase = set_enum(),
	SendTaserMalfunction = set_enum(),
	OnPlayerDamage = set_enum(),
	OnPlayerDodge = set_enum(),
	SetWeaponStagger = set_enum(),
	OnEnemyShot = set_enum(),
	OnDoctorBagUsed = set_enum(),
	OnPlayerReload = set_enum(),
	RevivePlayer = set_enum(),
	ResetStagger = set_enum(),
	CanTradeHostage = set_enum(),
	OnCashInspectWeapon = set_enum(),
	OnLethalHeadShot = set_enum(),
	OnWeaponFired = set_enum(),
	OnShotgunPush = set_enum(),
	OnCopDamageDeath = set_enum(),
	OnLevelUp = set_enum(),
	OnHeistComplete = set_enum(),
	OnWeaponBought = set_enum(),
	OnAchievement = set_enum(),
	OnSideJobComplete = set_enum(),
	OnEnterSafeHouse = set_enum(),
	OnSafeHouseUpgrade = set_enum(),
	OnDailyGenerated = set_enum(),
	OnDailyCompleted = set_enum(),
	OnDailyRewardCollected = set_enum(),
	OnMissionEnd = set_enum(),
	OnSafeOpened = set_enum(),
	OnDaysInRow = set_enum(),
	OnHighestCrimeSpree = set_enum()
}
