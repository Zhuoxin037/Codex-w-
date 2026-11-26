# 两刻更新位置，续租 40 tick。主人不再参与跟随时图标最多两秒自动回收。
# 单显示实体自带 billboard，因此横排在任意观察角度都不会互相遮挡。
$execute unless entity @s[tag=sd.fb.body] unless entity @s[tag=sd.hk.body] unless entity @s[tag=sd.kn.body] at @s anchored eyes positioned ^ ^ ^ anchored feet run tp @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] ~ ~0.45 ~
$execute if entity @s[tag=sd.fb.body] at @s anchored eyes positioned ^ ^ ^ anchored feet run tp @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] ~ ~1.45 ~
$execute if entity @s[tag=sd.kn.body] at @s anchored eyes positioned ^ ^ ^ anchored feet run tp @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] ~ ~1.45 ~
$execute if entity @s[tag=sd.hk.body] at @s anchored eyes positioned ^ ^ ^ anchored feet run tp @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] ~ ~1.20 ~
$scoreboard players set @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] zx.icon_ttl 40
