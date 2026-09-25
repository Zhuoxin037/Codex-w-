# ------------------------------------------------------------
# internal/mana\consume_ok —— 扣除成功分支
# 【宏参数】manacore:work.a {uuid}
# 【作用】#cur -= #need 后写回; #cur/#need 由 consume 预先算好。
# ------------------------------------------------------------
scoreboard players operation #cur manacore.math -= #need manacore.math
$execute store result storage manacore:players "$(uuid)".stats.current_mana double 0.001 run scoreboard players get #cur manacore.math
data modify storage manacore:out r.success set value 1b
data modify storage manacore:out r.reason set value "ok"
