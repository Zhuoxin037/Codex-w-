# ============================================================
# sweetdream:equipment/staff/renew_fire/skill —— 续火 · 主动技能(潜行右键)
# ------------------------------------------------------------
# 【谁调用它】cast ①(潜行分支)
# 【技能原文】✦ 主动技能   魔力 50 · 冷却 30 秒
#   "使用后恢复自身 8 点生命值。自身生命值为满时无法使用。"
# 【★ "生命值为满时无法使用" 必须排在扣蓝之前 ★】文案是"无法使用", 不是
#   "用了白扣" ⇒ 满血时不扣魔力、也不进冷却, 只给一句红字。
#   (判据: Health 与 max_health 都取整点数比较 —— store result 对 float 会截断,
#    19.99 记为 19 < 20, 不会把"差一丝"误判成满血。)
# 【★ 回血走 lib/heal, 入参是整点 8 ★】
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 满血判定(排在一切扣费之前)
execute store result score #rf_hp zx.meta run data get entity @s Health
execute store result score #rf_mh zx.meta run attribute @s minecraft:max_health get
execute if score #rf_hp zx.meta >= #rf_mh zx.meta run tellraw @s [{"text":"生命值已满，无法使用续火","color":"red"}]
execute if score #rf_hp zx.meta >= #rf_mh zx.meta run return fail

# ③ 只读检查: 魔力 50 + 冷却
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:renew_fire",mana:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"续火冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 50）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ④ 扣魔力 50
data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 50）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:renew_fire",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 恢复 8 点生命值
scoreboard players set #heal_pt zx.meta 8
function sweetdream:lib/heal

# ⑦ 表现: 火苗绕身一圈 + 暖光
execute at @s run particle minecraft:dust{color:[1.0,0.55,0.15],scale:1.2} ~ ~1 ~ 0.5 0.6 0.5 0.02 18 normal
execute at @s run particle minecraft:flame ~ ~0.6 ~ 0.45 0.7 0.45 0.01 14 normal
execute at @s run playsound minecraft:block.campfire.crackle player @a ~ ~ ~ 0.7 1.4
tellraw @s [{"text":"续火点燃（恢复 8 点生命值）","color":"gold"}]
