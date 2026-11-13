$execute unless entity $(vx_uuid) run return 0

# ① 已经有术阵 -> 在术阵内落雷(见 bolt)
execute if score @s zx.tc_on matches 1 run function sweetdream:equipment/axe/thunderclap/bolt
$execute if score @s zx.tc_on matches 1 run tag $(vx_uuid) remove zx.victim
execute if score @s zx.tc_on matches 1 run return 0

# ② 没术阵 + 天煌 >0 -> 扣除 min(魔力,天煌) 点魔力并在被击者处开一个术阵(X 按实际消耗算)
execute if score @s zx.tc_n matches ..0 run return 0
function sweetdream:equipment/axe/thunderclap/open
$tag $(vx_uuid) remove zx.victim
