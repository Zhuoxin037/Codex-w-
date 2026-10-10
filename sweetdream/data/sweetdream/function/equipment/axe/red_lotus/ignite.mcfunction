# ============================================================
# sweetdream:equipment/axe/red_lotus/ignite —— 让**单只**生物燃烧 N 秒(只延长、不缩短)
# ------------------------------------------------------------
# 【宏参数】zx:work rl{n:<tick 数>} —— 目标燃烧时间(Fire 用 tick; NBT 的 s 后缀
#   是 short 类型标记, 不是秒)。
# 【执行者】被波及的单只生物
# 【★ 为什么不直接 data merge Fire:40s ★】
#   目标已经在烧、而且剩余时间更长时, 直接 merge 会**把长燃烧砍短**(反而帮倒忙)。
#   完全照抄 tinder/ignite + immolate/ignite 的笨办法: 先 data get 出 Fire 再判。
#   ★ 1.21.5 的 NBT 过滤器**不接受** `Fire:1..` 这种范围写法(会让整个函数加载失败),
#     所以只能读出来比。
#   ★ data get 失败时(没有 Fire 字段 = 没在烧), store 不执行, 分数保持预设的 0 -> 正好。
# ============================================================

scoreboard players set #rl_f zx.meta 0
execute store result score #rl_f zx.meta run data get entity @s Fire
$execute unless score #rl_f zx.meta matches $(n).. run data merge entity @s {Fire:$(n)s}
