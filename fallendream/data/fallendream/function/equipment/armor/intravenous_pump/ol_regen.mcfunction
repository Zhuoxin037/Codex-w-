# ============================================================
# fallendream:equipment/armor/intravenous_pump/ol_regen —— 超限·静脉泵：70% 血以上的每秒回魔
# ------------------------------------------------------------
# 【文案】"自身生命值在 70% 以上时每秒恢复 12 点魔力值。自身生命值保持在 70% 以上
#   超过 8 秒时，每秒恢复的魔力值提升为 30 。"
# 【执行者】玩家  【判据】调用方已确认穿超限 + zx.hp_p100 >= 7000
# 【★ 8 秒怎么算 ★】passive 每秒在 70% 以上给 zx.ip_hi +1，掉下去清零；
#   >= 8 起按 30 点（此处按"满 8 秒即升档"，不是第 9 秒才升）。
# 【★ 与基础版互斥 ★】基础版的"满血 3 点"在 ④-a，超限档只走本文件。
# ============================================================

scoreboard players set #ip_gain zx.meta 12
execute if score @s zx.ip_hi matches 8.. run scoreboard players set #ip_gain zx.meta 30

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #ip_gain zx.meta
function manacore:api/mana/add

scoreboard players operation @s zx.regen_extra += #ip_gain zx.meta
