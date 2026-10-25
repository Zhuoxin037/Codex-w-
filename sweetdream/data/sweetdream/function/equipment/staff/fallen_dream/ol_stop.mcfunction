# ============================================================
# sweetdream:equipment/staff/fallen_dream/ol_stop —— 超限·堕梦普攻的「20% 概率时停 1 秒」
# ------------------------------------------------------------
# 【谁调用它】ball_hit 第 ④ 步: `as @e[tag=zx.ball_hit] at @s run function 本文件`
#   ⇒ 执行者 = **被命中的那一只**, 每只各进来一次(所以要逐只掷点, 不能外面摇一次)。
# 【文案】"之后有 20% 的概率额外使其时停 1 秒。"
# 【为什么抽成单独文件】`as @e[...]` 后面要接"摇号 → 判等 → 给时停"三件事,
#   写成一坨会在"判等失败"时把后面的粒子也吃掉(execute 链的条件会一路带下去);
#   拆成函数后, 函数内部第一行就能 `return`, 外层循环不受影响。
# 【随机源】lib/rnd(LCG, 全包统一)。20% = "值 % 5 == 0"。
#   ★ 别用坐标小数位 / 当前 tick 之类的源: 站着不动打同一只怪会一直同一个结果。
# ============================================================

# ① 掷点(0..4 等概率; 命中 0 号 = 20%)
function sweetdream:lib/rnd
scoreboard players operation #fd_r zx.meta = #rnd zx.meta
scoreboard players operation #fd_r zx.meta %= #5 zx.meta
execute unless score #fd_r zx.meta matches 0 run return 0

# ② 时停 1 秒(20 tick)
#   ★ 走 lib/timestop 而不是直接改 zx.ts_end: 时停有一整套"上标签 / 记结束时刻 /
#     解冻 sweep"的账本, 手写只改一个数会漏掉 zx.stop 标签 ⇒ 表现上根本没停住。
data modify storage zx:work fz set value {target:"@s",ticks:20}
function sweetdream:lib/timestop with storage zx:work fz

# ③ 表现
execute at @s run particle minecraft:reverse_portal ~ ~1 ~ 0.3 0.5 0.3 0.02 14 normal
