local enum = 0

local function set_enum()
	enum = enum + 1

	return enum
end

Message = {}
Message.OnHeadShot = set_enum()
Message.OnAmmoPickup = set_enum()
Message.OnSwitchWeapon = set_enum()
Message.OnEnemyKilled = set_enum()
Message.EscapeTase = set_enum()
Message.SendTaserMalfunction = set_enum()
Message.OnPlayerDamage = set_enum()
Message.OnPlayerDodge = set_enum()
Message.SetWeaponStagger = set_enum()
Message.OnEnemyShot = set_enum()
Message.OnDoctorBagUsed = set_enum()
Message.OnPlayerReload = set_enum()
Message.RevivePlayer = set_enum()
Message.ResetStagger = set_enum()
Message.CanTradeHostage = set_enum()
Message.OnCashInspectWeapon = set_enum()
Message.OnLethalHeadShot = set_enum()
Message.OnWeaponFired = set_enum()
Message.OnShotgunPush = set_enum()
Message.OnCopDamageDeath = set_enum()
Message.OnLevelUp = set_enum()
Message.OnHeistComplete = set_enum()
Message.OnWeaponBought = set_enum()
Message.OnAchievement = set_enum()
Message.OnSideJobComplete = set_enum()
Message.OnEnterSafeHouse = set_enum()
Message.OnSafeHouseUpgrade = set_enum()
Message.OnDailyGenerated = set_enum()
Message.OnDailyCompleted = set_enum()
Message.OnDailyRewardCollected = set_enum()
Message.OnMissionEnd = set_enum()
Message.OnSafeOpened = set_enum()
Message.OnDaysInRow = set_enum()
Message.OnHighestCrimeSpree = set_enum()

