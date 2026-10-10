# ============================================================
# sweetdream:equipment/bow/cold_crow/ol_refill —— 超限·寒鸦 · 第 4 发打完后的「冰凌」回填
# ------------------------------------------------------------
# 【技能原文(超限, 必须和这里对上)】
#   "「冰凌」到达 4 层并射击后若自身魔力值大于 150，则消耗 120 魔力值并使「冰凌」
#    恢复至 3 层。"
# 【谁调用它】cold_crow/shot 的 ⑤ —— 只有"这一发是第 4 层"(#tier=4)才进得来。
# 【默认行为】非超限 = 打完第 4 层清空冰凌(和改之前一字不差)。
# 【超限行为】手持的弩带 custom_data.ol="cold_crow" 时, 若**射击后**的当前魔力 > 150,
#   就再扣 120 点, 并把冰凌设回 3 层 —— 下一发又是第 4 层, 只要蓝够就能连续满层。
# 【★ "射击后"的口径】shot 的 ② 已经先扣掉这一发的 320(4 层价), 所以这里读到的
#   魔力就是"扣完 320 之后"的余额 ⇒ 打第 4 发之前需要 ≥ 440 才会触发回填。
# 【★ 时序 ★】本文件在 shot 的 ⑤ 被调, 而 model/on_shot 与 apocalypse/spend 都排在
#   ⑤ 之后 —— 所以模型/LED 读到的冰凌已经是回填后的值, 不需要额外同步。
# ============================================================

# ① 默认: 第 4 层用掉 -> 清空(超限若不满足条件, 结果也是这个)
scoreboard players set @s zx.cc_ice 0

# ② 只有超限版寒鸦才可能回填(玩家物品 NBT 只读, 这里只"读"不"写", 安全)
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{ol:"cold_crow"}] run return 0

# ③ 读当前魔力, 必须 > 150
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #cc_m zx.meta run data get storage manacore:out r.value 1
execute if score #cc_m zx.meta matches ..150 run return 0

# ④ 再消耗 120 魔力(在 320 之外)
data modify storage manacore:in arg set value {uuid:"",value:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return 0

# ⑤ 「冰凌」恢复至 3 层(下一发 = 第 4 层)
scoreboard players set @s zx.cc_ice 3

# ⑥ 表现: 一层霜气回卷(与 shot 里第 4 发的破冰声区分开)
execute at @s run particle minecraft:snowflake ~ ~1.2 ~ 0.6 0.5 0.6 0.03 20 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.6 1.6
