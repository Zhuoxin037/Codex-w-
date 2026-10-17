# ============================================================
# sweetdream:tag/icon_fade_go —— 淡出期间的"跟随"(宏: 用 zx:tag owner 的 uuid 拼选择器)
# ------------------------------------------------------------
# 【执行者】被标记的那只生物   【谁调它】tag/icon_fade(先跑 identity 写好 owner)
# 【做什么】把正在淡出的图标继续 tp 到头顶, 并在图标已不在时自清理驱动标签。
# 【★ 为什么要有这一层】摘掉最后一个标签后生物已不在 zx.tagged 里, follow_dimension
#   不再管它 —— 不补这条, 0.4 秒里高速移动的生物会把图标甩在原地 1~2 格。
# 【★ 逐帧淡出不在本文件】那部分在 tag/icon_fade_icon(从**图标侧**驱动), 这样即使
#   生物中途死亡、本驱动消失, 图标也能自己淡完并 kill —— 不会有孤儿图标残留。
# ============================================================

$execute unless entity @e[type=minecraft:text_display,tag=zx.icon_fading,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3)] run tag @s remove zx.icon_fading_owner
$execute unless entity @e[type=minecraft:text_display,tag=zx.icon_fading,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3)] run return 0
$execute unless entity @s[tag=sd.fb.body] at @s anchored eyes positioned ^ ^ ^ anchored feet run tp @e[type=minecraft:text_display,tag=zx.icon_fading,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3)] ~ ~0.45 ~
$execute if entity @s[tag=sd.fb.body] at @s anchored eyes positioned ^ ^ ^ anchored feet run tp @e[type=minecraft:text_display,tag=zx.icon_fading,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3)] ~ ~1.45 ~
