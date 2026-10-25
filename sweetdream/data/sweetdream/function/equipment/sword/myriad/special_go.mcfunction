# ============================================================
# sweetdream:equipment/sword/myriad/special_go —— 宏: 打领域内那批生物
# ------------------------------------------------------------
# 【宏参数】zx:work mqh {u0,u1,u2,u3} = 玩家 UUID 四个整数
# 【前置】#mq_isq(1 = 手里是千散) 已由调用方设好; zx:data self.uuid 已备好
# 【目标】zx.mq_dmg(本函数现圈, **不清** —— 留给公共收尾 tail 里的居合回声用)
# ============================================================

tag @e[tag=zx.mq_dmg] remove zx.mq_dmg

# ① 领域还在 -> 打领域内的生物(半径 5, 文案原话)
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @e[tag=zx.mq_f] at @s if entity @a[distance=..5,tag=zx.ub,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..5] add zx.mq_dmg

# ② 领域已经散了 -> 退回"主动技能"自身的口径: 自身 3 格内
#   ★ 这一条不能省 ★ 2026-10-08 起释放窗口不再要求站在领域里(见 cast ③),
#     领域 6 秒本来就常在这时已到期; 没有这条兜底, ① 圈出来的是**空集**,
#     整个特殊技能就会"放出来了但没有任何伤害"(而且不报错, 最难查)。
execute at @s unless entity @e[tag=zx.mq_dmg,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..3] add zx.mq_dmg

execute unless entity @e[tag=zx.mq_dmg,limit=1] run return 0

# 千散效果: 基础攻击力 ×3     /     万念效果: 最大魔力 ×0.12
execute if score #mq_isq zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",attack_mul:3.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
execute unless score #mq_isq zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.12,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/myriad/ju_boost
function manacore:api/damage/calc

# 居合的增伤是"**下一次**技能伤害", 这次用掉就清(下一层由 tail 里的 ju_extend 再叠)
scoreboard players set @s zx.mq_jb 0
execute store result score #mq_echo zx.meta run data get storage manacore:out r.damage

# 【本次口径】窗口技能用的是哪把的效果, 就按哪把的口径重复 (2026-10-08 用户定稿)
#   文案第二句是"使用一次【X】的主动技能**效果**"(引用式措辞), 所以:
#     · 手里千散(#mq_isq=1, 打基础攻击力 ×3) -> #mq_qs=1 -> 按剑魂重复 1+N 次
#     · 手里万念(#mq_isq=0, 打最大魔力 ×0.12) -> #mq_qs=0 -> 固定 1 次
#   ⚠️ 这一发**不清**剑魂: 它是被动兑现, tail 里那道 #mq_pas 门控会挡住
#     ("这个是被动触发的效果", 见 special ⑧)。
scoreboard players operation #mq_qs zx.meta = #mq_isq zx.meta

function sweetdream:equipment/sword/myriad/hit_go
