# ============================================================
# fallendream:equipment/armor/fade/go —— 息影·兑现（10 秒没再放技能）
# ------------------------------------------------------------
# 【执行者】玩家(刚满"10 秒没再放技能")
# 【技能原文】
#   基础: "…则使当前手持装备冷却时间 -10 秒且自身恢复 50 魔力值。"
#   超限: "…则使当前手持装备冷却时间减半（至少减少 10 秒）且自身恢复 5% 魔力值。"
# 【口径】
#   · "当前手持装备" = 主手那件自带 custom_data.skill 的装备。主手没有 skill 就只回魔。
#   · 只对**正在冷却**的技能生效(api/cooldown/reduce 的口径)。
# 【★ 两档分开 ★】基础与超限的减冷却/回魔数值都不同，各写一个叶子，不共用半成品参数。
# 【★ 先 uuid 后写公共输入口 ★】所有 api 都要 manacore:in arg.uuid。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 档位快照（同一函数内不会换装，用假玩家即可）
scoreboard players set #fd_ol zx.meta 0
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["fade"],ol:"fade"}] run scoreboard players set #fd_ol zx.meta 1

# ① 当前手持装备冷却：基础 -10 秒 / 超限 减半（至少 -10 秒）
execute if score #fd_ol zx.meta matches 0 if data entity @s SelectedItem.components."minecraft:custom_data".skill run function fallendream:equipment/armor/fade/cd_reduce
execute if score #fd_ol zx.meta matches 1 if data entity @s SelectedItem.components."minecraft:custom_data".skill run function fallendream:equipment/armor/fade/cd_half

# ② 回魔：基础固定 50 / 超限 5% 最大魔力值
execute if score #fd_ol zx.meta matches 0 run data modify storage manacore:in arg set value {uuid:"",value:50.0}
execute if score #fd_ol zx.meta matches 0 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #fd_ol zx.meta matches 0 run function manacore:api/mana/add
execute if score #fd_ol zx.meta matches 1 run function fallendream:equipment/armor/fade/ol_mana

# ③ 一点反馈(看得见才好测)
execute at @s run particle minecraft:reverse_portal ~ ~1 ~ 0.35 0.5 0.35 0.02 18 normal
execute at @s run playsound minecraft:entity.allay.item_thrown player @s ~ ~ ~ 0.5 1.2
