# ============================================================
# sweetdream:equipment/sword/chengxing/hit —— 秤星（下界剑 · 被动）
# ------------------------------------------------------------
# 【触发】玩家普攻命中（advancement player_hurt_entity，只认 is_player_attack）
# 【机制】每次命中的**目标**额外受到一次
#             （自身护甲韧性 + 自身护甲值）× 2
#         点固定伤害。不参与任何乘区、不吃暴击 —— 直接走 internal/damage/with_from。
# 【★ 口径】护甲/韧性一律读**原版属性当前值**（含装备与修饰符），不读面板缓存：
#     attribute @s minecraft:armor_toughness get
#     attribute @s minecraft:armor get
#   参考 10-20 定死的"基础攻击力"口径同源（attribute 读数 = 实际情况）。
#   ★ 坑 199 的对策在这里**不适用**：那条是"临时压低 max_health 后读到假上限"，
#     护甲/韧性没有这套临时补丁，读数就是真实值。
# 【上限】原版护甲封顶 30，韧性靠底材，所以最高（韧性 + 30）× 2 —— 堆不到无穷大。
# 【为什么先判满蓄力】包内所有"普攻附带"件（归息 / 回旋 / 雷楔）都先走 lib/atk_charge，
#   不满蓄力的一下不算"命中"，否则连点就能无限刷固定伤害。
# ============================================================
advancement revoke @s only sweetdream:equipment/sword/chengxing_hit

# 主手或副手持有秤星（下界剑）
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["chengxing"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["chengxing"]}] run return 0

function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=..16,limit=1] run return 0

# ---- 读属性：韧性 + 护甲 ----
scoreboard players set #cx_t zx.meta 0
execute store result score #cx_t zx.meta run attribute @s minecraft:armor_toughness get
scoreboard players set #cx_a zx.meta 0
execute store result score #cx_a zx.meta run attribute @s minecraft:armor get
scoreboard players operation #cx_t zx.meta += #cx_a zx.meta
scoreboard players operation #cx_t zx.meta *= #2 zx.meta
execute if score #cx_t zx.meta matches ..0 run return 0

# ---- 投递固定伤害 ----
data modify storage zx:work a set value {fixed:1b,target:"@e[tag=zx.victim,distance=..16,limit=1]",type:"minecraft:player_attack"}
# ★ 缩放必须是 1：#cx_t 已经是 (韧性 + 护甲) × 2 的整数，再除 10 会正好小十倍
#   （全下界合金 12+20=32 → ×2 = 64，写成 0.1 只剩 6.4，就是"额外伤害才 6 点多"）。
#   `data get storage ... double <倍数>` 的第三段是**乘数**，不是小数点后位数。
execute store result storage zx:work a.num double 1 run scoreboard players get #cx_t zx.meta
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

execute at @e[tag=zx.victim,distance=..16,limit=1] run particle minecraft:crit ~ ~1 ~ 0.35 0.35 0.35 0 10 normal
execute at @e[tag=zx.victim,distance=..16,limit=1] run particle minecraft:end_rod ~ ~0.8 ~ 0.3 0.5 0.3 0.02 8 normal
execute at @e[tag=zx.victim,distance=..16,limit=1] run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.5 1.6
tag @e[tag=zx.victim] remove zx.victim
