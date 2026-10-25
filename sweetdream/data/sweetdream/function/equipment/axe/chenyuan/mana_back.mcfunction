# ============================================================
# sweetdream:equipment/axe/chenyuan/mana_back —— 已附带渊海 -> 自身恢复魔力
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】常态: 恢复 70 魔力
#         超限: 恢复 80 魔力, 并追加"下一个最大魔力技能 +10%(不可叠加)"
# 【★ 这里必须判物品、不能读 zx:work cy.ol ★】这条链是平A触发的
#   (hit -> hit_go -> mana_branch -> 这里), 前面根本没有 cast, 那个键不存在。
# ============================================================

scoreboard players set #cy_ol zx.meta 0
execute if items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["chenyuan"],ol:"chenyuan"}] run scoreboard players set #cy_ol zx.meta 1
execute if items entity @s weapon.offhand diamond_axe[custom_data~{zx:["chenyuan"],ol:"chenyuan"}] run scoreboard players set #cy_ol zx.meta 1

data modify storage manacore:in arg set value {uuid:"",value:70.0}
execute if score #cy_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 80.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# 超限: 挂"下一个最大魔力技能 +10%" —— 用 set 不是 add(文案"不可叠加")
execute if score #cy_ol zx.meta matches 1 run scoreboard players set @s zx.cy_mmn 1
# 【不要加 tellraw】玩家 2026-10-04 明确反馈"连打会刷屏" -> 这里只给音效反馈
#   (超限那一支换个音高, 听得出来但不会刷屏)。
execute at @s run playsound minecraft:block.conduit.activate player @a ~ ~ ~ 0.6 1.5
execute if score #cy_ol zx.meta matches 1 at @s run playsound minecraft:block.conduit.activate player @a ~ ~ ~ 0.4 1.9
