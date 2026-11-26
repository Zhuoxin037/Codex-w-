# ============================================================
# fallendream:equipment/bow/ember_string/fire —— 「烬弦」结算(宏 {target, shooter, uuid})
# ------------------------------------------------------------
# 【执行者】射手(玩家), 位置/朝向 = 射手自己(apply 用 as/at 送进来)
# 【文案·原版】三种互斥分支 + 整段 8 秒节流(记在**射手**身上):
#   ① 未附「流火」和「夜火」 -> 附加「流火」
#   ② 附「流火」未附「夜火」 -> 「流火」转化为「夜火」
#   ③ 已附「夜火」           -> 额外造成 自身最大魔力值 ×0.04 的伤害
# 【文案·超限】分支③ 改 ×0.06；节流改成"每个生物 4 秒"(记在**受害者**身上)；
#   另加 ③-D: 12 秒内三种效果都对它触发过 -> 再打一次 ×0.08 + 随机标签。
# 【★ 超限为什么按生物算 4 秒 ★】文案是"以上三个效果每个对生物 4 秒最多触发一次"。
#   三种分支互斥(按命中前状态二选一), 所以"每效果各自 4 秒"与"整体 4 秒"在
#   单只生物上只差一点: 前者能让连射两箭连续走①②。取**整体 4 秒**是因为
#   后半句"12 秒内触发全部效果"正好 = 3 × 4 秒, 说明设计上就是每 4 秒一次、
#   12 秒刚好集齐三种 —— 若逐效果各自计时, 连射三箭就能拿奖励, 彩蛋失去意义。
#   要改成逐效果独立冷却: 把 ① 里那条 es_cd 拆成 es_t1/t2/t3 三条各判各的。
# 【★ 快照必须先拍(坑 123) ★】②③ 的判据都是"命中**前**带什么", 而 ①② 会改状态
#   ⇒ 先把"命中前带流火/带夜火"拍成目标身上的两个标签(zx.es_hadl / zx.es_hady),
#     后面全部按快照取值, 绝不在改了状态之后再按状态现选。
# 【★ ②是"替换"不是"消耗" ★】刻意不走 lib/mark_consume: 走它的话, 穿「永恒」的
#   消耗者会把流火"补回来"变成"流火+夜火"双状态 —— 2026-10-04 记过的刷魔力漏洞
#   (热熔/余烬的流火→夜火 也是这样处理)。
# ============================================================

# ⓪ 受害者还在吗
execute unless entity @e[tag=zx.es_v,distance=0..,limit=1] run return 0

# ① 节流(分档)
#   原版: **整段** 8 秒(2026-10-15 用户拍板), 记在射手身上。
#     zx.es_gate = 该射手"下次可触发"的 tick 时刻(#now = 框架时钟, 见 manacore core/tick)。
#     ★ 先 `add 0` 把没分数的玩家补成 0 —— 计分项"没分数"时 `if score` 判**不成立**,
#       不能靠"没分数"表达"从没触发过"(那样第一次永远触发不了)。
#   超限: 每只生物 4 秒, 记在受害者身上(zx.es_cd), 一只一个, 互不挤占。
scoreboard players add @s zx.es_ol 0
execute if score @s zx.es_ol matches 0 run scoreboard players add @s zx.es_gate 0
execute if score @s zx.es_ol matches 0 if score @s zx.es_gate > #now manacore.meta run return 0
execute if score @s zx.es_ol matches 0 run scoreboard players operation @s zx.es_gate = #now manacore.meta
execute if score @s zx.es_ol matches 0 run scoreboard players operation @s zx.es_gate += #160 zx.meta
execute if score @s zx.es_ol matches 1 as @e[tag=zx.es_v,distance=0..,limit=1] run scoreboard players add @s zx.es_cd 0
execute if score @s zx.es_ol matches 1 as @e[tag=zx.es_v,distance=0..,limit=1] if score @s zx.es_cd > #now manacore.meta run return 0
execute if score @s zx.es_ol matches 1 as @e[tag=zx.es_v,distance=0..,limit=1] run scoreboard players operation @s zx.es_cd = #now manacore.meta
execute if score @s zx.es_ol matches 1 as @e[tag=zx.es_v,distance=0..,limit=1] run scoreboard players operation @s zx.es_cd += #80 zx.meta

# ② 拍"命中前"状态快照(挂在**受害者**身上, 不用假玩家 —— 一发多目标不串号, 坑 123 同款)
tag @e[tag=zx.es_hadl,distance=0..] remove zx.es_hadl
tag @e[tag=zx.es_hady,distance=0..] remove zx.es_hady
execute as @e[tag=zx.es_v,distance=0..,limit=1] if entity @s[tag=zx.status.liuhuo] run tag @s add zx.es_hadl
execute as @e[tag=zx.es_v,distance=0..,limit=1] if entity @s[tag=zx.status.yehuo] run tag @s add zx.es_hady

