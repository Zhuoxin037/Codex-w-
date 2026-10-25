# ============================================================
# sweetdream:debug/ember_probe —— 单只生物的状态快照(给 debug/ember_immolate 用)
# ------------------------------------------------------------
# 【执行者】生物   【接收者】@a[tag=zx.em_dbg]
# 【看什么】Fire 还剩几 tick / 有没有余烬边沿标记 / 流火 / 夜火
#   排查“焚舟点了火但余烬没反应”: Fire>0 却没有 em_burn, 就是边沿标记漏了。
# ============================================================

scoreboard players set #em_f zx.meta 0
execute store result score #em_f zx.meta run data get entity @s Fire

tellraw @a[tag=zx.em_dbg] [{"text":"  · ","color":"dark_gray"},{"selector":"@s"},{"text":"  Fire=","color":"gray"},{"score":{"name":"#em_f","objective":"zx.meta"},"color":"yellow"}]
execute if score @s zx.em_burn matches 1 run tellraw @a[tag=zx.em_dbg] [{"text":"      余烬边沿标记: ","color":"gray"},{"text":"有","color":"green"}]
execute unless score @s zx.em_burn matches 1 run tellraw @a[tag=zx.em_dbg] [{"text":"      余烬边沿标记: ","color":"gray"},{"text":"无","color":"red"}]
execute if entity @s[tag=zx.status.liuhuo] run tellraw @a[tag=zx.em_dbg] [{"text":"      流火","color":"gold"}]
execute if entity @s[tag=zx.status.yehuo] run tellraw @a[tag=zx.em_dbg] [{"text":"      夜火","color":"dark_purple"}]
# 双状态时"补流火"的节流闸: 这是该生物下次可补的 tick 时刻, 和 #now 比 ——
#   gate <= #now 才会补(见 ember/top_up)。没打过闸的目标显示 0(可以补)。
scoreboard players add @s zx.em_gate 0
execute if entity @s[tag=zx.status.yehuo] run tellraw @a[tag=zx.em_dbg] [{"text":"      下次可补流火(gate/#now): ","color":"gray"},{"score":{"name":"@s","objective":"zx.em_gate"},"color":"yellow"},{"text":" / ","color":"dark_gray"},{"score":{"name":"#now","objective":"manacore.meta"},"color":"white"}]
