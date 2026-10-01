scoreboard players add #tag_checks zx.meta 1
$execute store result score #tag_actual zx.meta run execute if entity @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3)]
$execute unless score #tag_actual zx.meta matches $(count) run function sweetdream:debug/tag_test/fail {case:"$(case): entity count"}
$execute if score #tag_actual zx.meta matches 1 unless score @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] zx.icon_mask matches $(expected) run function sweetdream:debug/tag_test/fail {case:"$(case): state mask"}
scoreboard players set #tag_glyphs zx.meta 0
$execute if score #tag_actual zx.meta matches 1 store result score #tag_glyphs zx.meta run data get entity @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] text.extra
$execute unless score #tag_glyphs zx.meta matches $(glyphs) run function sweetdream:debug/tag_test/fail {case:"$(case): glyph count"}
$tag @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3)] add zx.tag_test_icon
