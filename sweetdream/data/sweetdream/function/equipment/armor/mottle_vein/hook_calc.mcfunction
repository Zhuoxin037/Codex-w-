# ============================================================
# sweetdream:equipment/armor/mottle_vein/hook_calc —— 杂纹「夜火」奖励: 下一次技能伤害 +20%
# ------------------------------------------------------------
# @calc: add     ← 加算型 hook: 只往加算池里写百分比, 由 lib/dmg_add_apply 统一乘
# 【谁调用它】#manacore:event/damage_calc —— 注册在 lib/dmg_add_apply **之前**
#   (顺序由 check 规则 dmgord 盯着)。
# 【执行者】施法者本人   【触发】reward ③ 给玩家打上 zx.mv_ny 之后的下一次 calc
# 【技能原文】"若消耗了「夜火」则下一次技能伤害 +20%。"
# 【★ 为什么要消费标签 ★】文案是"**下一次**" —— 一次性。这里结算完立刻摘掉
#   zx.mv_ny, 第二次 calc 就吃不到了。
# 【★ "技能伤害"的口径 = 与「愿景」/狄俄尼索斯之桂冠一致 ★】
#   全包对"技能伤害 +X%"的既有口径是"**走 manacore 伤害计算的都算**"(见
#   dionysus_helmet/hook_calc 的说明) —— 所以法杖普攻这类也吃。这是既有约定,
#   不在本件单独收紧; 若以后要严格区分普攻/技能, 应该在 calc 侧加来源字段, 而不是
#   在每一件装备里各写一套判断。
# 【★ 用 dmg_add_put_any 而不是写单通道 ★】文案没说限定哪条通道 ⇒ 三条通道
#   (mm/atk/oth)各 +20%(分量级, 见 D01 口径 B)。只在某一条通道写会让
#   "最大生命结算"这类不走那三条的技能吃不到。
# 【★ 只在穿着杂纹时有效 ★】标签可能因脱下护腿而残留 ⇒ 这里再判一次 armor.legs。
# ============================================================

# ⓪ 不是玩家 -> 不参与(damage_calc 被法球/箭这类调用时)
execute unless entity @s[type=minecraft:player] run return 0

# ① 没穿杂纹 -> 不参与
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"]}] run return 0

# ② 没有「夜火」留下的那一次加成 -> 不参与
execute unless entity @s[tag=zx.mv_ny] run return 0

# ③ 往加算池写 +20(三条通道各一份), 然后消费掉这次机会
scoreboard players set #pct zx.meta 20
execute store result storage zx:work put.pct int 1 run scoreboard players get #pct zx.meta
function sweetdream:lib/dmg_add_put_any
tag @s remove zx.mv_ny
