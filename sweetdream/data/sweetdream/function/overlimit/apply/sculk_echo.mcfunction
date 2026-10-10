# ============================================================
# sweetdream:overlimit/apply/sculk_echo —— 右键用掉超限石去敲副手那件「幽匿残响」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:overlimit/sculk_echo(consume_item), 以玩家身份
# 【流程】①撤销进度 ②交给 station/api/apply(kind=overlimit, of=sculk_echo)
#         ③成功 = 消耗成立; 失败 = 退材料 + 说明原因
# 【of 是什么】这块石头"属于哪件装备" —— overlimit/api/fit 会拿它去比对
#   副手的 zx(必须含 sculk_echo), 并且确认这件还没敲过 ol。
# 【★ 敲完之后靠什么生效 ★】station/api/apply 把 `ol:"sculk_echo"` 写进副手那件
#   幽匿残响的 custom_data; 之后每次射击由 shot ①' 读它决定"这一发走不走超限数值"。
#   已给出去的旧弩不会自己变 —— 要重新 give 或重新敲。
# ============================================================

advancement revoke @s only sweetdream:overlimit/sculk_echo

data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"sculk_echo"}
function sweetdream:station/api/apply

execute if data storage zx:out r{ok:1b} run tellraw @s [{"text":"✔ 幽匿残响已超限","color":"green"}]
execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/item/sculk_echo
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/api/refuse
