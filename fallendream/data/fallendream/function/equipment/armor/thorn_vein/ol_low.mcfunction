# ============================================================
# fallendream:equipment/armor/thorn_vein/ol_low —— 超限·刺纹: <30% 血的额外收益
# ------------------------------------------------------------
# 【谁调用它】thorn_vein/hit/victim_body ⑤.5（条件已判: 超限 + 自身 <30% 血）
# 【执行者】玩家（@s）
# 【前置】调用方已把"它 3 格内的其他生物(最多 2 只、未带噬心、排除本体)"
#         打了临时标 zx.tv_new
# 【文案(lore 逐字)】…若自身生命值低于最大生命值的 30%，则额外使其 3 格内的
#   其他 2 个生物获得「噬心」，且自身恢复 1% 魔力值，效果冷却时间缩短至 6 秒。
#   （"冷却缩短至 6 秒"已由调用方按档记账, 这里不重复处理）
# ============================================================

# ① 给候选批量附「噬心」（tag/mark 内部是 `as $(target)`, 多目标逐个跑）
data modify storage zx:work ic set value {target:"@e[tag=zx.tv_new]",mark:"shixin"}
function fallendream:tag/mark with storage zx:work ic

# ①.5 摘临时标（不管有没有挂上, 都不能把这批标留到下一次）
tag @e[tag=zx.tv_new,distance=0..] remove zx.tv_new

# ② 自身恢复 1% 魔力值（读面板上限 ×1000 再 ÷100 => 就是 1%, 只做除法不会溢出）
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #tv_mm zx.meta 0
execute store result score #tv_mm zx.meta run data get storage manacore:out r.value 1000
scoreboard players set #tv_p zx.meta 0
scoreboard players operation #tv_p zx.meta = #tv_mm zx.meta
scoreboard players operation #tv_p zx.meta /= #100 zx.meta
execute if score #tv_p zx.meta matches ..0 run return 0
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #tv_p zx.meta
function manacore:api/mana/add

# ③ 一点反馈
execute at @s run particle minecraft:item{item:{id:"minecraft:pointed_dripstone",count:1}} ~ ~1.2 ~ 0.5 0.5 0.5 0.03 14 normal
