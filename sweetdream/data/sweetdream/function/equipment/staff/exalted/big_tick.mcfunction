data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute unless entity @s[tag=zx.ex_big] run return 0
execute unless entity @a[tag=zx.ub,distance=0..,limit=1] run return run function sweetdream:equipment/staff/exalted/big_die
particle minecraft:dust{color:[0.52,0.4,0.65],scale:2.0} ~ ~ ~ 0.7 0.7 0.7 0 9 normal
tag @s add zx.ex_self
function sweetdream:equipment/staff/exalted/big_find with entity @s data
execute if entity @s[tag=zx.ex_big] at @s if entity @e[tag=zx.ex_goal,distance=0..,limit=1] run function sweetdream:equipment/staff/exalted/big_move
tag @e[tag=zx.ex_goal,distance=0..] remove zx.ex_goal
tag @e[tag=zx.ex_candidate,distance=0..] remove zx.ex_candidate
tag @s remove zx.ex_self

# ============================================================
# 外观载体(item_display)的每刻同步 —— 2026-11-01 建模实装
# ------------------------------------------------------------
# 三条各管一件事, 缺一条都会"能动但看着不对":
#  ① 位置: 载体不是本体的乘客(marker 的挂载点在各版本里不保证是 0) ⇒ 每刻硬 tp。
#     `tp @s ~ ~ ~` 只给 3 个坐标 ⇒ **朝向保留原值**, 正是我们要的(朝向交给 ②)。
#  ② 朝向: 本体每刻被 big_move 的 `facing entity … tp @s ~ ~ ~ ~ ~` 转向,
#     载体自己有独立的 Rotation ⇒ 不抄的话石像永远朝北, 走起来像横着平移。
#     抄的是 Rotation[0](yaw), 因为 merge 里已经把模型转过 180°, 口径一致。
#  ③ zx.ex_live: 每刻重打一次, lib/second 靠"这一秒有没有被打过"判孤儿。
#     ★ 别删这条 —— 本体被任何未预见的方式收掉时, 这是唯一的兜底。
# 【为什么用 distance=..3 而不是精确匹配】没有 UUID 绑定: 载体是本体的唯一
#   同伴, 3 格内不会有第二个。稳态距离 ≈0(big_tick 每刻拽)。
# 【@s 已经死了会怎样】三条都以 `at @s` / `@s` 为前提 ⇒ 整条不执行,
#   不会误伤旁边的另一个崇高之形。
# 【★ 下面 tp 与 data modify 两条必须 sort=nearest,limit=1 ★】
#   `data modify entity` 的 NBT 路径**只接受唯一实体**, 选择器只要"允许多个"
#   就会在**加载期**抛 `只允许一个实体` —— 注意: 是整个 big_tick 函数作废,
#   不是这一条失效。表现 = 大石像站着不动、不追踪、不推人、没有伤害,
#   而且日志里只有一行 Failed to load function(2026-11-01 18:59 踩过一次)。
#   tp 也顺手带 limit=1: 两个载体挤进 3 格时不会互相被拽走。
#   （`store ... data get entity @s` 与末尾的 tag 不受此限: 前者是 @s, 后者允许多个。）
# ============================================================
execute at @s run tp @e[tag=zx.ex_model,distance=..3,sort=nearest,limit=1] ~ ~ ~
execute store result storage zx:work exm.ry float 1 run data get entity @s Rotation[0]
execute at @s run data modify entity @e[tag=zx.ex_model,distance=..3,sort=nearest,limit=1] Rotation[0] set from storage zx:work exm.ry
tag @e[tag=zx.ex_model,distance=..3] add zx.ex_live
