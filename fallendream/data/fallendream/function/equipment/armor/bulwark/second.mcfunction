# ============================================================
# fallendream:equipment/armor/bulwark/second —— 肉盾（胸甲）每秒：抗性档 + 攻加成到期
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】自身最大生命值低于 50% 获得抗性提升Ⅱ，低于 30% 改为抗性提升Ⅳ。
#   受击那一段在 hurt（进度 entity_hurt_player）。
# 【★ 抗性用 effect give 每秒续 2 秒 ★】文案是"低于 X% 时获得"，
#   一旦回到线上方必须自然掉 —— 短时长重挂，脱装/回血后最多多留 1 秒。
#   amplifier：抗性提升Ⅱ = 1，抗性提升Ⅳ = 3。
# ============================================================

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["bulwark"]}] run function fallendream:equipment/armor/bulwark/off
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["bulwark"]}] run return 0

function fallendream:lib/hp_pct
execute if score #hp_p100 zx.meta matches ..4999 run effect give @s minecraft:resistance 2 1 true
execute if score #hp_p100 zx.meta matches ..2999 run effect give @s minecraft:resistance 2 3 true

# 受击加的「基础攻击力」10 秒到期（hurt 里记的是绝对到期刻）
execute if score @s zx.bw_st matches 1 unless score @s zx.bw_until > #now manacore.meta run function fallendream:equipment/armor/bulwark/expire
