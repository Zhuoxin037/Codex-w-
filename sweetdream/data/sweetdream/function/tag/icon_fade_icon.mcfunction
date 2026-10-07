# ============================================================
# sweetdream:tag/icon_fade_icon —— 图标淡出的逐帧(执行者 = 一个正在淡出的图标)
# ------------------------------------------------------------
# 【谁调它】core/tick 三维度 `as @e[tag=zx.icon_fading]`
# 【做什么】帧号 -1 -> 同步降 text_opacity + 缩 transformation.scale -> 到 0 收掉自己
# 【★ 为什么从图标侧驱动(与跟随分开) ★】这样即便生物中途死亡、跟随驱动消失,
#   图标也能自己淡完并 kill —— 否则会留下"永远淡不完的孤儿图标"(静态隐患)。
# 【★ 为什么不用 interpolation_duration 补间】实测靠不住(MC-259926 插值非确定 /
#   MC-260874 相邻两刻 chained desync), 一律服务端逐帧推字面常量。
#   图标本身 interpolation_duration 缺省 = 0, 改了就立刻生效。
# 【★ text_opacity 是**有符号 byte**(-128..127) ★】它按无符号解读成 0..255:
#   · 0..3   -> 当作完全不透明(255)
#   · 4..26  -> **整段文字被丢弃**(看不见)
#   · 27..255-> 正常不透明度
#   所以"高不透明度"要写**负值**(-36b = 220 …); 落到 40b 以下就直接 kill,
#   不要走进 4..26 那段(否则最后几帧是突然整段消失, 不是渐变)。
# 【为什么安全】这些实体已经摘了 zx.icon_v2 -> 每秒的租约清扫 / icon_tp / 旧格式清理
#   都不会碰它们(后者已显式排除 zx.icon_fading)。
# ============================================================

scoreboard players remove @s zx.icon_fade 1
execute if score @s zx.icon_fade matches 7 run data modify entity @s text_opacity set value -36b
execute if score @s zx.icon_fade matches 7 run data modify entity @s transformation.scale set value [0.74f,0.74f,0.74f]
execute if score @s zx.icon_fade matches 6 run data modify entity @s text_opacity set value -66b
execute if score @s zx.icon_fade matches 6 run data modify entity @s transformation.scale set value [0.69f,0.69f,0.69f]
execute if score @s zx.icon_fade matches 5 run data modify entity @s text_opacity set value -96b
execute if score @s zx.icon_fade matches 5 run data modify entity @s transformation.scale set value [0.64f,0.64f,0.64f]
execute if score @s zx.icon_fade matches 4 run data modify entity @s text_opacity set value -126b
execute if score @s zx.icon_fade matches 4 run data modify entity @s transformation.scale set value [0.59f,0.59f,0.59f]
execute if score @s zx.icon_fade matches 3 run data modify entity @s text_opacity set value 100b
execute if score @s zx.icon_fade matches 3 run data modify entity @s transformation.scale set value [0.54f,0.54f,0.54f]
execute if score @s zx.icon_fade matches 2 run data modify entity @s text_opacity set value 70b
execute if score @s zx.icon_fade matches 2 run data modify entity @s transformation.scale set value [0.49f,0.49f,0.49f]
execute if score @s zx.icon_fade matches 1 run data modify entity @s text_opacity set value 40b
execute if score @s zx.icon_fade matches 1 run data modify entity @s transformation.scale set value [0.44f,0.44f,0.44f]
execute if score @s zx.icon_fade matches ..0 run kill @s
