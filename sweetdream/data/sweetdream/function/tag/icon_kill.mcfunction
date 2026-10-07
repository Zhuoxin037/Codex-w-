# 不再直接 kill: 改成逐帧淡出(见 tag/icon_fade + tag/icon_fade_go)。
# 【执行者】被标记的那只**生物**(icon_refresh 调进来时 @s 就是它)。
# 【为什么要换标签】每秒的图标租约清扫(tag/second_dimension)会把没被续租的 zx.icon_v2
#   图标当场杀掉 —— 正在淡出的图标必须先摘掉 zx.icon_v2, 否则淡出只播一帧。
# 【顺序】先 add 淡出标签 → 再 remove v2(两步都按 v2 选目标) → 把帧号写在**图标**上
#   (逐帧在 tag/icon_fade_icon, 从图标侧驱动, 孤儿图标也能自己淡完) → 最后给**生物**
#   打 zx.icon_fading_owner, 让 tag/icon_fade 在淡出期间继续把图标贴到头顶。
$tag @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3)] add zx.icon_fading
$tag @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3)] remove zx.icon_v2
$scoreboard players set @e[type=minecraft:text_display,tag=zx.icon_fading,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3)] zx.icon_fade 8
tag @s add zx.icon_fading_owner

