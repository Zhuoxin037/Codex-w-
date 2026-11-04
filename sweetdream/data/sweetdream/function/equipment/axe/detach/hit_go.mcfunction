# ============================================================
# sweetdream:equipment/axe/detach/hit_go —— 脱离：本次攻击追加 最大生命值 伤害
# ------------------------------------------------------------
# 【执行者】玩家（动手的）
# 【伤害投递】a.num → lib/num/plain → internal/damage/with_from（deal 唯一出口）
#   数值 = zx.dt_hp（毫点）×0.001 = 最大生命值本身。
# ============================================================

function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ★ 确认命中目标之后才清闸门 ★ 先清再找目标的话，一旦定位失败这一次就白扔了，
#   玩家得重新右键蓄力 —— 2026-11-01 调整顺序。
scoreboard players set @s zx.dt_arm 0

data modify storage zx:work a set value {target:"@e[tag=zx.victim,distance=0..,limit=1]",type:"sweetdream:skill",u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.num double 0.001 run scoreboard players get @s zx.dt_hp
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
# ★★ 必须把 a.num 转成 a.num_str 再投递（2026-11-01 修）★★
#   internal/damage/deal 的宏参数是 $(num_str)，只给 a.num 的话宏"缺少传入参数"，
#   整条 damage 静默失败 —— 表现就是"额外伤害未生效"，零日志。这是脱离不生效的主因。
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
tag @e[tag=zx.victim] remove zx.victim

execute at @s run particle minecraft:crit ~ ~1 ~ 0.4 0.6 0.4 0.1 20 normal

# 之后切换为“同生体”
function sweetdream:profession/twin/enter
