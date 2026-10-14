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
# 动作进行中不重复扣费、覆盖目标或追加伤害。
execute if entity @s[tag=zx.fb_cast] run return 0

# ① 拿 uuid + 把熔浆计分项建出来
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
scoreboard players add @s zx.fb_lava 0

# ①.2 超限状态冻结到本人的计分项，后续命中不重读武器。
#      【超限·"烈火，残躯" 加在这把上的机制(逐字照抄 oldef."flame_brokenbody".lore)】
#        触发条件从"附有「夜火」"放宽成"附有「流火」或「夜火」",
#        并且若有「流火」则**转化**为「夜火」(替换, 见 torchify)。
function sweetdream:equipment/sword/flame_brokenbody/is_ol
scoreboard players operation @s zx.fb_ol = #fb_ol zx.meta

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




# ⑤ 圈出前方 5×3；与引梦镰一样按 UUID 保存本次目标，不留跨刻共享标签。
tag @e[tag=zx.fb_hit,distance=0..] remove zx.fb_hit
execute anchored eyes positioned ^ ^ ^2.0 positioned ~-2.2 ~-1.3 ~-2.2 run tag @e[type=!#sweetdream:no_damage,dx=4.4,dy=2.6,dz=4.4] add zx.fb_hit
data modify storage zx:fbcombat record set value {targets:[]}
execute as @e[tag=zx.fb_hit,distance=0..] run function sweetdream:equipment/sword/flame_brokenbody/combat/collect
function sweetdream:equipment/sword/flame_brokenbody/combat/context
function sweetdream:equipment/sword/flame_brokenbody/combat/save with storage zx:fbcombat ctx
tag @e[tag=zx.fb_hit,distance=0..] remove zx.fb_hit

# ⑥ 本次强化只看释放时的熔浆；动画和三段伤害共同读取本人的 mode。
scoreboard players set #fb_enh zx.meta 0
execute if score @s zx.fb_lava matches 4.. run scoreboard players set #fb_enh zx.meta 1
function sweetdream:equipment/sword/flame_brokenbody/visual/start

# ⑩ 起势只播声音；伤害和爆焰由命中帧触发。
playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.9 0.9
