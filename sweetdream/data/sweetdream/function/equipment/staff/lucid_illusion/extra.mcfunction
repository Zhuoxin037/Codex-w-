# ============================================================
# sweetdream:equipment/staff/lucid_illusion/extra —— 清醒与幻觉：占一个额外法球槽
# ------------------------------------------------------------
# 【执行者】玩家   【入参】#li_dur zx.meta = 这个额外法球能活几刻（200 / 400）
# 【槽怎么算空】该槽的到期刻 `≤ #now`（没写过的分数也算空 —— `unless …>` 对"没分数"成立）
# 【★ 为什么用三个独立的到期刻槽、而不是一个计数 ★】
#   额外法球是**一个一个在不同时刻**生成的，各自 10 秒；只有一个计数器的话，
#   先来的到期了也没法单独作废。三个槽各记各的到期刻，第二次（主动结算）还能
#   直接给出 20 秒的版本，互不干扰。
# 【最多 3 个】三个槽都占着时本函数什么都不做（文案"最多 3 个"）。
# ============================================================

scoreboard players set #li_s1 zx.meta 0
scoreboard players set #li_s2 zx.meta 0
scoreboard players set #li_s3 zx.meta 0

# ---- 槽 1 ----
execute unless score @s zx.li_e1 > #now manacore.meta run scoreboard players operation @s zx.li_e1 = #now manacore.meta
execute unless score @s zx.li_e1 > #now manacore.meta run scoreboard players set #li_s1 zx.meta 1
execute if score #li_s1 zx.meta matches 1 run scoreboard players operation @s zx.li_e1 += #li_dur zx.meta

# ---- 槽 2（槽 1 没占上才试）----
execute if score #li_s1 zx.meta matches 0 unless score @s zx.li_e2 > #now manacore.meta run scoreboard players operation @s zx.li_e2 = #now manacore.meta
execute if score #li_s1 zx.meta matches 0 unless score @s zx.li_e2 > #now manacore.meta run scoreboard players set #li_s2 zx.meta 1
execute if score #li_s2 zx.meta matches 1 run scoreboard players operation @s zx.li_e2 += #li_dur zx.meta

# ---- 槽 3（前两槽都没占上才试）----
execute if score #li_s1 zx.meta matches 0 if score #li_s2 zx.meta matches 0 unless score @s zx.li_e3 > #now manacore.meta run scoreboard players operation @s zx.li_e3 = #now manacore.meta
execute if score #li_s1 zx.meta matches 0 if score #li_s2 zx.meta matches 0 unless score @s zx.li_e3 > #now manacore.meta run scoreboard players set #li_s3 zx.meta 1
execute if score #li_s3 zx.meta matches 1 run scoreboard players operation @s zx.li_e3 += #li_dur zx.meta

# 槽满 = 不再生成（三个都没占上就是满的）
execute if score #li_s1 zx.meta matches 0 if score #li_s2 zx.meta matches 0 if score #li_s3 zx.meta matches 0 run return 0
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.5 0.5 0.5 0.04 8 normal

# 【2026-11-01 补：超限必须"听得见"】
#   超限法球没有实体、不是掉落物，界面上原本只剩观测镜那一行（zx.li_x）。
#   不开观测镜的玩家完全不知道自己已经越限，只觉得"球明明才 3 个却一直在掉血"。
#   这里给一声低沉的共鸣音做锚点：听到这个音 = 从这一刻开始每秒吃反噬。
execute at @s run playsound minecraft:block.amethyst_block.resonate player @s ~ ~ ~ 0.7 0.5
