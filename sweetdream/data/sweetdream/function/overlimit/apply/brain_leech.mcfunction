# ============================================================
# sweetdream:overlimit/apply/brain_leech —— 右键用掉超限石去敲副手的「脑髓蛭」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:overlimit/brain_leech(consume_item), 以玩家身份
# 【流程】①撤销进度 ②交给 station/api/apply(kind=overlimit, of=brain_leech)
#         ③成功 = 消耗成立; 失败 = 退材料 + 说明原因
# 【of 是什么】这块石头"属于哪件装备" —— overlimit/api/fit 会拿它去比对
#   副手那件的 zx(必须含 brain_leech), 并且确认它还没敲过 ol。
# 【与武器的差别】脑髓蛭/脊骨共生是**盔甲**, 超限乘区(dmg/mana/cd)全 0 ——
#   换名字 + 整段换描述 + 效果由装备自己的 second/kill/attack 读 ol 分流。
# ============================================================

advancement revoke @s only sweetdream:overlimit/brain_leech

data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"brain_leech"}
function sweetdream:station/api/apply

execute if data storage zx:out r{ok:1b} run tellraw @s [{"text":"✔ 脑髓蛭已超限","color":"green"}]
execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/item/brain_leech
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/api/refuse
