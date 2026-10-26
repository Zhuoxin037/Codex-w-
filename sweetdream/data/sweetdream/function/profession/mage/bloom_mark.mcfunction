execute unless entity @s[tag=zx.tags_v2] run function sweetdream:tag/migrate
# Snapshot every existing TTL because the legacy mark_one refreshes all present marks.
data modify storage zx:work jbttl set value {liuhuo:0,yehuo:0,shixin:0,yuanhai:0,dream:0}
execute store result storage zx:work jbttl.liuhuo int 1 run scoreboard players get @s zx.tt.liuhuo
execute store result storage zx:work jbttl.yehuo int 1 run scoreboard players get @s zx.tt.yehuo
execute store result storage zx:work jbttl.shixin int 1 run scoreboard players get @s zx.tt.shixin
execute store result storage zx:work jbttl.yuanhai int 1 run scoreboard players get @s zx.tt.yuanhai
execute store result storage zx:work jbttl.dream int 1 run scoreboard players get @s zx.tt.dream
tag @s add zx.j_bloom_v
data modify storage zx:work ub set from storage zx:work jb_owner
function sweetdream:lib/u_by
$execute as @a[tag=zx.ub,limit=1] positioned ~ ~ ~ run function sweetdream:tag/mark {target:"@e[tag=zx.j_bloom_v,distance=0..,limit=1]",mark:"$(mark)"}
tag @s remove zx.j_bloom_v
execute if data storage zx:work jbttl.liuhuo store result score @s zx.tt.liuhuo run data get storage zx:work jbttl.liuhuo
execute if data storage zx:work jbttl.yehuo store result score @s zx.tt.yehuo run data get storage zx:work jbttl.yehuo
execute if data storage zx:work jbttl.shixin store result score @s zx.tt.shixin run data get storage zx:work jbttl.shixin
execute if data storage zx:work jbttl.yuanhai store result score @s zx.tt.yuanhai run data get storage zx:work jbttl.yuanhai
execute if data storage zx:work jbttl.dream store result score @s zx.tt.dream run data get storage zx:work jbttl.dream
$data modify storage zx:work jbmark set value "$(mark)"
execute if data storage zx:work {jbmark:"liuhuo"} run scoreboard players add @s zx.tt.liuhuo 6
execute if data storage zx:work {jbmark:"yehuo"} run scoreboard players add @s zx.tt.yehuo 6
execute if data storage zx:work {jbmark:"shixin"} run scoreboard players add @s zx.tt.shixin 6
execute if data storage zx:work {jbmark:"yuanhai"} run scoreboard players add @s zx.tt.yuanhai 6
execute if data storage zx:work {jbmark:"dream"} run scoreboard players add @s zx.tt.dream 6
