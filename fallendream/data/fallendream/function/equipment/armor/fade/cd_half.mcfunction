# ============================================================
# fallendream:equipment/armor/fade/cd_half —— 超限·息影: 手持技能冷却减半（至少 -10 秒）
# ------------------------------------------------------------
# 【执行者】玩家（go 已取好 lib/uuid，zx:data self.uuid 可用；主手确有 custom_data.skill）
# 【文案】"使当前手持装备冷却时间减半（至少减少 10 秒）"
# 【算法】remaining = api/cooldown/get；to_reduce = max(remaining ÷ 2, 200 刻)
#   · 减半 = remaining ÷ 2（整数除法）
#   · 至少 10 秒 = 200 刻，用 revive 夹下界（remaining 很小时按 200 减，api 会减到就绪）
#   · ★ 不写乘法，只做 除法 + 取较大，天然不溢出（无需 R05 上界保护）
# ============================================================

# ① 读手持技能 id
data modify storage zx:work fd.skill set from entity @s SelectedItem.components."minecraft:custom_data".skill

# ② 读该技能剩余冷却
data modify storage manacore:in arg set value {uuid:"",skill:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from storage zx:work fd.skill
function manacore:api/cooldown/get
scoreboard players set #fd_rem zx.meta 0
execute store result score #fd_rem zx.meta run data get storage manacore:out r.remaining
execute if score #fd_rem zx.meta matches ..0 run return 0

# ③ to_reduce = max(remaining/2, 200)
scoreboard players set #fd_2 zx.meta 2
scoreboard players operation #fd_reduce zx.meta = #fd_rem zx.meta
scoreboard players operation #fd_reduce zx.meta /= #fd_2 zx.meta
scoreboard players set #fd_200 zx.meta 200
execute if score #fd_reduce zx.meta < #fd_200 zx.meta run scoreboard players operation #fd_reduce zx.meta = #fd_200 zx.meta

# ④ reduce（ticks）
data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from storage zx:work fd.skill
execute store result storage manacore:in arg.ticks int 1 run scoreboard players get #fd_reduce zx.meta
function manacore:api/cooldown/reduce

# ★ 兑现减半也是"息影提供的减冷却"：该技能的下一次伤害 +10% + 附随机标签
tag @s add zx.fd_next
