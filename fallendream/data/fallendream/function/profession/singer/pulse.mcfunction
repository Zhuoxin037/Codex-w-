tag @e[tag=zx.j_follow_v,distance=0..16] remove zx.j_follow_v
tag @e[type=!#fallendream:no_damage,distance=..3] add zx.j_follow_v
execute at @a[tag=zx.j_ally_cast,limit=1] run tag @e[type=!#fallendream:no_damage,distance=..3] add zx.j_follow_v
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless data storage zx:b21 echo_stack run data modify storage zx:b21 echo_stack set value []
data modify storage zx:b21 echo_stack append value {ok:0b}
execute as @a[tag=zx.ub,scores={zx.job=3},limit=1] positioned ~ ~ ~ run function fallendream:profession/singer/damage
function fallendream:equipment/tool/echo_harmony/pulse_end
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute if entity @a[tag=zx.ub,scores={zx.job=3,zx.j_aw=1},limit=1] run function fallendream:profession/singer/duet
# 引声·超限(2026-11-22)：把这一轮**真正投递过伤害**的名单抄给引声, 用于附加「渊海」。
#   ★ 必须排在下面清 j_follow_v 之前 ★ 施法者带 zx.in_owner 时才抄(只有引声会挂它)。
execute if entity @a[tag=zx.in_owner,limit=1] run tag @e[tag=zx.j_follow_v,distance=0..16] add zx.in_vic
tag @e[tag=zx.j_follow_v,distance=0..16] remove zx.j_follow_v

# 余响（剑·歌者，2026-11-01）：主动窗口内，追随者触发过一次被动后立即被收回。
#   ★ 必须放在最后一行 ★ 它会把 @s（追随者）kill 掉，后面再写"用 @s 的命令"就无效了。
#   判定与结算都在 equipment/sword/aftersound/recall_check 里。
execute if entity @a[tag=zx.ub,scores={zx.as_win=1},limit=1] at @s run function fallendream:equipment/sword/aftersound/recall_check
