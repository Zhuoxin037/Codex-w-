# ============================================================
# sweetdream:overlimit/apply/liuguang —— 右键用掉超限石去敲副手那把流光
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:overlimit/liuguang(consume_item), 以玩家身份
# 【流程】①撤销进度 ②交给 station/api/apply(kind=overlimit, of=liuguang)
#         ③成功 = 消耗成立; 失败 = 退材料 + 说明原因
# 【of 是什么】这块石头"属于哪把武器" —— overlimit/api/fit 会拿它去比对
#   副手武器的 zx(必须含 liuguang), 并且确认这把还没敲过 ol。
# ============================================================

advancement revoke @s only sweetdream:overlimit/liuguang

data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"liuguang"}
function sweetdream:station/api/apply

execute if data storage zx:out r{ok:1b} run tellraw @s [{"text":"✔ 流光已超限：右键释放「超限·流光」","color":"green"}]
execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/item/liuguang
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/api/refuse
