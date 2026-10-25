# ============================================================
# sweetdream:equipment/axe/frost_carve/ol_wing —— 超限·剜霜 的「披霜」
# ------------------------------------------------------------
# 【谁调用它】cast ⑩.5(只在"本次解除冰冻 ≥2 只"时)   【执行者】施法者
# 【设计原文】
#   "若本次至少解除了两个生物的冰冻，则为自身恢复最大生命值 20% 的生命，
#    之后为自身附加 3 层持续 12 秒的「披霜」。自身每受到一次伤害则自身消耗一层
#    「披霜」并使攻击自己的生物及其 3 格内的全部生物冰冻 2 秒。"
# 【为什么层数与时长分成两个计分项】
#   · zx.frc_fr = 层数(0..3) —— 受击时消耗的就是它;
#   · zx.frc_ft = 剩余秒数(12..0) —— 由 lib/second 每秒 -1, 归零无条件清层。
#   文案写的是"3 层持续 12 秒"(一份时长), 不是"每层各 12 秒"。
# 【为什么必须判 zx:work frc.ol】apply 中间会调 api/damage, 那条链上的 hook 会动
#   #字头假玩家(比如 #frc_ol) —— 所以超限标记留在 cast 写好的私有 storage 里,
#   这里只读 storage, 不读计分项。
# ============================================================

# ⓪ 不是超限版 -> 什么都不做(常态剜霜没有「披霜」这一层)
execute unless data storage zx:work frc{ol:1} run return 0

# ① 3 层 + 12 秒
scoreboard players set @s zx.frc_fr 3
scoreboard players set @s zx.frc_ft 12

# ② 表现
execute at @s run particle minecraft:snowflake ~ ~1.2 ~ 0.6 0.6 0.6 0.03 24 normal
execute at @s run playsound minecraft:block.powder_snow.step player @a ~ ~ ~ 0.6 1.6
tellraw @s [{"text":"剜霜: 获得 3 层「披霜」(12 秒)","color":"aqua"}]
