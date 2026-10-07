# ============================================================
# sweetdream:equipment/sword/liuguang/diagnose —— 流光自检(以玩家身份执行)
# ------------------------------------------------------------
# 【用法】/function sweetdream:equipment/sword/liuguang/diagnose
# 【它打印】技能流程里每一步的中间值, 用来定位"右键没反应"卡在哪:
#   ① UUID 有没有取到(casual 失败点: 玩家还没注册完)
#   ② 冷却/魔力检查返回了什么
#   ③ 8 格内到底有几个可锁定目标
#   ④ 当前魔力
#   ⑤ 伤害算出来是多少
# 【注意】它只读不改: 不扣蓝、不进冷却、不打伤害。
# ============================================================

tellraw @s [{"text":"========== 流光自检 ==========","color":"gold"}]

# ① UUID
function sweetdream:lib/uuid
tellraw @s [{"text":"① uuid = ","color":"gray"},{"nbt":"self.uuid","storage":"zx:data","color":"white"},{"text":"   ok = ","color":"gray"},{"nbt":"self.ok","storage":"zx:data","color":"yellow"}]

# ② 冷却 + 魔力检查
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:liuguang",mana:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
tellraw @s [{"text":"② 技能检查 = ","color":"gray"},{"nbt":"r","storage":"manacore:out","color":"white"}]

# ③ 8 格内的可锁定目标数量
execute store result score #n zx.meta run execute if entity @e[type=!#sweetdream:no_damage,distance=0.1..8]
tellraw @s [{"text":"③ 8 格内可锁定目标数 = ","color":"gray"},{"score":{"name":"#n","objective":"zx.meta"},"color":"white"}]

# ④ 当前魔力
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
tellraw @s [{"text":"④ 魔力 = ","color":"gray"},{"nbt":"r.value","storage":"manacore:out"},{"text":" / ","color":"gray"},{"nbt":"r.max","storage":"manacore:out"}]

# ⑤ 伤害预览(攻击力 x2)
data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
tellraw @s [{"text":"⑤ 伤害(攻击力x2) = ","color":"gray"},{"nbt":"r.damage","storage":"manacore:out","color":"gold"}]

tellraw @s [{"text":"正常的话: ①有 uuid 且 ok=1b, ②success=1b, ③至少 1, ④>=20","color":"dark_gray"}]
