# ============================================================
# sweetdream:equipment/armor/armor_hp/passive —— 重算"该有多少生命上限加成"
# ------------------------------------------------------------
# 【执行者】每个玩家（second 用 `as @a` 送进来）
# 【入参/出参】#want = 本秒该有的总加成；与账本 @s zx.ah_hp 比差值 -> apply
# 【口径(逐字对 lore)】
#   · 沸痕(胸甲) +4
#   ★ 每加一件，往 ① 里加一行 + 在注释里补一行；账本是差值制的，不必改别处。
# 【★ 生命上限要改两个地方 ★】(同 external_power/apply_hp 的说明)
#   ① 面板 max_health（技能伤害公式读它）
#   ② 原版属性 minecraft:max_health（真正的血条长度）
#   只有面板变了是"账本好看而已"，血条不会变长。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ---- ① 各件加成 ----
scoreboard players set #want zx.meta 0
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["boil_trace"]}] run scoreboard players add #want zx.meta 4
# ---- 批 15-4(2026-10-16): 绯缝(胸甲) +4 ----
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["crimson_seam"]}] run scoreboard players add #want zx.meta 4
# ---- 批 14(2026-10-25): 剖面(护腿) +6 ----
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["profile"]}] run scoreboard players add #want zx.meta 6

# ---- ② 与账本比差值（差值制：换装那一秒自动补/退） ----
#   ★ 先 `add 0` 把没分数的玩家补成 0 —— 计分项"没分数"时 `if score` 判**不成立**,
#     不能靠"没分数"表达"没加过"(那样第一次永远加不上)。
scoreboard players add @s zx.ah_hp 0
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.ah_hp
execute if score #diff zx.meta matches 0 run return 0

# ---- ③ 面板 max_health 加差值 ----
data modify storage manacore:in arg set value {uuid:"",key:"max_health",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# ---- ④ 原版属性：先按旧账摘，再按新账加 ----
#   ★ 旧账为 0 时**不能** remove —— 没挂过的 modifier 去 remove 会失败,
#     而失败会**截断整个函数**(后面都不跑)。所以两处都带门控。
execute if score @s zx.ah_hp matches 1.. run attribute @s minecraft:max_health modifier remove sweetdream:eqp_ah_hp
scoreboard players operation @s zx.ah_hp += #diff zx.meta
execute store result storage zx:work ah.amt int 1 run scoreboard players get @s zx.ah_hp
execute if score @s zx.ah_hp matches 1.. run function sweetdream:equipment/armor/armor_hp/apply with storage zx:work ah
