# ============================================================
# sweetdream:equipment/bow/tiejili/spawn —— 生成蒺藜区（宏）
# ------------------------------------------------------------
# 【宏参数】sweetdream:work tj {dmg,u0,u1,u2,u3}
# 【本体是 marker】不吃伤害、不占地表方块（不改世界，可随时撤销）
# ============================================================
$summon minecraft:marker ~ ~ ~ {Tags:["zx.tjl_field","zx.tjl_new"],data:{zx:{dmg:$(dmg),u:[I;$(u0),$(u1),$(u2),$(u3)]}}}
scoreboard players operation @e[type=marker,tag=zx.tjl_new,distance=..1,limit=1] zx.tjl_end = #now manacore.meta
scoreboard players add @e[type=marker,tag=zx.tjl_new,distance=..1,limit=1] zx.tjl_end 100
scoreboard players operation @e[type=marker,tag=zx.tjl_new,distance=..1,limit=1] zx.tjl_next = #now manacore.meta
tag @e[type=marker,tag=zx.tjl_new,distance=..1] remove zx.tjl_new
particle minecraft:crit ~ ~0.1 ~ 1.2 0.1 1.2 0.02 24 normal
particle minecraft:enchanted_hit ~ ~0.15 ~ 1.0 0.05 1.0 0.02 16 normal
