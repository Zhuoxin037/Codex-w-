# ============================================================
# sweetdream:equipment/sword/deepsea_echo/diagnose_go —— 自检正文(宏参数 {uuid})
# ------------------------------------------------------------
# 【怎么读结果】
#   ① = 0        -> 12 格内真的没有生物。右键时聊天栏会提示「附近没有目标」,
#                   这是设计好的行为(不是坏了), 站到生物旁边再试。
#   ② success:1b -> 冷却和魔力都够
#   ③ 魔力       -> 不够 350 会提示「魔力不足」
#   【注意】下面 mana:350.0 只是个"代理值", 必须和 cast 里 api/skill/check 的 mana 保持一致;
#   对不上的话自检结果会骗你(它会拿一个跟技能无关的数字去判定)。
#   ④ 源标记数   -> 右键成功后应该先变成 1; 每推进一波换一批
#                   剩余波数从 3 开始减, 减到 0 就结束
#   ⑤ 渊海       -> 被施加过「渊海」的生物数量(目前只是个标记, 不会消失)
# ============================================================

# ① 12 格内的可锁定目标数
execute store result score #n zx.meta run execute if entity @e[type=!#sweetdream:no_damage,distance=0.1..12]
tellraw @s [{"text":"① 12 格内目标数: ","color":"gray"},{"score":{"name":"#n","objective":"zx.meta"},"color":"white"}]

# ② 技能检查(冷却 + 魔力)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:deepsea_echo",mana:350.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
tellraw @s [{"text":"② 技能检查: ","color":"gray"},{"nbt":"r","storage":"manacore:out","color":"white"}]

# ③ 当前魔力 / 上限
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
tellraw @s [{"text":"③ 魔力: ","color":"gray"},{"nbt":"r.value","storage":"manacore:out"},{"text":" / ","color":"gray"},{"nbt":"r.max","storage":"manacore:out"}]

# ④ 本波的"源"数量 + 剩余波数
$execute store result score #src zx.meta run execute if entity @e[tag=zx.de_$(uuid)]
scoreboard players set #left zx.meta 0
$execute if data storage zx:data de."$(uuid)".left store result score #left zx.meta run data get storage zx:data de."$(uuid)".left
tellraw @s [{"text":"④ 源标记数: ","color":"gray"},{"score":{"name":"#src","objective":"zx.meta"},"color":"aqua"},{"text":"   剩余波数: ","color":"gray"},{"score":{"name":"#left","objective":"zx.meta"},"color":"aqua"}]

# ⑤ 带「渊海」的生物数量
execute store result score #yh zx.meta run execute if entity @e[tag=zx.status.yuanhai]
tellraw @s [{"text":"⑤ 带「渊海」的生物数: ","color":"gray"},{"score":{"name":"#yh","objective":"zx.meta"},"color":"light_purple"}]

tellraw @s [{"text":"读法: ①=0 就是附近真没生物; 右键成功后 ④ 的源标记数应该先变成 1","color":"dark_gray"}]
