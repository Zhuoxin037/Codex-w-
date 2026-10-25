# ============================================================
# sweetdream:equipment/armor/glimmer/foe_slow —— 黄 / 白 的"最近 N 个生物减速"
# ------------------------------------------------------------
# 【执行者】玩家(@s)（已确认穿着浮光）
# 【★ 文案(逐字) ★】
#   黄：「离自身最近的 3 个生物移速 -40%」
#   白：「离自身最近的 5 个生物移速 -45%」
# 【★ 原文没给范围 ★】字面是"最近的 N 个", 不设界的话会去减速 200 格外的怪,
#   玩家看到的是"莫名其妙有怪变慢"。这里取 **10 格**为界（实现口径, lore 未写）。
# 【★ 为什么不用"每刻刷" ★】给生物挂 attribute 会标脏 chunk（卡顿坑 2）。
#   每秒只刷一次, 并且用 zx.gl_slt 做 2 秒倒计时: 玩家脱装备 / 换目标后,
#   最多 2 秒那边自己就恢复了 —— 不会留下永久 -40% 的漏洞。
# 【★ 重复 add 不报错 ★】同一个 modifier id 已存在时 add 会失败(返回 0, 无副作用),
#   所以不必先 remove（与 tag/mark_one 里 liuhuo 那条同口径）。
# ============================================================

# ① 该挂几个 / 挂多少：白优先
scoreboard players set #gl_fn zx.meta 0
scoreboard players set #gl_fv zx.meta 40
execute if score @s zx.gl_y matches 1.. run scoreboard players set #gl_fn zx.meta 3
execute if score @s zx.gl_r matches 1.. if score @s zx.gl_g matches 1.. if score @s zx.gl_y matches 1.. run scoreboard players set #gl_fn zx.meta 5
execute if score @s zx.gl_r matches 1.. if score @s zx.gl_g matches 1.. if score @s zx.gl_y matches 1.. run scoreboard players set #gl_fv zx.meta 45
execute if score #gl_fn zx.meta matches 0 run return 0

# ② 挑最近的 N 个（不含玩家 / 不含非活体）
#   ★ 逐档写两条命令: limit 只能吃字面量
execute if score #gl_fn zx.meta matches 3 at @s run tag @e[type=!#sweetdream:no_damage, type=!minecraft:player, distance=..10, sort=nearest, limit=3] add zx.gl_foe
execute if score #gl_fn zx.meta matches 5 at @s run tag @e[type=!#sweetdream:no_damage, type=!minecraft:player, distance=..10, sort=nearest, limit=5] add zx.gl_foe

# ③ 逐个挂上（值按 #gl_fv 分两条字面量）
execute as @e[tag=zx.gl_foe, distance=0..] run function sweetdream:equipment/armor/glimmer/foe_one

# ④ 收尾
tag @e[tag=zx.gl_foe, distance=0..] remove zx.gl_foe
