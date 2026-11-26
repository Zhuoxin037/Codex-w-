# ============================================================
# fallendream:equipment/sword/chengxing/hit —— 秤星（下界剑 · 被动）
# ------------------------------------------------------------
# 【触发】玩家普攻命中（advancement player_hurt_entity，只认 is_player_attack）
# 【原版机制】每次命中的**目标**额外受到一次
#             （自身护甲韧性 + 自身护甲值）× 2 点固定伤害。
#             不参与任何乘区、不吃暴击 —— 直接走 internal/damage/with_from。
# 【超限机制】① 主手持时护甲 +1（chengxing/base_sync，每秒同步）
#             ② 固定伤害 ×2 → ×2.2（hit/victim_body）
#             ③ 每攻击 4 次，下一次攻击可以被"当前最高的下一次技能增幅"增强，
#                且不消耗那份增幅（本文件的 count + amp_hit）
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
advancement revoke @s only fallendream:equipment/sword/chengxing_hit

# 主手或副手持有秤星（下界剑）
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["chengxing"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["chengxing"]}] run return 0

function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 超限判定（主手 / 副手，与 victim_body 同口径）
scoreboard players set #cx_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["chengxing"],ol:"chengxing"}] run scoreboard players set #cx_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["chengxing"],ol:"chengxing"}] run scoreboard players set #cx_ol zx.meta 1

# 超限：这一击计入「每攻击 4 次」

function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/sword/chengxing/hit/victim_body with storage zx:work vx_frames[-1].context
execute if score #cx_ol zx.meta matches 1 run function fallendream:equipment/sword/chengxing/count
# 超限：上一击打满 4 下时攒下的那张券，在这一击兑现
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
