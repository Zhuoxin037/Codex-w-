# ============================================================
# sweetdream:equipment/armor/lethe_shore/passive —— 沉溺忘川彼岸: 被动(每秒)
# ------------------------------------------------------------
# 【谁调用它】second -> execute as @a
# 【文案】
#   ① 自身魔力值上限 +180。
#   ② 自身攻击了 8 次生物后进入「残念」, 持续 3 秒(攻击计数见 hit)。
#   ③ 残念期间: 每秒恢复 20 魔力值 + 基础速度翻倍。
#   ④ 解除残念时的爆发见 end_lethe。
#   ⑤ 进入残念所需攻击次数可被削到最低 3, 20 秒内没再触发就重置回 8。
# 【为什么对全部玩家跑】魔力上限是差值账本, 摘下那一秒得有人把 +180 减回去
#   (炉心/漫步冥河同款定式)。
# ============================================================

# ① 拿 UUID
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 自己穿了吗(沉溺忘川是下界合金靴子, 槽位 armor.feet)
scoreboard players set #on zx.meta 0
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["lethe_shore"]}] run scoreboard players set #on zx.meta 1

# ③ 魔力上限 +180(差值账本)
scoreboard players set #want zx.meta 0
execute if score #on zx.meta matches 1 run scoreboard players add #want zx.meta 180
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.lt_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/lethe_shore/apply_mana

# ④ 脱下 -> 静默清掉残念(不触发解除爆发 —— "脱下"不是"自然解除")
execute unless score #on zx.meta matches 1 if entity @s[tag=zx.lethe] run function sweetdream:equipment/armor/lethe_shore/clear

# ⑤ 残念到期(3 秒) -> 解除结算
#   ★ 排在 ④ 之后: 已经因摘下清掉的不会再走这里
execute if score #on zx.meta matches 1 if entity @s[tag=zx.lethe] if score @s zx.lt_end <= #now manacore.meta run function sweetdream:equipment/armor/lethe_shore/end_lethe

# ⑥ 残念期间: 每秒回 20 魔力
#   ★ 排在 ⑤ 之后 —— end_lethe 已经把 tag 摘了, 到期的这一秒不再回魔
#     (回魔是"在此状态下"的, 状态结束的那一秒不该再吃一次)
scoreboard players set #lt_regen zx.meta 0
execute if entity @s[tag=zx.lethe] run scoreboard players set #lt_regen zx.meta 20
execute if score #lt_regen zx.meta matches 1.. run scoreboard players operation @s zx.regen_extra += #lt_regen zx.meta
execute if score #lt_regen zx.meta matches 1.. run function sweetdream:equipment/armor/lethe_shore/regen

# ⑦ 攻击次数阈值的 20 秒重置窗口
#   文案: "…所需攻击次数 -1(最低为 3), 直至 20 秒内未触发该被动。"
#   zx.lt_reset 存"窗口到期时刻"; 到点就说明 20 秒没再触发 -> 阈值复位回 8。
execute if score @s zx.lt_reset matches 1.. if score @s zx.lt_reset <= #now manacore.meta run scoreboard players set @s zx.lt_need 8
execute if score @s zx.lt_reset matches 1.. if score @s zx.lt_reset <= #now manacore.meta run scoreboard players set @s zx.lt_reset 0
