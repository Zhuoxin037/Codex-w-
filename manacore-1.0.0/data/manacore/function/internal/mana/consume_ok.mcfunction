# ------------------------------------------------------------
# internal/mana\consume_ok —— 扣除成功分支
# 【宏参数】manacore:work.a {uuid}
# 【作用】#cur -= #need 后写回; #cur/#need 由 consume 预先算好。
# ------------------------------------------------------------
scoreboard players operation #cur manacore.math -= #need manacore.math
# 【上限夹取(2026-10-08)】正常扣蓝只会减少, 不会超上限; 但同一个入口也吃**负 value**
#   (debug/recover_mana 就是这么回蓝的, 注释还写着"最后会被夹回 max") —— 负值 = 加蓝,
#   会把当前魔力顶到 max 之上(100/100 -> 1100), 直到下一次每秒回魔才夹回来。
#   这期间 check_mana 报警 / 魔力百分比 >100% / 一切 other_base 通道的基数被抬高。
#   这里顺手夹一下(读不到 max_mana 就跳过; 正常情况 #cur <= #max, 那两行是空操作)。
scoreboard players set #cap manacore.math 0
$execute store result score #cap manacore.math run data get storage manacore:players "$(uuid)".stats.max_mana 1000
execute if score #cap manacore.math matches 1.. if score #cur manacore.math > #cap manacore.math run scoreboard players operation #cur manacore.math = #cap manacore.math
$execute store result storage manacore:players "$(uuid)".stats.current_mana double 0.001 run scoreboard players get #cur manacore.math
data modify storage manacore:out r.success set value 1b
data modify storage manacore:out r.reason set value "ok"
