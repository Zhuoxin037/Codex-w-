# ============================================================
# sweetdream:equipment/sword/crescent/freeze_tick —— 冻结窗: 每刻把剩余冷却顶回原值
# ------------------------------------------------------------
# 【谁调用它】freeze_drive(宏 {uuid})   【执行者】施法者玩家   【位置】他所在处
# 【宏参数】uuid = 施法者 uuid(freeze_drive 已写好)
# 【每刻三件事】
#   ① 窗还开着(zx.cr_t >= 1) -> 名单里每一条正在冷却的技能 api/cooldown/increase 1 tick
#      ⇒ 剩余冷却**原地不动**(= 冻结)。名单来自 zx:freeze p."<uuid>".s0..s8(施法那刻的快照)。
#   ② zx.cr_t -1
#   ③ 归零 -> freeze_end 结算(并清名单)
# 【★ 计时口径 ★】用 core/tick **每刻**扣, 120 刻 = 6 秒(别改成每秒扣 —— 见坑 120)。
# ============================================================

# 每条 increase 都要 uuid, 先写一次(uuid 是字符串, 不会被下面的循环改动)
$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:"",ticks:1}

# 槽 0
data remove storage zx:work cz.s
$execute if data storage zx:freeze p."$(uuid)".s0 run data modify storage zx:work cz.s set from storage zx:freeze p."$(uuid)".s0
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run data modify storage manacore:in arg.skill set from storage zx:work cz.s
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run function manacore:api/cooldown/increase

# 槽 1
data remove storage zx:work cz.s
$execute if data storage zx:freeze p."$(uuid)".s1 run data modify storage zx:work cz.s set from storage zx:freeze p."$(uuid)".s1
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run data modify storage manacore:in arg.skill set from storage zx:work cz.s
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run function manacore:api/cooldown/increase

# 槽 2
data remove storage zx:work cz.s
$execute if data storage zx:freeze p."$(uuid)".s2 run data modify storage zx:work cz.s set from storage zx:freeze p."$(uuid)".s2
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run data modify storage manacore:in arg.skill set from storage zx:work cz.s
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run function manacore:api/cooldown/increase

# 槽 3
data remove storage zx:work cz.s
$execute if data storage zx:freeze p."$(uuid)".s3 run data modify storage zx:work cz.s set from storage zx:freeze p."$(uuid)".s3
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run data modify storage manacore:in arg.skill set from storage zx:work cz.s
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run function manacore:api/cooldown/increase

# 槽 4
data remove storage zx:work cz.s
$execute if data storage zx:freeze p."$(uuid)".s4 run data modify storage zx:work cz.s set from storage zx:freeze p."$(uuid)".s4
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run data modify storage manacore:in arg.skill set from storage zx:work cz.s
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run function manacore:api/cooldown/increase

# 槽 5
data remove storage zx:work cz.s
$execute if data storage zx:freeze p."$(uuid)".s5 run data modify storage zx:work cz.s set from storage zx:freeze p."$(uuid)".s5
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run data modify storage manacore:in arg.skill set from storage zx:work cz.s
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run function manacore:api/cooldown/increase

# 槽 6
data remove storage zx:work cz.s
$execute if data storage zx:freeze p."$(uuid)".s6 run data modify storage zx:work cz.s set from storage zx:freeze p."$(uuid)".s6
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run data modify storage manacore:in arg.skill set from storage zx:work cz.s
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run function manacore:api/cooldown/increase

# 槽 7
data remove storage zx:work cz.s
$execute if data storage zx:freeze p."$(uuid)".s7 run data modify storage zx:work cz.s set from storage zx:freeze p."$(uuid)".s7
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run data modify storage manacore:in arg.skill set from storage zx:work cz.s
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run function manacore:api/cooldown/increase

# 槽 8
data remove storage zx:work cz.s
$execute if data storage zx:freeze p."$(uuid)".s8 run data modify storage zx:work cz.s set from storage zx:freeze p."$(uuid)".s8
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run data modify storage manacore:in arg.skill set from storage zx:work cz.s
execute if score @s zx.cr_t matches 1.. if data storage zx:work cz.s run function manacore:api/cooldown/increase

# ② 窗 -1; ③ 归零 -> 结算
scoreboard players remove @s zx.cr_t 1
$execute if score @s zx.cr_t matches ..0 run function sweetdream:equipment/sword/crescent/freeze_end {uuid:"$(uuid)"}
