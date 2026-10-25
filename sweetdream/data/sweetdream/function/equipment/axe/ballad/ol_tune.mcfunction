# ============================================================
# sweetdream:equipment/axe/ballad/ol_tune —— 超限·歌谣: 攻击也攒「曲调」
# ------------------------------------------------------------
# 【谁调用它】hit(平A命中, 排在按游戏刻去重 **之后**)
# 【执行者】动手的玩家
# 【设计原文】"自身使用「歌谣」时每攻击或击杀一个生物则积攒一点「曲调」。（最高 8 层）"
#   —— 常态版只有"击杀"攒层; 超限版加上"攻击"。
# 【★ 为什么放在按刻去重之后 ★】一次挥击(横扫)可能命中好几只; 文案的"每攻击
#   一个生物"在这里按"每次攻击动作"算一次 —— 不然横扫一刀直接 +5 层, 太快。
# 【★ zx.blt_lt 是给 kill 用的 ★】攻击攒过之后, 同一刻的"击杀"不该再加一点
#   (一击必杀会同时触发 player_hurt_entity 与 player_killed_entity), 见 kill。
# ============================================================

# ⓪ 不是超限版 -> 常态的歌谣只有"击杀"攒层
execute unless data storage zx:work bdly{ol:1} run return 0

# ① 已经满 8 层 -> 不再加
execute if score @s zx.bd_tune matches 8.. run return 0

# ② +1 并记下这一 tick
scoreboard players add @s zx.bd_tune 1
scoreboard players operation @s zx.blt_lt = #now manacore.meta

# ③ 表现(轻, 不刷屏: 只有音效 + 一个小音符粒子)
execute at @s run particle minecraft:note ~ ~1.4 ~ 0.3 0.3 0.3 0.01 2 normal
execute at @s run playsound minecraft:block.note_block.harp player @a ~ ~ ~ 0.3 1.6
