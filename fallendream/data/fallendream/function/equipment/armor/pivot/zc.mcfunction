# ============================================================
# fallendream:equipment/armor/pivot/zc —— 超限枢: 进入自己的「阵成」(8 秒)
# ------------------------------------------------------------
# 【执行者】玩家(已确认戴着超限枢 + 满血满 12 秒 + 冷却已好)
# 【出参】zx.pv_zc = 到期刻(8 秒) / zx.pv_cd = 下次可进入刻(12 秒)
# 【和套装的关系】独立账本 ⇒ 和「承」的阵成**同时存在时两份都生效**(文案"可以叠加")。
# ============================================================
scoreboard players set @s zx.pv_hp 0
scoreboard players operation @s zx.pv_zc = #now manacore.meta
scoreboard players add @s zx.pv_zc 160
scoreboard players operation @s zx.pv_cd = #now manacore.meta
scoreboard players add @s zx.pv_cd 240

tellraw @s [{"text":"「阵成」","color":"gold"},{"text":"  满血 12 秒 —— 技能伤害 +15%、技能冷却 −10%","color":"gray"}]
particle minecraft:end_rod ~ ~1 ~ 0.8 0.6 0.8 0.05 20 normal
playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.5 1.6
