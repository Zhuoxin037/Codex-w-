# ============================================================
# sweetdream:equipment/axe/grave_tablet/one —— 裂口单目标结算（@s = 目标）
# ------------------------------------------------------------
# 护甲 ≥15 ⇒ 用 ×4×1.8 档，否则 ×4 档；两档都以 sweetdream:true_damage 投递。
# ★ 读的是目标自己的属性（本函数由 `as @e[...] at @s` 进来，@s = 目标）。
# ★ 护甲读不到（不是活体 / 命令失败）时按 0 处理 ⇒ 走 ×4 档，不会白给 +80%。
# ============================================================
scoreboard players set #gt_arm zx.meta 0
execute store result score #gt_arm zx.meta run attribute @s minecraft:armor get

scoreboard players add #gt_n zx.meta 1

data modify storage zx:work a set value {target:"@s",type:"sweetdream:true_damage"}
execute if score #gt_arm zx.meta matches 15.. run data modify storage zx:work a.num set from storage zx:work gt.d18
execute if score #gt_arm zx.meta matches ..14 run data modify storage zx:work a.num set from storage zx:work gt.d4
function sweetdream:lib/num/plain
data modify storage zx:work a.u0 set from storage zx:work gt.u0
data modify storage zx:work a.u1 set from storage zx:work gt.u1
data modify storage zx:work a.u2 set from storage zx:work gt.u2
data modify storage zx:work a.u3 set from storage zx:work gt.u3
function sweetdream:internal/damage/with_from with storage zx:work a

execute at @s run particle minecraft:dust{color:[0.18,0.18,0.2],scale:1.3} ~ ~1 ~ 0.4 0.5 0.4 0.02 12 normal
execute at @s if score #gt_arm zx.meta matches 15.. run particle minecraft:end_rod ~ ~1 ~ 0.3 0.4 0.3 0.02 8 normal
execute at @s if score #gt_arm zx.meta matches 15.. run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.5 0.8
