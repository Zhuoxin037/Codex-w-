# ============================================================
# sweetdream:lib/unfreeze_one —— 解冻一只生物(执行者 = 被冻的那只)
# 【三件事】TicksFrozen 归零 / 摘掉速度属性乘区 / 摘 zx.freeze
# 【计时】只清自己的 zx.fz_end(时停有自己的 zx.ts_end, 不用管)
# 【④ 苦寒(bitter_cold) 钩子】"解除冻结状态的那一刻"是个**事件**, 只能在这里就地广播
#   —— 靠每秒轮询"上一秒冻着、这一秒没冻"会锁相漏判(原因见 unfreeze_dim 里时停那段)。
#   只有 8 格内**持「苦寒」的玩家**在场才触发(判在命令里, 没人在场等于空转)。
#   目标生物靠 zx.bc_thaw 临时标签传给子函数: 子函数里 @s 换成了玩家,
#   而 `execute as` 不改变执行位置 —— 所以子函数能用"执行位置 + distance"把它找回来。
#   标签在下一行立刻摘掉, 不留残留。
# ============================================================

data modify entity @s TicksFrozen set value 0
attribute @s minecraft:movement_speed modifier remove sweetdream:freeze
tag @s remove zx.freeze
scoreboard players reset @s zx.fz_end

# ④ 苦寒: 解冻瞬间 -> 8 格内持「苦寒」的玩家给这只生物 5 秒缓慢Ⅲ + 虚弱Ⅲ + 「渊海」
tag @s add zx.bc_thaw
execute at @s as @a[distance=..8] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["bitter_cold"]}] run function sweetdream:equipment/tool/bitter_cold/on_thaw
tag @s remove zx.bc_thaw