# ============================================================
# sweetdream:equipment/staff/stop_needle/cd —— 停住 N 个 = 全部包内技能冷却 -2N 秒
# ------------------------------------------------------------
# 只由至少 3 个目标的时停分支调用；最多 5 个，即最多减少 10 秒。
# ============================================================
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
execute unless score #sn_n zx.meta matches 3..5 run return 0
data modify storage manacore:in arg set value {uuid:"",skill:"",seconds:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.seconds double 2.0 run scoreboard players get #sn_n zx.meta
function sweetdream:equipment/staff/stop_needle/cd_all

execute at @s run particle minecraft:dust{color:[0.4,0.8,0.9],scale:0.9} ~ ~1 ~ 0.5 0.6 0.5 0.01 10 normal
