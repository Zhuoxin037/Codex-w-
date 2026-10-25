# ============================================================
# sweetdream:equipment/staff/cage_day/hit_all —— 对目标 5 格内全部生物结算（位置 = 目标）
# ============================================================
# ★ 半径两档互斥（2026-10-23 批 K8）：基础 5 格 / 超限 8 格。
#   写成"先灌原版值、再被超限覆盖"，没敲石头时与改动前逐字一致。
data modify storage zx:work a set value {target:"@e[type=!#sweetdream:no_damage,distance=..5]",type:"minecraft:player_attack"}
execute if score #cg_ol zx.meta matches 1 run data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=..8]"
data modify storage zx:work a.num set from storage zx:work cg.dmg
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work cg.u0
data modify storage zx:work a.u1 set from storage zx:work cg.u1
data modify storage zx:work a.u2 set from storage zx:work cg.u2
data modify storage zx:work a.u3 set from storage zx:work cg.u3
function sweetdream:internal/damage/with_from with storage zx:work a

particle minecraft:dust{color:[0.95,0.9,0.55],scale:1.0} ~ ~1 ~ 2.2 0.5 2.2 0.01 20 normal
