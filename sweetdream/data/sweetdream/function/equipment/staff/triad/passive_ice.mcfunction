# ============================================================
# sweetdream:equipment/staff/triad/passive_ice —— 冰斧被动: 概率冰冻 1 秒
# ------------------------------------------------------------
# 【文案】「很冰的斧」每次攻击生物后都有 20% 的概率使其冰冻 1 秒;
#   强化中概率提升至 60%。
# 【概率】lib/rnd → %= #100: 普通取 ..19(20%), 强化取 ..59(60%)。
#   一次只掷一次骰 —— "先掷普通再看强化"会掷两次, 概率就变成条件概率了。
# 【冰冻】走现成的 lib/freeze(宏 {target, ticks}); 1 秒 = 20 tick。
#   它会自己续冻、到点自己解, 本文件不管生命周期。
# ============================================================

function sweetdream:lib/rnd
scoreboard players operation #tri_r zx.meta = #rnd zx.meta
scoreboard players operation #tri_r zx.meta %= #100 zx.meta

# 普通 20%
execute if data storage zx:work tri{strong:0b} if score #tri_r zx.meta matches ..19 run data modify storage zx:work fz set value {target:"@e[tag=zx.ball_hit]",ticks:20}
execute if data storage zx:work tri{strong:0b} if score #tri_r zx.meta matches ..19 run function sweetdream:lib/freeze with storage zx:work fz

# 强化 60%
execute if data storage zx:work tri{strong:1b} if score #tri_r zx.meta matches ..59 run data modify storage zx:work fz set value {target:"@e[tag=zx.ball_hit]",ticks:20}
execute if data storage zx:work tri{strong:1b} if score #tri_r zx.meta matches ..59 run function sweetdream:lib/freeze with storage zx:work fz

# 命中表现: 结霜
execute as @e[tag=zx.ball_hit] at @s run particle minecraft:snowflake ~ ~1 ~ 0.3 0.5 0.3 0.02 8 normal
