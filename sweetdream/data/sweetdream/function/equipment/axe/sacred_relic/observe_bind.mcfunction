# 宏 {victim,u0..u3}; @s 是受害者, marker 按准确 victim UUID 去重。
tag @e[type=minecraft:marker,tag=zx.sr_watch_new,distance=0..] remove zx.sr_watch_new
# 按唯一 victim UUID 查记录, 故意跨维度去重(生物可能刚过传送门)。
$execute unless entity @e[type=minecraft:marker,tag=zx.sr_w,nbt={data:{victim:"$(victim)"}}] run summon minecraft:marker ~ ~ ~ {Tags:["zx.sr_w","zx.sr_watch_new"],data:{victim:"$(victim)"}}
$data modify entity @e[type=minecraft:marker,tag=zx.sr_w,nbt={data:{victim:"$(victim)"}},limit=1] data.owner set value [I;$(u0),$(u1),$(u2),$(u3)]
$scoreboard players set @e[type=minecraft:marker,tag=zx.sr_w,nbt={data:{victim:"$(victim)"}},limit=1] zx.sr_wt 110
tag @e[type=minecraft:marker,tag=zx.sr_watch_new,distance=0..] remove zx.sr_watch_new
