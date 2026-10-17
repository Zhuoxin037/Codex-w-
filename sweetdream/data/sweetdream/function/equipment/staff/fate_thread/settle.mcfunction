# ============================================================
# sweetdream:equipment/staff/fate_thread/settle —— 血丝结算(普攻)
# ------------------------------------------------------------
# 【谁调用它】settle_from_ball   【执行者】**发射者本人**   【位置】命中点
# 【做什么】
#   ① 8 秒节流(记在玩家身上, 原文"该效果 8 秒内不可再次触发")
#   ② 对"最初的生物"和"另一个"各打一次 最大魔力值 ×0.05
#   ③ 给最初的生物附加「噬心」(走 tag/mark 受管接口)
#   ④ 消掉它的血丝
# 【★ 节流为什么先做 ★】一旦触发就要扣掉 8 秒, 否则连点会每球都结算。
# 【★ 附加噬心为什么用 tag/mark 而不是直接 tag add ★】
#   受管状态要带 TTL / 图标 / 一次性效果(噬心没有一次性效果, 但衰减由状态系统统一管),
#   直接 tag add 会得到一个"永不过期、也不显示"的假状态。
# ============================================================

# ① 8 秒节流
scoreboard players add @s zx.ft_pd 0
execute if score @s zx.ft_pd > #now manacore.meta run return 0
scoreboard players operation @s zx.ft_pd = #now manacore.meta
scoreboard players add @s zx.ft_pd 160

# ② 伤害 = 最大魔力值 ×0.05(先重取 uuid: 平A链不经过 lib/uuid, 直接读会读到别人)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.05,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work ft.dmg set from storage manacore:out r.damage

# ③ 打"最初的生物"
data modify storage zx:in arg set value {target:"@e[tag=zx.ft_src,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work ft.dmg
execute at @s run function sweetdream:api/damage

# ④ 打"另一个"(同一个伤害值)
data modify storage zx:in arg set value {target:"@e[tag=zx.ft_other,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work ft.dmg
execute at @s run function sweetdream:api/damage

# ⑤ 最初的生物附加「噬心」
data modify storage zx:work ic set value {target:"@e[tag=zx.ft_src,distance=0..,limit=1]",mark:"shixin"}
function sweetdream:tag/mark with storage zx:work ic

# ⑥ 血丝消失
tag @e[tag=zx.ft_src,distance=0..] remove zx.ft_ln
scoreboard players reset @e[tag=zx.ft_src,distance=0..] zx.ft_ln_end

# ⑦ 表现: 血丝绷断
execute at @e[tag=zx.ft_src,distance=0..,limit=1] run particle minecraft:dust{color:[0.75,0.1,0.2],scale:1.4} ~ ~1 ~ 0.5 0.6 0.5 0.02 24 normal
execute at @e[tag=zx.ft_src,distance=0..,limit=1] run playsound minecraft:entity.vex.hurt player @a ~ ~ ~ 0.7 1.5
