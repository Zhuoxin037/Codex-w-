# ============================================================
# sweetdream:equipment/staff/pour_sack/splash —— 消耗 ≥120：主目标周围全部生物
# ------------------------------------------------------------
# "对其 2 格内的全部生物造成一半的固定伤害" —— 含主目标自己（设计原文没有排除）。
# 【超限分档（批 K8）】半径 2→5 格，「一半」→「相等」。
#   两档都写成"先灌原版值、再被超限覆盖"，没敲石头时与改动前逐字一致。
# ============================================================
scoreboard players set #ps_h zx.meta 0
scoreboard players operation #ps_h zx.meta = #ps_d zx.meta
scoreboard players operation #ps_h zx.meta /= #2 zx.meta
execute if score #ps_ol zx.meta matches 1 run scoreboard players operation #ps_h zx.meta = #ps_d zx.meta

data modify storage zx:work a set value {fixed:1b,target:"@e[type=!#sweetdream:no_damage,distance=..2]",type:"minecraft:player_attack"}
execute if score #ps_ol zx.meta matches 1 run data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=..5]"
data modify storage zx:work a.num set value 0.0
execute store result storage zx:work a.num double 1.0 run scoreboard players get #ps_h zx.meta
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work ps.u0
data modify storage zx:work a.u1 set from storage zx:work ps.u1
data modify storage zx:work a.u2 set from storage zx:work ps.u2
data modify storage zx:work a.u3 set from storage zx:work ps.u3
function sweetdream:internal/damage/with_from with storage zx:work a

particle minecraft:dust{color:[0.5,0.45,0.7],scale:1.1} ~ ~1 ~ 1.6 0.4 1.6 0.01 16 normal
playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.7 1.1
