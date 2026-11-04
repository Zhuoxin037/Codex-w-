execute unless entity @e[tag=zx.ball_hit,distance=..4] run return 0
execute at @e[tag=zx.ball_hit,distance=..4,sort=nearest,limit=1] run summon minecraft:marker ~ ~ ~ {Tags:["zx.ex_small","zx.ex_new"],data:{}}
data modify entity @e[tag=zx.ex_new,distance=0..,limit=1] data set from entity @s data
data modify entity @e[tag=zx.ex_new,distance=0..,limit=1] data.owner set from entity @s data.uuid
scoreboard players operation @e[tag=zx.ex_new,distance=0..,limit=1] zx.ex_until = #now manacore.meta
scoreboard players add @e[tag=zx.ex_new,distance=0..,limit=1] zx.ex_until 400
# 外观载体(小石像)：千钧之形本身就该看得见形体，不是只有粒子。
# 用 `execute at <千钧之形>` 而不是在这里写 summon，是为了让 small_model 里的
# `~ ~ ~` 直接就是本体的位置 —— 少一处容易对不齐的坐标复制。
execute at @e[tag=zx.ex_new,distance=0..,sort=nearest,limit=1] run function sweetdream:equipment/staff/exalted/small_model
tag @e[tag=zx.ex_new,distance=0..] remove zx.ex_new
