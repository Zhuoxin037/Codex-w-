# ============================================================
# sweetdream:overlimit/apply/myriad —— 右键用掉超限石去敲副手那件「万念」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:overlimit/myriad(consume_item), 以玩家身份
# 【流程】①撤销进度 ②交给 station/api/apply(kind=overlimit, of=myriad)
#         ③成功 = 消耗成立; 失败 = 退材料 + 说明原因
# 【of 是什么】这块石头"属于哪件装备" —— overlimit/api/fit 会拿它去比对
#   副手的 zx(必须含 myriad), 并且确认这件还没敲过 ol。
# ============================================================

advancement revoke @s only sweetdream:overlimit/myriad

data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"myriad"}
function sweetdream:station/api/apply

execute if data storage zx:out r{ok:1b} run tellraw @s [{"text":"✔ 万念已超限","color":"green"}]
execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/item/myriad
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/api/refuse
