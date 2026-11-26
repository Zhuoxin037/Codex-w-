# ============================================================
# fallendream:equipment/sword/mana_imbue/skill —— 注魔主动（魔导士）
# ------------------------------------------------------------
# 【原版】魔力 180 · 冷却 30 秒：消耗全部法球，下一次攻击后对被攻击生物
#   额外附加 X 次「最大魔力 ×0.08」的伤害（X = 消耗的法球数）。
# 【超限】魔力 240 · 冷却 30 秒，并且补上文案后半段：
#   · 打完 X 次之后，对被攻击生物 2 格内的**其他**生物造成同一份的 80%
#     （落在 profession/delayed/hit 里，由 jdelay.im_aoe 分派）
#   · 结束后恢复「自身所造成的总伤害 ×10%」的魔力值，并获得两个法球
#     （落在本文件末尾预算 + second 到期兑现）
# 【★ 为什么总伤害是"预算"而不是"实收"★】
#   delayed 的每次伤害都是同一个固定值（施法时就 calc 好写进 jdelay.num），
#   实际收多少还会被目标的抗性/减伤削。文案说的"自身所造成的总伤害"在这套
#   实现里最贴近、也最可复现的口径就是 X × 单次。若按实收累加，需要每次
#   delayed 回写玩家账本、再判"最后一次"，多一份跨刻状态却不改数值语义。
# 【★ 兑现时刻为什么放到 second ★】
#   delayed 只会在最后一次打完时 kill 掉 marker，没有收尾钩子。X 最大到 5，
#   全程 50 刻；用 zx.mi_end 记到期刻、由 second 每秒查一次，误差 ≤20 刻。
# ============================================================

execute unless score @s zx.job matches 1 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 1 run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 超限判定（主手 / 副手都算）
scoreboard players set #im_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["mana_imbue"],ol:"mana_imbue"}] run scoreboard players set #im_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["mana_imbue"],ol:"mana_imbue"}] run scoreboard players set #im_ol zx.meta 1

# 魔力需求：原版 180 / 超限 240
scoreboard players set #im_cost zx.meta 180
execute if score #im_ol zx.meta matches 1 run scoreboard players set #im_cost zx.meta 240

data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:mana_imbue",mana:180.0}
execute store result storage manacore:in arg.mana double 1 run scoreboard players get #im_cost zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:180.0}
execute store result storage manacore:in arg.value double 1 run scoreboard players get #im_cost zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:mana_imbue",cooldown_seconds:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# 消耗全部法球，X 记进 zx.j_im_n（口径与原版一致：只清 zx.j_orb）
scoreboard players operation @s zx.j_im_n = @s zx.j_orb
function fallendream:equipment/armor/eagle_hat/orb_before
scoreboard players set @s zx.j_orb 0
function fallendream:equipment/armor/eagle_hat/orb_after

# 原版到此结束
execute if score #im_ol zx.meta matches 0 run return 0
# 一个球都没消耗 ⇒ 没有伤害、没有回魔、也没有回球
scoreboard players set @s zx.mi_armed 1
scoreboard players set @s zx.mi_end 0
scoreboard players set @s zx.mi_mana 0
scoreboard players set @s zx.mi_orb 0
