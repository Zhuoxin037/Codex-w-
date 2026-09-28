# ============================================================
# sweetdream:tag/mark_one —— 贴标记(宏 {mark}; 以**那只生物**身份执行)
# ------------------------------------------------------------
# ① 写 NBT 标记
# ② 从全局计数器借一个编号, 存成这只生物自己的 zx.icon_id
#    (用计分项不需要宏, 而且天然"每只一份")
# ③ 挂 zx.tagged: 每秒的同步循环靠它筛选, 没标记过的生物完全不参与
# ④ 立刻刷新一次图标(所以贴上去的那一瞬间就能看见)
# ============================================================

$data modify entity @s data.zx.status."$(mark)" set value 1b

# 【★ 重复贴同一个标签不要换编号 ★】
#   一开始写成"每贴一次就借一个新编号", 结果旧图标换了主人、变成没人认领的孤儿
#   留在原地 —— 同一个标签贴两次, 头顶就有两个图标。改成: 已经有编号就沿用。
scoreboard players add #icon_id zx.meta 1
execute unless score @s zx.icon_id matches 1.. store result score @s zx.icon_id run scoreboard players get #icon_id zx.meta

tag @s add zx.tagged

# 标签可能变了(比如本来只有流火, 现在又加了渊海 -> 该显示渊海的图标),
# 所以先把旧图标收掉, 下面重算时会按现在的标签重生一个正确的。
function sweetdream:tag/icon_kill_self
function sweetdream:tag/icon_refresh
