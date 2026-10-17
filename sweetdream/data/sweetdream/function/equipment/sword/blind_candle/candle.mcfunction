# ============================================================
# sweetdream:equipment/sword/blind_candle/candle —— 「烛火」结算(平A后)
# ------------------------------------------------------------
# 【谁调用它】hit_go ③   【执行者】动手的玩家   【位置】他所在处
# 【技能原文】
#   "每次普通攻击后对目标 3 格内随机一个其他生物造成一次相当于自身最大魔力值 ×0.08
#    的伤害。若没有其他生物，则改为对被攻击的生物造成一次相当于自身最大魔力值 ×0.04
#    的伤害。"
# 【★ 没有节流 ★】原文没写"N 秒内最多一次" ⇒ 烛火亮着的 8 秒里每一下平A都触发。
# 【★ "目标" = 刚被这一下平A打中的那只(zx.bcd_v) ★】不是"施法者周围", 也不是"视线前方"。
# 【为什么先把"打谁"归到一个标签】原文是二选一(其他人 / 目标本人), 而一次
#   api/damage 只吃一个选择器 ⇒ 统一挂到 zx.bcd_hit2 上, 倍率同理预先算两份。
# ============================================================

# ① 自己有「烛火」吗(zx.bcd_cd = 到期刻; 过期自然不等于 > #now)
execute unless score @s zx.bcd_cd > #now manacore.meta run return 0

# ② 目标 3 格内随机一个**其他**生物(排除目标自己)
tag @e[tag=zx.bcd_pick2,distance=0..] remove zx.bcd_pick2
execute at @e[tag=zx.bcd_v,distance=0..,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=0.01..3,tag=!zx.bcd_v,sort=random,limit=1] add zx.bcd_pick2

# ③ 决定这一刀打谁: 有别人 -> 它; 没有 -> 目标本人
tag @e[tag=zx.bcd_hit2,distance=0..] remove zx.bcd_hit2
execute if entity @e[tag=zx.bcd_pick2,distance=0..,limit=1] run tag @e[tag=zx.bcd_pick2,distance=0..] add zx.bcd_hit2
execute unless entity @e[tag=zx.bcd_pick2,distance=0..,limit=1] run tag @e[tag=zx.bcd_v,distance=0..] add zx.bcd_hit2

# ④ 两个候选倍率各算一次(同 passive: 先重取 uuid, 否则可能按别人的魔力算)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work bcdc.dmg0 set from storage manacore:out r.damage

data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.04,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work bcdc.dmg1 set from storage manacore:out r.damage

# ⑤ 按"有没有别人"取倍率
data modify storage zx:work bcdc.dmg set from storage zx:work bcdc.dmg1
execute if entity @e[tag=zx.bcd_pick2,distance=0..,limit=1] run data modify storage zx:work bcdc.dmg set from storage zx:work bcdc.dmg0

# ⑥ 打
data modify storage zx:in arg set value {target:"@e[tag=zx.bcd_hit2,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work bcdc.dmg
execute at @s run function sweetdream:api/damage

# ⑦ 表现: 烛火跳了一下
execute at @e[tag=zx.bcd_hit2,distance=0..,limit=1] run particle minecraft:flame ~ ~0.8 ~ 0.3 0.4 0.3 0.02 10 normal
