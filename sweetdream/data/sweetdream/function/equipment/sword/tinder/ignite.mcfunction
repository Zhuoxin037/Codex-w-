# ============================================================
# sweetdream:equipment/sword/tinder/ignite —— 让单只生物燃烧 5 秒(仅当它还没在烧)
# ------------------------------------------------------------
# 【执行者】被波及的单只生物
# 【执行位置】被击者身上(坐标由 burn 的 at 定好, as 只是换个执行者)
# 【★ 为什么不用 unless data entity @s {Fire:1..} ★】
#   1.21.5 的实体选择器 / NBT 过滤器不接受 `Fire:1..` 这种范围写法:
#   会报 "Whilst parsing command ... 应为十进制数", 并且**整个 burn 函数
#   加载失败**(2026-10-07 实机报错)。完全照抄 immolate/check_burn 的笨办法:
#   先 data get 出 Fire 存进分数再判。
#   ★ data get 失败时(实体根本没有 Fire 字段=没在烧), execute store 不会写,
#     分数保持我们预先 set 的 0 -> 正好当成"没在烧"。
# ============================================================

scoreboard players set #td_f zx.meta 0
execute store result score #td_f zx.meta run data get entity @s Fire

# Fire <= 0 = 未处于燃烧状态 -> 点燃 5 秒(100 tick)
execute if score #td_f zx.meta matches ..0 run data merge entity @s {Fire:100s}
