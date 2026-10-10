# ============================================================
# sweetdream:overlimit/apply/dream_reader —— 右键用掉超限石去敲副手那件「释梦」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:overlimit/dream_reader(consume_item), 以玩家身份
# 【流程】①撤销进度 ②交给 station/api/apply(kind=overlimit, of=dream_reader)
#         ③成功 = 消耗成立; 失败 = 退材料 + 说明原因
# 【of 是什么】这块石头"属于哪件装备" —— overlimit/api/fit 会拿它去比对
#   副手的 zx(必须含 dream_reader), 并且确认这件还没敲过 ol。
# 【★ 敲完之后靠什么生效 ★】station/api/apply 把 `ol:"dream_reader"` 写进副手那件
#   释梦的 custom_data; 之后:
#   · 平A 被动由 hit ③' 读它决定"用 5× 还是 基础攻击力×0.5";
#   · 主动由 cast ⑤ 读它决定"入梦体伤害 ×0.1 还是 ×0.12", 并随 `zx:work drp.ol`
#     传进每个入梦体的 NBT / tag `zx.dr_ol`(入梦体侧全靠这个 tag 分支)。
#   已给出去的旧斧不会自己变 —— 要重新 give 或重新敲。
# ============================================================

advancement revoke @s only sweetdream:overlimit/dream_reader

data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"dream_reader"}
function sweetdream:station/api/apply

execute if data storage zx:out r{ok:1b} run tellraw @s [{"text":"✔ 释梦已超限","color":"green"}]
execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/item/dream_reader
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/api/refuse
