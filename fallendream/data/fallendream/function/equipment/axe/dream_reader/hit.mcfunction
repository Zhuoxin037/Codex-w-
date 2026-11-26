# ============================================================
# fallendream:equipment/axe/dream_reader/hit —— 释梦 · 被动技能(平A钩子)
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/axe/dream_reader_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【技能原文(必须和这里对上)】
#   基础: "攻击处于时停状态的生物时对其额外造成 5×剩余时停时间的真实伤害，之后解除他的
#          时停状态。"
#   超限(第三十三批, 2026-10-10): "攻击处于时停状态的生物时对其额外造成相当于自身基础
#          攻击力（最低为10）*剩余时停时间*0.5的真实伤害，之后解除他的时停状态。"
#     ★ 只有**倍率**变了: 5×剩余秒数 -> 基础攻击力(下限 10) × 剩余秒数 ×0.5。
#       "解除其时停"两段都有, 不变。剩余时停时间的单位沿用基础版口径 = **秒**
#       ((zx.ts_end − #now) ÷ 20, 下限 0)。
# 【★ 四要素逐个落实 ★】
#   ① 触发: 平A命中。
#   ② 目标范围: 命中的那一只, 且**必须处于时停**(tag=zx.stop)。
#   ③ 次数: 每次命中一次(这个钩子是"攻击到生物"口径 —— 只对"被点到的、且在时停里的那只"生效;
#      横扫扫到别的生物不会给它们加伤, 所以**不需要**按刻去重)。
#   ④ 时长: 瞬发; 打完之后**解除其时停**(lib/timestop_one)。
# 【数值】5 × 剩余时停秒数; 剩余秒数 = (zx.ts_end − #now) ÷ 20, 下限 0。
# 【伤害类型】fallendream:true_damage(穿甲 + 不被无敌帧吃, 见 mirage/ts_dmg 的说明)。
# 【为什么用 lib/victim】命中的是哪一只, 只能从"刚挨打的最近一只"反查(见 lib/victim)。
# ============================================================

advancement revoke @s only fallendream:equipment/axe/dream_reader_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 武器门控: 主手或副手是释梦才生效
scoreboard players set #dr_ok zx.meta 0
execute if items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["dream_reader"]}] run scoreboard players set #dr_ok zx.meta 1
execute if items entity @s weapon.offhand diamond_axe[custom_data~{zx:["dream_reader"]}] run scoreboard players set #dr_ok zx.meta 1
execute unless score #dr_ok zx.meta matches 1 run return 0

# ① 定位"刚才这一下打的是哪一只"
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/axe/dream_reader/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