# 诊断锚 #es_dbg8 = 这一发走了哪条分支(1=附加流火 / 2=流火转夜火 / 3=夜火补伤害)
scoreboard players set #es_dbg8 zx.meta 0
execute unless entity @e[tag=zx.es_hadl,distance=0..,limit=1] unless entity @e[tag=zx.es_hady,distance=0..,limit=1] run scoreboard players set #es_dbg8 zx.meta 1
execute if entity @e[tag=zx.es_hadl,distance=0..,limit=1] unless entity @e[tag=zx.es_hady,distance=0..,limit=1] run scoreboard players set #es_dbg8 zx.meta 2
execute if entity @e[tag=zx.es_hady,distance=0..,limit=1] run scoreboard players set #es_dbg8 zx.meta 3

# ③-A 两个都没有 -> 附加「流火」(这是"附着"不是"消耗", 走通用接口 tag/mark)
execute unless entity @e[tag=zx.es_hadl,distance=0..,limit=1] unless entity @e[tag=zx.es_hady,distance=0..,limit=1] run data modify storage zx:work ic set value {target:"@e[tag=zx.es_v,limit=1]",mark:"liuhuo"}
execute unless entity @e[tag=zx.es_hadl,distance=0..,limit=1] unless entity @e[tag=zx.es_hady,distance=0..,limit=1] run function fallendream:tag/mark with storage zx:work ic

# ③-B 有流火、无夜火 -> 「流火」转化为「夜火」(先摘后挂; 不走 mark_consume)
execute if entity @e[tag=zx.es_hadl,distance=0..,limit=1] unless entity @e[tag=zx.es_hady,distance=0..,limit=1] run data modify storage zx:work ic set value {target:"@e[tag=zx.es_v,limit=1]",mark:"liuhuo"}
execute if entity @e[tag=zx.es_hadl,distance=0..,limit=1] unless entity @e[tag=zx.es_hady,distance=0..,limit=1] run function fallendream:tag/unmark with storage zx:work ic
execute if entity @e[tag=zx.es_hadl,distance=0..,limit=1] unless entity @e[tag=zx.es_hady,distance=0..,limit=1] run data modify storage zx:work ic set value {target:"@e[tag=zx.es_v,limit=1]",mark:"yehuo"}
execute if entity @e[tag=zx.es_hadl,distance=0..,limit=1] unless entity @e[tag=zx.es_hady,distance=0..,limit=1] run function fallendream:tag/mark with storage zx:work ic

# ③-C 已有夜火 -> 额外造成 最大魔力值 ×0.04(原版) / ×0.06(超限) 的伤害
execute if score @s zx.es_ol matches 0 if entity @e[tag=zx.es_hady,distance=0..,limit=1] run data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.04}
execute if score @s zx.es_ol matches 1 if entity @e[tag=zx.es_hady,distance=0..,limit=1] run data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.06}
execute if entity @e[tag=zx.es_hady,distance=0..,limit=1] run data modify storage manacore:in arg.uuid set from storage zx:work es.uuid
execute if entity @e[tag=zx.es_hady,distance=0..,limit=1] run function manacore:api/damage/calc
data modify storage zx:work es.dmg set value 0.0
execute if entity @e[tag=zx.es_hady,distance=0..,limit=1] run data modify storage zx:work es.dmg set from storage manacore:out r.damage
execute if entity @e[tag=zx.es_hady,distance=0..,limit=1] run data modify storage zx:work es.s2_b_dmg set value {n:0,d:1}
execute if entity @e[tag=zx.es_hady,distance=0..,limit=1] run data modify storage zx:work es.s2_b_dmg set from storage manacore:out r.s2_b_damage
execute store result storage zx:work es.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work es.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work es.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work es.u3 int 1 run data get entity @s UUID[3]
execute if entity @e[tag=zx.es_hady,distance=0..,limit=1] as @e[tag=zx.es_v,distance=0..,limit=1] at @s run function fallendream:equipment/bow/ember_string/burn

# ③-D 超限: 记下本次走的是哪条分支, 三种在 12 秒内集齐就再打一次 ×0.08 + 随机标签
#   ★ 必须排在 ③-A/③-B **之后** —— 分支走完了才知道这次是哪一种(#es_dbg8 是快照)。
#   ★ 也必须排在 ④ 之前 —— 它要靠 zx.es_v 找到受害者。
execute if score @s zx.es_ol matches 1 run function fallendream:equipment/bow/ember_string/ol_track with storage zx:work es

# ④ 收尾: 清掉本次用过的快照/标的标签
tag @e[tag=zx.es_hadl,distance=0..] remove zx.es_hadl
tag @e[tag=zx.es_hady,distance=0..] remove zx.es_hady
tag @e[tag=zx.es_v,distance=0..] remove zx.es_v
