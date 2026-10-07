# ============================================================
# sweetdream:equipment/sword/remelt/cast —— 热熔: 开启「熔解」状态
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/remelt 的奖励函数(右键消耗时, 玩家身份)
# 【文案】消耗 500 魔力 / 冷却 80 秒。
#   使用后每攻击一次都会同步使自身 8 格内带有「夜火」的生物受到"基础攻击力 ×2"的伤害,
#   之后使其护甲值归 0, 持续 10 秒。
# 【状态怎么记】zx.rm_on = 还剩几秒(每秒由 second 扣)。
#   文案没写状态本身持续多久, 取"与融甲同为 10 秒"(合理默认, 已写进使用教程)。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/sword/remelt

# ① 拿 uuid + 把状态计分项建出来(没分数的目标 matches 判不出来)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
scoreboard players add @s zx.rm_on 0

# ② 只读检查: 冷却 + 魔力 500
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:remelt",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"热熔冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 500)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 500
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 500)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 80 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:remelt",cooldown_seconds:80.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 进入熔解状态 10 秒
scoreboard players set @s zx.rm_on 10

# ⑥ 表现(不出聊天提示, 只给画面和声音)
execute at @s run particle minecraft:lava ~ ~1 ~ 1.6 0.7 1.6 0.02 24 normal
execute at @s run particle minecraft:flame ~ ~1 ~ 1.2 0.6 1.2 0.03 30 normal
execute at @s run playsound minecraft:block.lava.extinguish player @a ~ ~ ~ 0.9 0.9
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.8 0.8
