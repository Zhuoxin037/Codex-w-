# ============================================================
# sweetdream:equipment/axe/meteor/cast —— 陨星: 进入「熔星」形态
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/meteor 的奖励函数(右键消耗时, 玩家身份)
# 【文案】消耗 300 魔力 / 冷却 30 秒。使用后攻击间隔大幅度缩小, 且被动概率
#   提升为 50%, 持续 10 秒。期间若切换主手武器则该效果失效。
# 【"攻击间隔大幅度缩小"怎么实现】给 minecraft:attack_speed 挂一个
#   add_multiplied_base 2.0 的 modifier -> 攻速 4.0 变 12.0(攻击间隔 0.5 秒 -> 1/6 秒)。
#   挂上/摘下都写在自己身上, 到点或换手由 meteor/second / meteor/tick 收。
# 【状态存哪】zx.mt_on = 还剩几秒(每秒由 second 扣)。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/meteor

# ⓪.5 【必须主手】(2026-10-08 修) —— tick/second 那边只认主手, 副手放的话会
#      "全额付费(300 蓝 + 30 秒冷却)后约 1 tick 被 end 撤销"。这里先挡掉。
#      ★ 这是"触发键"的判定, **不**受超限的"换手仍生效"影响(超限只让形态撑住, 不能让副手放)。
execute unless items entity @s weapon.mainhand diamond_axe[minecraft:custom_data~{zx:["meteor"]}] run return fail

# ⓪.6 这一次是不是超限版(主手这把带 ol:"meteor")
#   ★ 超限版多了"期间若切换主手武器则被动和主动仍旧生效" ⇒ 记 zx.mt_keep=1,
#     tick 见到它就跳过"没握就 end", hit 见到它就跳过武器门控。★ 只有触发键判手持。
scoreboard players set @s zx.mt_keep 0
execute if items entity @s weapon.mainhand diamond_axe[custom_data~{ol:"meteor"}] run scoreboard players set @s zx.mt_keep 1

# ① 拿 uuid + 先把状态计分项建出来(没分数的目标 matches 判不出来)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
scoreboard players add @s zx.mt_on 0

# ② 只读检查: 冷却 + 魔力 300 / 超限 400
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:meteor",mana:300.0}
execute if score @s zx.mt_keep matches 1 run data modify storage manacore:in arg.mana set value 400.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"陨星冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if score @s zx.mt_keep matches 0 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 300)","color":"red"}]
execute if score @s zx.mt_keep matches 1 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 400)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 300 / 超限 400
data modify storage manacore:in arg set value {uuid:"",value:300.0}
execute if score @s zx.mt_keep matches 1 run data modify storage manacore:in arg.value set value 400.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 30 秒 / 超限 35 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:meteor",cooldown_seconds:30.0,reduce:1b}
execute if score @s zx.mt_keep matches 1 run data modify storage manacore:in arg.cooldown_seconds set value 35.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 进入熔星形态 10 秒 / 超限 12 秒
scoreboard players set @s zx.mt_on 10
execute if score @s zx.mt_keep matches 1 run scoreboard players set @s zx.mt_on 12

# ⑥ 攻速倍率(大幅度缩小攻击间隔)
attribute @s minecraft:attack_speed modifier remove sweetdream:meteor
attribute @s minecraft:attack_speed modifier add sweetdream:meteor 2.0 add_multiplied_base

# ⑦ 表现
execute at @s run particle minecraft:flame ~ ~1 ~ 1.4 0.8 1.4 0.04 30 normal
execute at @s run particle minecraft:lava ~ ~1 ~ 0.8 0.5 0.8 0.0 12 normal
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.9 0.7
execute at @s run playsound minecraft:entity.blaze.shoot player @a ~ ~ ~ 0.7 1.2
