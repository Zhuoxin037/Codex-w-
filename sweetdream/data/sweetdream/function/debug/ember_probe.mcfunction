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
execute if entity @s[tag=zx.em_burn] run tellraw @a[tag=zx.em_dbg] [{"text":"      余烬边沿标记: ","color":"gray"},{"text":"有","color":"green"}]
execute unless entity @s[tag=zx.em_burn] run tellraw @a[tag=zx.em_dbg] [{"text":"      余烬边沿标记: ","color":"gray"},{"text":"无","color":"red"}]
execute if entity @s[tag=zx.status.liuhuo] run tellraw @a[tag=zx.em_dbg] [{"text":"      流火","color":"gold"}]
execute if entity @s[tag=zx.status.yehuo] run tellraw @a[tag=zx.em_dbg] [{"text":"      夜火","color":"dark_purple"}]
