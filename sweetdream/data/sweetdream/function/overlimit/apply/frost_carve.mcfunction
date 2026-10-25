# ============================================================
# sweetdream:overlimit/apply/frost_carve —— 右键用掉超限石去敲副手那件「剜霜」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:overlimit/frost_carve(consume_item), 以玩家身份
# 【流程】①撤销进度 ②交给 station/api/apply(kind=overlimit, of=frost_carve)
#         ③成功 = 消耗成立; 失败 = 退材料 + 说明原因
# 【of 是什么】这块石头"属于哪件装备" —— overlimit/api/fit 会拿它去比对
#   副手的 zx(必须含 frost_carve), 并且确认这件还没敲过 ol。
# 【批 J4 / 2026-10-23】axe 类。定义(名字 + 整段 lore)见
#   overlimit/def/load 的批 J3 段; 三个乘区目前全 0 —— 超限是"换机制",
#   数值不从这里加。机制本体(各件自己的 ol 钩子)另起一批。
# ============================================================

advancement revoke @s only sweetdream:overlimit/frost_carve

data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"frost_carve"}
function sweetdream:station/api/apply

execute if data storage zx:out r{ok:1b} run tellraw @s [{"text":"✔ 剜霜已超限","color":"green"}]
execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/item/frost_carve
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/api/refuse
