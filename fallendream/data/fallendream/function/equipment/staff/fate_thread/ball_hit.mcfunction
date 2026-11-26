# 先找施放者先前留的血丝，再给本次命中挂血丝。
scoreboard players set #ft_olx zx.meta 0
execute if data entity @s data{ol:1} run scoreboard players set #ft_olx zx.meta 1

# ① 先算出"血丝还有效"的候选(选择器不能判分, 只能先打一层临时标签)
tag @e[tag=zx.ft_lnok,distance=0..] remove zx.ft_lnok
data modify storage zx:work ft_pass set value {queue:[],kept:[],node:{}}
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0
execute as @a[tag=zx.ub,limit=1] run function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work ft_pass.owner set from storage zx:data self
function fallendream:equipment/staff/fate_thread/line_read with storage zx:work ft_pass.owner
tag @e[tag=zx.ft_src,distance=0..] remove zx.ft_src
#   甲: 本次命中者自己就带有效血丝(最近的一只)
execute as @e[tag=zx.ball_hit,tag=zx.ft_lnok,distance=0..,sort=nearest,limit=1] run tag @s add zx.ft_src
#   乙: 甲没找到 -> 以最近的那个命中者为圆心, 5 格(超限 8 格)内挑一只带有效血丝的其他生物
#       (distance=0.01.. 天然排除它自己: 不会拿"自己和自己"结算)
#   ★ 两档互斥：matches 0 / matches 1，别让 8 格那条在 5 格那条之后又跑一次。
execute unless entity @e[tag=zx.ft_src,distance=0..,limit=1] if score #ft_olx zx.meta matches 0 as @e[tag=zx.ball_hit,distance=0..,sort=nearest,limit=1] at @s run tag @e[tag=zx.ft_lnok,distance=0.01..5,sort=nearest,limit=1] add zx.ft_src
execute unless entity @e[tag=zx.ft_src,distance=0..,limit=1] if score #ft_olx zx.meta matches 1 as @e[tag=zx.ball_hit,distance=0..,sort=nearest,limit=1] at @s run tag @e[tag=zx.ft_lnok,distance=0.01..8,sort=nearest,limit=1] add zx.ft_src

# ③ 找"另一个": src 5 格(超限 8 格)内、本次也命中、且不是它自己
#   ★ 必须带"src 存在"的门控: 否则 execute at 会退回世界原点执行, 可能在 0,0,0 附近
#     误标一只当 other(虽然 ④ 还会拦一次, 但临时标签乱跑没必要)。
tag @e[tag=zx.ft_other,distance=0..] remove zx.ft_other
execute if entity @e[tag=zx.ft_src,distance=0..,limit=1] if score #ft_olx zx.meta matches 0 at @e[tag=zx.ft_src,distance=0..,limit=1] run tag @e[tag=zx.ball_hit,distance=0.01..5,tag=!zx.ft_src,sort=nearest,limit=1] add zx.ft_other
execute if entity @e[tag=zx.ft_src,distance=0..,limit=1] if score #ft_olx zx.meta matches 1 at @e[tag=zx.ft_src,distance=0..,limit=1] run tag @e[tag=zx.ball_hit,distance=0.01..8,tag=!zx.ft_src,sort=nearest,limit=1] add zx.ft_other

# ④ 两者都在才结算; 结算要以**发射者身份**做(算伤要面板、击杀归属要玩家)
execute if entity @e[tag=zx.ft_src,distance=0..,limit=1] if entity @e[tag=zx.ft_other,distance=0..,limit=1] run function fallendream:equipment/staff/fate_thread/settle_from_ball

# ⑤ 挂新丝线(本次命中的每一只都留 5 秒血丝; 重复命中 = 刷新到期刻)
execute as @e[tag=zx.ball_hit,distance=0..] at @s run function fallendream:equipment/staff/fate_thread/line_mark

# ⑥ 收尾(本刻现打的临时标签一律摘掉)
function fallendream:equipment/staff/fate_thread/line_save with storage zx:work ft_pass.owner
tag @e[tag=zx.ft_src,distance=0..] remove zx.ft_src
tag @e[tag=zx.ft_other,distance=0..] remove zx.ft_other
tag @e[tag=zx.ft_lnok,distance=0..] remove zx.ft_lnok
