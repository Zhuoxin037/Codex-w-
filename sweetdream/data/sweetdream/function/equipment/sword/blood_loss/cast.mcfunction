# ============================================================
# sweetdream:equipment/sword/blood_loss/cast —— 失血 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/blood_loss(consume_item) -> rewards
# 【技能原文】
#   ✦ 心血
#     "「心血」最多 3 层。普通近战命中了附有「噬心」且仍存活的生物后，消耗其
#      「噬心」，并为自身积攒 1 层「心血」。"
#   ✦ 主动技能   魔力 120 · 冷却 24 秒
#     "使用后消耗全部「心血」，对准星前方 5 格内一个生物造成一次相当于自身最大
#      生命值 ×0.35×X 的真实伤害，并为自身恢复最大生命值 5%×X 的生命。X 为本次
#      消耗的「心血」层数。"
# 【★ 剑没有普攻技能 ★】右键只有主动(同盲烛); 所以这里不做潜行分派。
# 【★ 0 层不能用 ★】文案是"消耗**全部**心血" —— 一层都没有时既没有 X 也没有可
#   消耗的东西, 整段等于空放。这里按"放不出来"(提示 + 不扣魔力/不进冷却)处理,
#   与"魔力不足"同一类失败, 玩家不会白付 120。
# 【★ 顺序: 先查层数 / 先射线找目标 -> 再扣费 -> 再结算 ★】
#   射线只读(找 + 打标记), 所以可以排在扣费之前; 找不到目标就整段不发生。
# 【前缀】zx.bld_* / #bld_* / zx:work bld —— 定名前全树 grep:
#   zx.bl_* 已被「脑水蛭」(brain_leech) 占用, 所以失血用 bld_(坑 167)。
# ============================================================

# ⓪ 撤销自己的进度(自撤销型进度首行必须 revoke)
advancement revoke @s only sweetdream:equipment/sword/blood_loss

# ① 血够不够: 0 层直接放不出来
scoreboard players add @s zx.bld_n 0
execute if score @s zx.bld_n matches ..0 run tellraw @s [{"text":"「心血」不足，先用近战命中附有「噬心」的生物积攒","color":"red"}]
execute if score @s zx.bld_n matches ..0 run return fail

# ② 拿 uuid + 只读检查(冷却 24 秒 / 魔力 120)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:blood_loss",mana:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"失血冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 120）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 沿准星找"前方 5 格内的一个生物"(只读; 命中者打 zx.bld_tgt)
#   ★★ 射线步数必须每次归零 ★★ `#bld_st` 是递归用的计数器, 上一轮跑到 11 之后
#   没人清它 —— 不归零的话第二次施法第一行就 `matches 11..` 立刻收工,
#   表现是"只有第一次能放出技能"(静默、零日志)。
#   ★★ 必须 `anchored eyes` 起头 ★★ 默认锚点是**脚底**, 从脚底往前射会立刻撞到
#   脚下那格方块就地收工 ⇒ 永远找不到目标(同沉锚 anchor/cast 的写法)。
scoreboard players set #bld_st zx.meta 0
tag @e[tag=zx.bld_tgt,distance=0..] remove zx.bld_tgt
execute anchored eyes run function sweetdream:equipment/sword/blood_loss/ray

# ④ 一个都没瞄到 -> 提示并收工(不扣魔力/不进冷却)
execute unless entity @e[tag=zx.bld_tgt,distance=0..] run tellraw @s [{"text":"准星前方 5 格内没有生物","color":"red"}]
execute unless entity @e[tag=zx.bld_tgt,distance=0..] run return fail

# ⑤ 扣魔力 -120
data modify storage manacore:in arg set value {uuid:"",value:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return fail

# ⑥ 记冷却 24 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:blood_loss",cooldown_seconds:24.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑦ 算伤害: 最大生命值 ×0.35×X
#   ★ 走 calc 的 health_ratio(生命项, 见 manacore:api/damage/calc 的字段表) ★
#   health_ratio 是 double, 而 0.35×X 是动态的 ⇒ 先用计分板算 35×X, 再按 0.01 缩放写回。
scoreboard players set #bld_r zx.meta 35
scoreboard players operation #bld_r zx.meta *= @s zx.bld_n
data modify storage manacore:in arg set value {uuid:"",health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.health_ratio double 0.01 run scoreboard players get #bld_r zx.meta
function manacore:api/damage/calc

# ⑧ 打真伤(只打射线锁定的那一只)
data modify storage zx:in arg set value {target:"@e[tag=zx.bld_tgt,distance=0..,limit=1]",damage:0.0,type:"sweetdream:true_damage"}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ⑨ 回血 5%×X
execute store result score #heal_pt zx.meta run attribute @s minecraft:max_health get
scoreboard players set #bld_pct zx.meta 5
scoreboard players operation #bld_pct zx.meta *= @s zx.bld_n
scoreboard players operation #heal_pt zx.meta *= #bld_pct zx.meta
scoreboard players operation #heal_pt zx.meta /= #100 zx.meta
function sweetdream:lib/heal

# ⑩ 消耗全部「心血」
scoreboard players set @s zx.bld_n 0

# ⑪ 表现: 一束血色从准星那一点抽回来
execute at @e[tag=zx.bld_tgt,distance=0..,limit=1] run particle minecraft:dust{color:[0.6,0.02,0.05],scale:1.8} ~ ~1 ~ 0.5 0.7 0.5 0.03 22 normal
execute at @e[tag=zx.bld_tgt,distance=0..,limit=1] run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.8 0.7
execute at @s run playsound minecraft:item.trident.return player @a ~ ~ ~ 0.6 1.2

# ⑫ 收尾
tag @e[tag=zx.bld_tgt,distance=0..] remove zx.bld_tgt
