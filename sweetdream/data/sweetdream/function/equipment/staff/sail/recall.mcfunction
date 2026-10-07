# ============================================================
# sweetdream:equipment/staff/sail/recall —— "再次使用技能": 把被记录的生物拽到身边
# ------------------------------------------------------------
# 【谁调用它】sail/skill 第 ③ 步(旋风进行中再按技能); 【执行者】施法玩家
# 【技能原文(lore 逐字)】期间自身可以再次使用技能来将该生物召唤至自身处，持续 15 秒。
#   若自身召唤了该生物则技能缩短 3 秒。
# 【口径】再次使用**不再花蓝、不再起新冷却**(它依附在已经放出去的旋风上);
#   "技能缩短 3 秒"按**冷却缩短 3 秒**实现(api/cooldown/reduce, 减的是本技能当前冷却)。
#   被记录的生物不在 -> 不成立(给提示)。
# ============================================================

# ① 找"被记录的生物"
data modify storage zx:work slu set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work slu.u0 int 1 run scoreboard players get @s zx.sl_u0
execute store result storage zx:work slu.u1 int 1 run scoreboard players get @s zx.sl_u1
execute store result storage zx:work slu.u2 int 1 run scoreboard players get @s zx.sl_u2
execute store result storage zx:work slu.u3 int 1 run scoreboard players get @s zx.sl_u3
function sweetdream:equipment/staff/sail/find_rec with storage zx:work slu
execute unless entity @e[tag=zx.sl_found,distance=0..,limit=1] run tellraw @s [{"text":"被记录的生物已经不在了","color":"red"}]
execute unless entity @e[tag=zx.sl_found,distance=0..,limit=1] run return fail

# ② 拽到自身处
execute at @s run tp @e[tag=zx.sl_found,distance=0..,limit=1] ~ ~ ~

# ③ 技能冷却 -3 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sail",seconds:3.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/reduce

# ④ 表现 + 清理临时标记
execute at @e[tag=zx.sl_found,distance=0..,limit=1] run particle minecraft:cloud ~ ~1 ~ 0.5 0.5 0.5 0.05 16 normal
execute at @s run playsound minecraft:entity.enderman.teleport player @a ~ ~ ~ 0.7 1.3
tag @e[tag=zx.sl_found,distance=0..] remove zx.sl_found
