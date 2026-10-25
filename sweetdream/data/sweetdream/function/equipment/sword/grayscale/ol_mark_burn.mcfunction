# ============================================================
# sweetdream:equipment/sword/grayscale/ol_mark_burn —— 超限·灰度: 记下"主伤之前它已经在烧"
# ------------------------------------------------------------
# 【谁调用它】grayscale/overlimit ⑥(逐只, 主伤之前)
# 【执行者】被圈进 5 格的那只生物
# 【为什么单独一个文件】"已经在烧"是**主伤之前**的事实, 而燃烧/流火是主伤**之后**才施加;
#   等 apply 跑完再判, Fire 已经被它自己写过了, 所有人都成了"已经在烧"。
# 【判据照抄原版 apply】1.21.5 的选择器不接受 `Fire:1..` 这种范围写法(会整函数加载失败),
#   只能 data get 出来比; data get 失败(没有 Fire 字段 = 没在烧)时 store 不写,
#   分数保持预置的 0 —— 正合"没在烧"。
# ============================================================
scoreboard players set #gs_bf zx.meta 0
execute store result score #gs_bf zx.meta run data get entity @s Fire
execute if score #gs_bf zx.meta matches 1.. run tag @s add zx.gs_burn
