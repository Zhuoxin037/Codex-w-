# 临时 keep 标签只在当前 UUID 的集合内使用。
$tag @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3)] remove zx.icon_keep
$tag @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] add zx.icon_keep
$kill @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),tag=!zx.icon_keep]
$tag @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3)] remove zx.icon_keep
