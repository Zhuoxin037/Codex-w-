# ============================================================
# fallendream:equipment/axe/angel_core/dmg2 —— 第二段: 最大魔力 ×0.08, 重复 2 次
# ------------------------------------------------------------
# 【执行者】施法者
# 【目标】自身 6 格内带「圣痕」的生物 2 格内的全部生物(= 并集, 不重复打同一只)
# 【通道】max_mana_mul(基数 = 面板最大魔力) -> 顺带吃「下一次技能加成」(风声)
# 【收尾】清掉"触发了第二段效果的圣痕" = 6 格内那些做过中心的
# 【谁调用它】core/tick —— cast 放完第一段后给玩家挂 zx.ac_delay + zx.ac_d=10,
#   倒计时走到 0 由每刻钩子调这里(0.5 秒的"技能间隔")。
# ============================================================

# ⓪ ★ 第一件事: 摘掉"延后"标记 ★
#   本函数可能在 ①/② 提前 return, 标记若不在最前面摘掉, core/tick 会**每刻重复调用**它。
tag @s remove zx.ac_delay
scoreboard players reset @s zx.ac_d

# ⓪.5 【超限（2026-11-22）】开「第三段」窗口: 6 秒（+120 刻）
#   文案"之后 6 秒内…"里的"之后"= 第二段结算之后。dmg2 就是第二段，所以窗口在这里
#   开，而不是 cast 里 —— 在 cast 开的话会白送掉这 0.5 秒的间隔。
#   ★ 只有超限档才开 ★ 基础版 zx.ac_rw 保持 0（cast ⓪.6 判 > #now 自然不会进）。
execute if score @s zx.ac_ol matches 1 run scoreboard players operation @s zx.ac_rw = #now manacore.meta
execute if score @s zx.ac_ol matches 1 run scoreboard players add @s zx.ac_rw 120

# ① 中心: 6 格内带「圣痕」的
tag @e[tag=zx.ac_c] remove zx.ac_c
execute at @s run tag @e[type=!#fallendream:no_damage,distance=0.1..6,tag=zx.status.shenghen] add zx.ac_c
execute unless entity @e[tag=zx.ac_c] run return 0

# ② 每个中心的 2 格内全部生物并成 zx.ac_aoe(先清空再收, 免得留上一轮的)
tag @e[tag=zx.ac_aoe] remove zx.ac_aoe
execute at @e[tag=zx.ac_c] run tag @e[type=!#fallendream:no_damage,distance=..2] add zx.ac_aoe
execute unless entity @e[tag=zx.ac_aoe] run return 0

# ②.5 【超限】哪些"中心"带「额外」圣痕 -> 它们 2 格内的生物重复次数 +1
#   文案："有额外「圣痕」的生物被该武器技能锁定时伤害重复的次数 +1"
#   第二段锁定的对象是**中心**（6 格内带圣痕的），所以按中心是否带额外层来分档，
#   再把"带额外层中心"的 2 格范围单独收一份（zx.ac_aoe3），④ 之后补打一次。
#   ★ 用 zx.sh_x 判，不查标签：额外层是计数（0/1），没有专用标签。
tag @e[tag=zx.ac_cx] remove zx.ac_cx
tag @e[tag=zx.ac_aoe3] remove zx.ac_aoe3
execute as @e[tag=zx.ac_c] if score @s zx.sh_x matches 1.. run tag @s add zx.ac_cx
execute at @e[tag=zx.ac_cx] run tag @e[type=!#fallendream:no_damage,distance=..2] add zx.ac_aoe3

# ③ 算伤害: 最大魔力 ×0.08
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tag @e[tag=zx.ac_cx] remove zx.ac_cx
execute unless data storage zx:data self{ok:1b} run tag @e[tag=zx.ac_aoe3] remove zx.ac_aoe3
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ④ 打两次(文案: 重复 2 次)
data modify storage zx:in arg set value {target:"@e[tag=zx.ac_aoe]",read:"manacore"}
# dup-ok: 文案"重复 2 次", 这里刻意打两遍
data modify storage zx:in arg.uncapped set value 1b
execute at @s run function fallendream:internal/attack/api_skill
data modify storage zx:in arg.uncapped set value 1b
execute at @s run function fallendream:internal/attack/api_skill

# ④.5 【超限】带额外「圣痕」的中心, 它 2 格内的生物重复次数 +1（补第 3 次）
execute if entity @e[tag=zx.ac_aoe3,distance=0..,limit=1] run data modify storage zx:in arg set value {target:"@e[tag=zx.ac_aoe3,distance=0..]",read:"manacore"}
data modify storage zx:in arg.uncapped set value 1b
execute if entity @e[tag=zx.ac_aoe3,distance=0..,limit=1] at @s run function fallendream:internal/attack/api_skill

# ⑤ 清除触发了第二段效果的「圣痕」(就是这些中心) —— 连同它的计时一起清(与 status/decay_shenghen 一致)
tag @e[tag=zx.ac_c] remove zx.status.shenghen
scoreboard players reset @e[tag=zx.ac_c] zx.sh_t
scoreboard players reset @e[tag=zx.ac_c] zx.sh_x
execute at @e[tag=zx.ac_c] run particle minecraft:enchant ~ ~1 ~ 0.3 0.3 0.3 0.05 12 normal
# 「圣痕」被引爆: 在每个中心生物脚下升起一道圣光柱(2026-10-08)
#   ★ 必须 `as ... at @s`: beam 里用 `at @s` 定位 —— 只写 `at @e[...]` 的话 @s 还是施法者,
#     光柱会全堆在玩家脚下(RULES 坑 61/62)。
execute as @e[tag=zx.ac_c,distance=0..] at @s run function fallendream:equipment/axe/angel_core/beam
# 【引爆音效 2026-10-08 改版】用户: "音效没有啥感觉, 没力气"。
#   原来这一下是 `block.beacon.deactivate 0.7 1.3` —— 那是**关机**的泄气音, 方向完全反了。
#   现在换成一记重击的三层(响在施法者处 = "我这一下砸出去了"):
#     lightning_bolt.impact(落雷撞击, 低沉) + bell.use(压低的大钟 = 圣/庄严)
#     + generic.explode(爆开, 音高 1.35 收短)
execute at @s run playsound minecraft:entity.lightning_bolt.impact player @a ~ ~ ~ 0.90 0.85
execute at @s run playsound minecraft:block.bell.use player @a ~ ~ ~ 0.90 0.60
execute at @s run playsound minecraft:entity.generic.explode player @a ~ ~ ~ 0.65 1.35

tag @e[tag=zx.ac_c] remove zx.ac_c
tag @e[tag=zx.ac_aoe] remove zx.ac_aoe
tag @e[tag=zx.ac_cx] remove zx.ac_cx
tag @e[tag=zx.ac_aoe3] remove zx.ac_aoe3
