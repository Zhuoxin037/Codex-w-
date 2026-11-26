function fallendream:equipment/sword/contract_rift/mark_follow with entity @s data
execute unless entity @s[tag=zx.cr_mark] run return 0
execute unless score @s zx.cr_until > #now manacore.meta run function fallendream:equipment/sword/contract_rift/restore with entity @s data
