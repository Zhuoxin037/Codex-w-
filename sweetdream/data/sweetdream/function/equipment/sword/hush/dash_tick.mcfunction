# ============================================================
# sweetdream:equipment/sword/hush/dash_tick —— 每刻推进一步(突击)
# ------------------------------------------------------------
# 【谁调用它】sweetdream:core/tick:
#   execute as @a[scores={zx.hush=1..}] at @s run function ...
# 【还剩几步】就是玩家自己在 zx.hush 上的分数(16 步 × 0.5 = 8 格)。
#   用计分项而不是 storage: 天然"每人一份", 不用按 UUID 拼路径, 于是"推进"
#   这一层完全不需要宏函数 —— 少一层就少一类坑(同横刀 dash_tick)。
# 【★ 2026-10-07 改版: 撞到生物**不停**, 但每碰到一次都当场打一片】
#   停法只有两种: ① 方块挡路 ② 走完 16 步。
#   路上碰到生物: 见 ③ —— 身边 3 格内出现"本局还没打过的生物"就触发一次,
#   由 touch_dmg 对**身边 3 格内的全部生物**结算 最大魔力值 ×0.1(同一只每次施法至多一次);
#   停下后不再结算去程, 只由 back_finish 打回程 ×0.2。
# 【rotated ~ 0 不能删】^ 是带俯仰角的局部坐标: 视角稍微下压, `^ ^ ^0.5` 就
#   往斜下方算, 探针落到脚前地面那一格 -> 被判成撞墙 -> 第 0 步就停。
#   rotated ~ 0 = 朝向保留、俯仰归零, 于是 ^ ^ ^ 只沿水平方向走。
# 【每步 0.5 格】比原来的 0.25 快一倍(8 格 = 16 刻 = 0.8 秒)。方块挡路的探针
#   就在落点上(^ ^ ^0.5), 整数格宽 1 的墙一定会在落点被探到, 不会穿过去。
# 【半径】去程"碰到"与"打一片"都用 3 格(碰到生物就对身边 3 格内全部生物结算);
#   回程用 1.5 格 —— 那是"从旁边掠过"的路径走廊(见 ② 与 back_finish)。
# ============================================================

# ① 方块挡路: 脚那格 / 头那格不是可穿过方块 -> 停
execute rotated ~ 0 positioned ^ ^ ^0.5 unless block ~ ~ ~ #minecraft:replaceable run scoreboard players set @s zx.hush 0
execute rotated ~ 0 positioned ^ ^ ^0.5 unless block ~ ~1 ~ #minecraft:replaceable run scoreboard players set @s zx.hush 0

# ② 记下"路径上的生物"(1.5 格内) —— 闪回落地时由 back_finish 结算 ×0.2
execute as @e[type=!#sweetdream:no_damage,distance=..1.5] run tag @s add zx.hs_path

# ③ ★ 碰到生物: 身边 3 格内只要出现"本局还没打过的生物", 就触发一次范围伤害 ★
#   先给"3 格内还没被本局打过(tag=!zx.hs_hit)"的生物挂临时标签 zx.hs_new;
#   真有新的才调 touch_dmg —— 它对 3 格内**全部**生物结算 最大魔力值 ×0.1,
#   并把 3 格内全部生物都标成 zx.hs_hit(本局已覆盖) ⇒ 冲进同一群怪只触发一次,
#   不会每刻刷。zx.hs_hit 每次施法由 cast 开头全局清一遍, 保证下一局又能打。
execute as @e[type=!#sweetdream:no_damage,tag=!zx.hs_hit,distance=..3] run tag @s add zx.hs_new
execute if entity @e[type=!#sweetdream:no_damage,tag=zx.hs_new,distance=..3] run function sweetdream:equipment/sword/hush/touch_dmg

# ④ 还能走就挪一步(0.5 格), 再把剩余步数减 1
execute if score @s zx.hush matches 1.. rotated ~ 0 run tp @s ^ ^ ^0.5
execute if score @s zx.hush matches 1.. run scoreboard players remove @s zx.hush 1

# ⑤ 走完 / 停住 -> 起归位(去程伤害已在 ③ 随碰随打)
execute if score @s zx.hush matches ..0 run function sweetdream:equipment/sword/hush/dash_end
