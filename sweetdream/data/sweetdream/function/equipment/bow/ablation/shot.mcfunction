# ============================================================
# sweetdream:equipment/bow/ablation/shot —— 消融(弩/史诗/通用) 每次射击
# ------------------------------------------------------------
# 【谁调用】进度 sweetdream:equipment/bow/ablation(触发器 shot_crossbow)
# 【执行者】射手(玩家)
# 【文案逐字】消耗魔力：120
# 【扣蓝口径】离弦那一刻扣 120, 没射中也要付钱; 没蓝 -> 这一发不生效。
# 【付账状态】zx.ab_paid 写在射手身上: 开头先清零, 扣蓝成功才置 1。
#   命中回调 execute on attacker 读, 结算后消费掉 => 一轮多重射击只结算一次。
# 【箭标记】给刚射出的箭打 zx.ab_ok, hook_arrow 只认带这个标记的箭。
#   与其余弩同一套: core/tick 每刻给场上已有的箭打 zx.cc_seen。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/ablation
scoreboard players set @s zx.ab_paid 0
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 扣魔力 120
data modify storage manacore:in arg set value {uuid:"",value:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay

# ② 魔力不足 -> 这一发不生效(zx.ab_paid 开头已清零, 命中回调自然收工)
execute if data storage manacore:out r{success:0b} run return fail

# ③ 记下"这一发付过账"
scoreboard players set @s zx.ab_paid 1

# ④ 给刚射出的箭打"已付钱"标记
execute at @s as @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen,distance=..4] run tag @s add zx.ab_ok
