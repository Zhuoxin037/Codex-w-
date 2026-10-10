# ============================================================
# internal/uuid/collect_self —— 把自己的 UUID 四个 int 缓存进计分项(以 @s 执行)
# ------------------------------------------------------------
# 【谁调用它】internal/session/tick_self: `unless score @s manacore.u0 matches
#   -2147483648..2147483647` —— 即"这个人还没有缓存"时, 每人一生只跑一次。
# 【为什么敢缓存】玩家 UUID 是账号级的, 死亡重生 / 掉线重连 / /reload 都不变;
#   计分项跨死亡、跨 reload 保留。所以读一次就够了。
# 【为什么不用 add @s 建分】UUID 的 int 可能是 0 或负数, `scoreboard players
#   add @s manacore.u0 0` 会建出一个 0 分, 把真值顶掉 —— 这里用 store result,
#   读不到时根本不会建分(命令失败, 分数不动), 判定仍为"未缓存"。
# 【O02】见 tick_self 头注释: 这 4 条 data get entity 每条都是全玩家 NBT 序列化,
#   缓存后每秒的 4 次变成 4 次计分板读。
# ============================================================
execute store result score @s manacore.u0 run data get entity @s UUID[0]
execute store result score @s manacore.u1 run data get entity @s UUID[1]
execute store result score @s manacore.u2 run data get entity @s UUID[2]
execute store result score @s manacore.u3 run data get entity @s UUID[3]
