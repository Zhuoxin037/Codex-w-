# ============================================================
# fallendream:equipment/armor/bearing/ol_full —— 超限·承: 满术阵 4 秒 → 自己那份「阵成」
# ------------------------------------------------------------
# 【谁调用它】bearing/second ⑤.6（条件已判: 身上是超限「承」）
# 【执行者】玩家（@s）
# 【文案(lore 逐字)】…自身保持满术阵 4 秒后，进入「阵成」（可以和套装和枢的「阵成」叠加），
#   冷却 12 秒。
# 【★ 这一份不要「枢」 ★】套装那份要求头上是「枢」；这一份是「承」自带的,
#   只穿承也会触发。文案特意写"可以和套装和枢的阵成叠加" ⇒ 三份独立计时。
# 【★ 时长按套装口径 8 秒(160 刻) ★】原文只写"进入阵成"没写秒数；包里「阵成」
#   统一按 8 秒处理（与套装一致）。★待用户确认★
# 【★ 满的判据 ★】fm_u == fm_c 且 fm_c ≥ 1（上限 0 是异常态, 不算满）。
# ============================================================

# ① 满了吗
scoreboard players set #brx_full zx.meta 0
execute if score @s zx.fm_c matches 1.. if score @s zx.fm_u = @s zx.fm_c run scoreboard players set #brx_full zx.meta 1

# ② 连续满的秒数（不满立刻清零；到 4 就停住不再涨）
scoreboard players add @s zx.brx_hold 0
execute unless score #brx_full zx.meta matches 1 run scoreboard players set @s zx.brx_hold 0
execute if score #brx_full zx.meta matches 1 if score @s zx.brx_hold matches ..3 run scoreboard players add @s zx.brx_hold 1

# ③ 满不够 4 秒 / 还在 12 秒冷却里 → 什么都不做
execute unless score @s zx.brx_hold matches 4.. run return 0
execute if score @s zx.brx_cd > #now manacore.meta run return 0

# ④ 进入「阵成」: 8 秒, 冷却 12 秒
scoreboard players operation @s zx.brx_zc = #now manacore.meta
scoreboard players add @s zx.brx_zc 160
scoreboard players operation @s zx.brx_cd = #now manacore.meta
scoreboard players add @s zx.brx_cd 240
scoreboard players set @s zx.brx_hold 0

tellraw @s [{"text":"「阵成」","color":"gold"},{"text":"  承 · 满术阵 4 秒 —— 技能伤害 +15%、技能冷却 −10%","color":"gray"}]
execute at @s run particle minecraft:end_rod ~ ~1.2 ~ 0.7 0.5 0.7 0.04 16 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.5 1.4
