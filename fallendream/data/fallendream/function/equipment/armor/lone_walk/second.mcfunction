# ============================================================
# fallendream:equipment/armor/lone_walk/second —— 「独行」每秒结算
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】魔力 +120（armor_mana 登记）/ 移速 +8%；8 格内敌对 ≤2 → 技能伤害 +8%；
#   套装（+空营）：8 格内敌对数量**变化**时 → 4 秒「临敌」（护甲 +4 / 技能伤害 +10% 独立），
#   每 16 秒最多一次。
# 【★ 移速只挂一次 ★】穿上的第一秒挂 0.08，之后靠账本 zx.lw_spd 跳过。
# 【★ 「临敌」是"变化"触发 ★】zx.lw_last 记上秒数量；第一次跑只记基线不触发。
# ============================================================

execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["lone_walk"]}] run function fallendream:equipment/armor/lone_walk/off
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["lone_walk"]}] run return 0

# ① 移速 +8%（只挂一次）
execute unless score @s zx.lw_spd matches 1 run attribute @s minecraft:movement_speed modifier add fallendream:lw_spd 0.08 add_multiplied_total
execute unless score @s zx.lw_spd matches 1 run scoreboard players set @s zx.lw_spd 1

# ② 数 8 格内敌对
scoreboard players set #lw_n zx.meta 0
execute as @e[type=!#fallendream:no_damage,type=!minecraft:player,distance=..8] run scoreboard players add #lw_n zx.meta 1

# ③ ≤2 → 技能伤害 +8%（hook_calc 读 zx.lw_on）
scoreboard players set @s zx.lw_on 0
execute if score #lw_n zx.meta matches ..2 run scoreboard players set @s zx.lw_on 1

# ④ 套装「临敌」：数量变化 → 4 秒，16 秒冷却
function fallendream:equipment/armor/lone_walk/set_lc

# ⑤ 临敌期间的护甲 +4（挂/摘）
execute if score @s zx.lw_lc > #now manacore.meta unless score @s zx.lw_arm matches 1 run attribute @s minecraft:armor modifier add fallendream:lw_arm 4 add_value
execute if score @s zx.lw_lc > #now manacore.meta unless score @s zx.lw_arm matches 1 run scoreboard players set @s zx.lw_arm 1
execute if score @s zx.lw_lc <= #now manacore.meta if score @s zx.lw_arm matches 1 run attribute @s minecraft:armor modifier remove fallendream:lw_arm
execute if score @s zx.lw_lc <= #now manacore.meta if score @s zx.lw_arm matches 1 run scoreboard players set @s zx.lw_arm 0
