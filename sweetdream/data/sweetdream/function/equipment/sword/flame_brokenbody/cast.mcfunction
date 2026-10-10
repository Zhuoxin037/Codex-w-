# ============================================================
# sweetdream:equipment/sword/flame_brokenbody/cast —— 主动技能(右键)
# ------------------------------------------------------------
# 【文案】消耗 350 魔力 / 冷却 12 秒。
#   使用后对前方 5*3 范围内的生物造成一次"自身最大魔力值 ×0.1"的伤害;
#   若攻击到的生物附有「夜火」, 则该技能冷却时间立即结束, 且每有一个「夜火」
#   则吸收并为自身积攒一点「熔浆」。
#   若自身释放技能时「熔浆」大于或等于 4 层, 则本次技能强化为:
#   对前方 5*3 范围内的生物造成**两次** ×0.1 的伤害, 之后再对自身 6 格内的生物
#   造成 ×0.2 的伤害, 之后清除「熔浆」。
#
# 【顺序】先判定"熔浆够不够"(强化与否) -> 再打伤害 -> 最后处理夜火(刷冷却 + 吸收)
#   -> 如果这次是强化, 收尾清空熔浆。
#   (文案说"本次伤害强化为", 所以是替换, 不是打两次基础伤害)
# 【"前方 5*3"怎么落地】用一个立方体近似: 视线前 2.0 格开一个 4.4 的盒子
#   —— 打出来就是"眼前一大片"。⚠️ 用 dx/dy/dz 盒子判定(生物的判定箱相交),
#   不用 distance(distand 量的是到脚底的距离, 站在地上的怪会判不到)。
# 【先 add 0】熔浆这项计分项要先存在, 不然 `if score` 判不出来(引梦镰的 8 秒锁栽过)。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/sword/flame_brokenbody

# ① 拿 uuid + 把熔浆计分项建出来
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
scoreboard players add @s zx.fb_lava 0

# ①.2 ★ 超限快照 ★ 整段技能都在这一个函数里跑完(没有延迟结算), 所以用假玩家
#      就够, 不用往玩家身上存。
#      【超限·"烈火，残躯" 加在这把上的机制(逐字照抄 oldef."flame_brokenbody".lore)】
#        触发条件从"附有「夜火」"放宽成"附有「流火」或「夜火」",
#        并且若有「流火」则**转化**为「夜火」(替换, 见 torchify)。
function sweetdream:equipment/sword/flame_brokenbody/is_ol

# ② 只读检查: 冷却 + 魔力 350
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:flame_brokenbody",mana:350.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"烈火，残躯 冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 350)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 350
data modify storage manacore:in arg set value {uuid:"",value:350.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 350)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 12 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:flame_brokenbody",cooldown_seconds:12.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 圈出前方 5*3 里的生物
tag @e[tag=zx.fb_hit] remove zx.fb_hit
execute anchored eyes positioned ^ ^ ^2.0 positioned ~-2.2 ~-1.3 ~-2.2 run tag @e[type=!#sweetdream:no_damage,dx=4.4,dy=2.6,dz=4.4] add zx.fb_hit

# ⑥ 判定强化: 释放时熔浆 >= 4 层
scoreboard players set #fb_enh zx.meta 0
execute if score @s zx.fb_lava matches 4.. run scoreboard players set #fb_enh zx.meta 1

# ⑦ 打伤害(强化与否只跑其中一个)
execute if score #fb_enh zx.meta matches 0 run function sweetdream:equipment/sword/flame_brokenbody/dmg
execute if score #fb_enh zx.meta matches 1 run function sweetdream:equipment/sword/flame_brokenbody/dmg_enh

# ⑧ 先记"这次该不该刷冷却": 圈里有「夜火」(基础版就有的条件),
#    超限版再加一条「流火」(超限文案: 攻击到的生物附有「流火」**或**「夜火」)。
#    ★ 为什么单独记: 冷却刷新要覆盖"只有流火、一个夜火都没有"的情况 ——
#      那种情况下 ⑧-1 的 night 根本不会跑, 冷却就漏刷了。
scoreboard players set #fb_cd zx.meta 0
execute as @e[tag=zx.fb_hit] if entity @s[tag=zx.status.yehuo] run scoreboard players set #fb_cd zx.meta 1
execute if score #fb_ol zx.meta matches 1 as @e[tag=zx.fb_hit] if entity @s[tag=zx.status.liuhuo] run scoreboard players set #fb_cd zx.meta 1

# ⑧-1 吸收圈里**原本就有**的「夜火」: 每有一个积 1 点熔浆, 然后把它们消耗掉
tag @e[tag=zx.fb_night] remove zx.fb_night
execute as @e[tag=zx.fb_hit] if entity @s[tag=zx.status.yehuo] run tag @s add zx.fb_night
execute if entity @e[tag=zx.fb_night] run function sweetdream:equipment/sword/flame_brokenbody/night

# ⑧-2 【超限】把圈里剩下的「流火」转成「夜火」—— **只转化, 本次不吸收**
#   ★ 2026-10-08 改(玩家口径): 原来是"转化完立刻一起吸收 + 积熔浆",
#     现在改成只转化。转化出来的这批夜火留着, **下一次**技能才会被吸收。
#     实现上就是把 torchify 从"挑夜火之前"挪到"吸收之后"。
execute if score #fb_ol zx.meta matches 1 run function sweetdream:equipment/sword/flame_brokenbody/torchify

# ⑧-3 命中带「流火」或「夜火」-> 该技能冷却时间立即结束(统一在这里刷, night 里不再刷)
execute if score #fb_cd zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:flame_brokenbody"}
execute if score #fb_cd zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #fb_cd zx.meta matches 1 run function manacore:api/cooldown/reset

# ⑨ 强化的收尾: 清空熔浆
execute if score #fb_enh zx.meta matches 1 run scoreboard players set @s zx.fb_lava 0

# ⑩ 表现: 火光 + 热浪
execute anchored eyes positioned ^ ^ ^2.0 run particle minecraft:flame ~ ~ ~ 2.2 1.0 2.2 0.05 45 normal
execute anchored eyes positioned ^ ^ ^2.0 run particle minecraft:large_smoke ~ ~ ~ 1.8 0.8 1.8 0.02 20 normal
execute anchored eyes positioned ^ ^ ^2.0 run particle minecraft:lava ~ ~ ~ 1.6 0.7 1.6 0 15 normal
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.9 0.9
execute if score #fb_enh zx.meta matches 1 run playsound minecraft:entity.generic.explode player @a ~ ~ ~ 0.7 1.2

tag @e[tag=zx.fb_hit] remove zx.fb_hit
