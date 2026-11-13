# ============================================================
# sweetdream:equipment/bow/pierce/shot —— 穿孔(弩/罕见/魔导士1) 每次射击
# ------------------------------------------------------------
# 【谁调用】进度 sweetdream:equipment/bow/pierce(触发器 shot_crossbow)
# 【执行者】射手(玩家)
# 【文案逐字】消耗魔力 30 / 每次射击时消耗 1 个法球
# 【一轮一次】shot_crossbow 一次射击只触发一次, 天然只扣一次球/一次蓝;
#   zx.pi_paid 写射手身上, 命中回调 execute on attacker 读并消费
#   => 多重射击的 3 支箭各自命中也只结算一次贯穿。
# 【没球口径】没有法球则本发不生效, 且不扣蓝(与魔力不足同口径)。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/pierce
scoreboard players set @s zx.pi_paid 0

# 职业门控(魔导士1 专属)
execute unless score @s zx.job matches 1 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 1 run return fail

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 没有法球 -> 不生效(不扣蓝)
execute unless score @s zx.j_orb matches 1.. run return fail

# ② 扣魔力 30
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ③ 消耗 1 个法球(普通法球 = 玩家计分项 zx.j_orb)
scoreboard players remove @s zx.j_orb 1

# ④ 记下"这一发付过账"
scoreboard players set @s zx.pi_paid 1

# ⑤ 给刚射出的箭打"已付钱"标记
execute at @s as @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen,distance=..4] run tag @s add zx.pi_ok
