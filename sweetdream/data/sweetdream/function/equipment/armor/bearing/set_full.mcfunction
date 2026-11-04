# ============================================================
# sweetdream:equipment/armor/bearing/set_full —— 套装：「阵成」的进入与计时（每秒）
# ------------------------------------------------------------
# 【执行者】玩家（已确认穿着「承」；套装还要求同时穿着「枢」）
# 【文案】术阵位全满时获得 8 秒「阵成」：技能伤害 +15%（独立乘区），技能冷却 −10%。
#   每 12 秒最多进入一次「阵成」。
# 【★ 边沿触发 ★】zx.br_full：上一秒是否"满"。只有 0→1 且冷却好了才进入。
# 【★ 满的判据 ★】fm_u == fm_c 且 fm_c ≥ 1（上限为 0 时不算满 —— 那是异常态）。
# 【★ 冷却 -10% 不在这里做 ★】见 bearing/on_cast：对"刚进入冷却的那个技能"减时长。
# ============================================================

# 套装门控：头上必须是「枢」
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run return 0

# 满了吗
scoreboard players set #br_full zx.meta 0
execute if score @s zx.fm_c matches 1.. if score @s zx.fm_u = @s zx.fm_c run scoreboard players set #br_full zx.meta 1

# 未满：清边沿记录就收工
execute if score #br_full zx.meta matches 0 run scoreboard players set @s zx.br_full 0
execute if score #br_full zx.meta matches 0 run return 0

# 已经满着（上秒也满）→ 不重复触发
execute if score @s zx.br_full matches 1 run return 0
scoreboard players set @s zx.br_full 1

# 12 秒冷却
execute if score @s zx.br_cd > #now manacore.meta run return 0

# 进入「阵成」：8 秒
scoreboard players operation @s zx.br_zc = #now manacore.meta
scoreboard players add @s zx.br_zc 160
scoreboard players operation @s zx.br_cd = #now manacore.meta
scoreboard players add @s zx.br_cd 240

tellraw @s [{"text":"「阵成」","color":"gold"},{"text":"  术阵位全满 —— 技能伤害 +15%、技能冷却 −10%","color":"gray"}]
particle minecraft:end_rod ~ ~1 ~ 0.8 0.6 0.8 0.05 20 normal
playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.5 1.6
