# ============================================================
# fallendream:equipment/armor/cease_war/hit —— 止战「余勇」: 普通近战命中生物之后
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/armor/cease_war_hit（player_hurt_entity，只认平A）
# 【执行者】动手的那个玩家
# 【文案】
#   基础: "普通近战命中生物后恢复 10 魔力。重新获得职业攻击增益时，余勇提前结束。"
#   超限: "普通近战命中生物后恢复 12 魔力。重新获得职业攻击增益时，余勇效果**改为**
#          普通近战命中生物后使其护甲值及护甲韧性 -20% 且自身基础攻击力 +5%，
#          可以叠加三次，持续至余勇效果结束。"
# 【★ 两种形态 ★】zx.s2_cw_x = 0 普通余勇（回蓝）/ 1 转化态（扣目标护甲 + 自身加攻）。
#   转化态由 profession/berserker/apply 在"重新获得职业攻击增益"那一刻切过来
#   （基础版是直接把余勇 end 掉，超限改成切换 —— 见 ol_swap）。
# ============================================================

advancement revoke @s only fallendream:equipment/armor/cease_war_hit
function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
execute unless entity @s[tag=zx.s2_cw] run return 0
execute unless score @s zx.s2_cw_end > #now manacore.meta run return 0
execute unless score @s zx.job matches 2 run return 0
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["cease_war"]}] run return 0

# ---- ① 普通余勇: 回 12 魔力（基础版 10）----
execute unless score @s zx.s2_cw_x matches 1 run function fallendream:lib/uuid
execute unless score @s zx.s2_cw_x matches 1 run data modify storage manacore:in arg set value {uuid:"",value:10.0}
execute unless score @s zx.s2_cw_x matches 1 if items entity @s armor.chest *[minecraft:custom_data~{zx:["cease_war"],ol:"cease_war"}] run data modify storage manacore:in arg set value {uuid:"",value:12.0}
execute unless score @s zx.s2_cw_x matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute unless score @s zx.s2_cw_x matches 1 run function manacore:api/mana/add
execute unless score @s zx.s2_cw_x matches 1 run return 0

# ---- ② 转化态: 定位这一下打的生物 -> 扣它护甲/韧性 + 自身叠 +5% ----
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/armor/cease_war/ol_hit with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
