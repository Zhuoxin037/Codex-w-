# ============================================================
# sweetdream:equipment/axe/grave_tablet/cd —— 每命中一个 -6 秒，单次最多 -30 秒
# ------------------------------------------------------------
# 45 秒冷却，5 个目标就减满（-30 秒），6 个及以上不再多减。
# ============================================================
execute if score #gt_n zx.meta matches 6.. run data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:grave_tablet",seconds:30.0}
execute if score #gt_n zx.meta matches 6.. run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #gt_n zx.meta matches 6.. run function manacore:api/cooldown/reduce
execute if score #gt_n zx.meta matches 1..5 run data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:grave_tablet",seconds:0.0}
execute if score #gt_n zx.meta matches 1..5 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #gt_n zx.meta matches 1..5 run execute store result storage manacore:in arg.seconds double 6.0 run scoreboard players get #gt_n zx.meta
execute if score #gt_n zx.meta matches 1..5 run function manacore:api/cooldown/reduce

execute at @s run particle minecraft:dust{color:[0.2,0.75,0.85],scale:0.9} ~ ~1 ~ 0.5 0.6 0.5 0.01 10 normal
