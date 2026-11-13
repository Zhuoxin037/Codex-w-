$execute unless entity $(vx_uuid) run return 0
tag @e[tag=zx.bcd_v,distance=0..] remove zx.bcd_v
$tag $(vx_uuid) add zx.bcd_v
$tag $(vx_uuid) remove zx.victim

# ② 被动段: 目标带「夜火」才结算(节流在 passive 里)
scoreboard players set #bcd_ye zx.meta 0
execute as @e[tag=zx.bcd_v,distance=0..,limit=1] if entity @s[tag=zx.status.yehuo] run scoreboard players set #bcd_ye zx.meta 1
execute if score #bcd_ye zx.meta matches 1 run function sweetdream:equipment/sword/blind_candle/passive

# ③ 烛火段(独立于夜火)
function sweetdream:equipment/sword/blind_candle/candle

# ④ 收尾: 清本轮临时标签
tag @e[tag=zx.bcd_v,distance=0..] remove zx.bcd_v
tag @e[tag=zx.bcd_pick,distance=0..] remove zx.bcd_pick
tag @e[tag=zx.bcd_pick2,distance=0..] remove zx.bcd_pick2
tag @e[tag=zx.bcd_hit2,distance=0..] remove zx.bcd_hit2
