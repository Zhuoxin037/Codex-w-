# ============================================================
# sweetdream:equipment/armor/huilan/settle —— 回澜结算（脱战 3 秒后）
# ------------------------------------------------------------
# 【执行者】玩家
# 【谁调】core/tick：zx.hl_on=1 且 zx.hl_t 倒数到 <=0 时
# 【算法】回复 = max(4, 记录伤害 / 2)；不设上限（10-20 用户明确删掉了 15 点封顶）。
#   lib/heal 自己会夹到当前生命上限，所以"回超了"不会溢出。
# 【★ 坑 199】lib/heal 的重入保护要求它单独跑完（摘旧上限 → 重读真实上限 →
#   挂新上限），所以这里只调它一次、前后不叠别的 heal。
# ============================================================
scoreboard players operation #hl_h zx.meta = @s zx.hl_dmg
scoreboard players operation #hl_h zx.meta /= #2 zx.meta
scoreboard players operation #hl_h zx.meta /= #1000 zx.meta
execute if score #hl_h zx.meta matches ..3 run scoreboard players set #hl_h zx.meta 4
scoreboard players operation #heal_pt zx.meta = #hl_h zx.meta
execute if score #heal_pt zx.meta matches 1.. run function sweetdream:lib/heal

scoreboard players set @s zx.hl_dmg 0
scoreboard players set @s zx.hl_t 0
scoreboard players set @s zx.hl_on 0
execute at @s run particle minecraft:heart ~ ~1.2 ~ 0.4 0.2 0.4 0.05 8 normal
execute at @s run particle minecraft:bubble ~ ~0.9 ~ 0.5 0.5 0.5 0.01 10 normal
execute at @s run playsound minecraft:block.conduit.activate player @a ~ ~ ~ 0.35 1.5
