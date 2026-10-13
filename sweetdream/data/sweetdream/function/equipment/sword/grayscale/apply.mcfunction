# ============================================================
# sweetdream:equipment/sword/grayscale/apply —— 灰度: 点火 / 或改附加「流火」
# ------------------------------------------------------------
# 【谁调用它】grayscale/cast ⑦(逐只)
# 【执行者/位置】被波及的单只生物(at @s)
# 【原文】"之后使其燃烧 3 秒。若已经处于燃烧状态则改为使其附加「流火」。"
# 【★ 为什么不用 unless data entity @s {Fire:1..} ★】
#   1.21.5 的选择器 / NBT 过滤器不接受 `Fire:1..` 这种范围写法(会整函数加载失败),
#   照抄 tinder/ignite 的笨办法: 先 data get 出来比。
#   ★ data get 失败(没 Fire 字段=没在烧)时 store 不写, 分数保持预置的 0 -> 正合"没在烧"。
# ============================================================

scoreboard players set #gs_f zx.meta 0
execute store result score #gs_f zx.meta run data get entity @s Fire

# 没在烧 -> 燃烧 3 秒(60 tick)
execute if score #gs_f zx.meta matches ..0 run data merge entity @s {Fire:60s}
# 已在烧 -> 改为附加「流火」(tag/mark 只对非玩家活体生效)
execute if score #gs_f zx.meta matches 1.. run function sweetdream:tag/mark {target:"@s",mark:"liuhuo"}
