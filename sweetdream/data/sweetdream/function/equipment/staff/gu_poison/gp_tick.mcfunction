# ============================================================
# sweetdream:equipment/staff/gu_poison/gp_tick —— 一个「噬心」目标的每秒心跳
# ------------------------------------------------------------
# 【谁调用它】gu_poison/second(执行者 = 目标生物, at @s)
# 【技能原文(lore 逐字)】使…生物每秒受到相当于自身最大生命值 ×0.1 的伤害，之后移除
#   「噬心」。持续 6 秒。（若「噬心」效果提前结束则技能效果也提前失效）
# 【★ 提前结束 ★】每拍先查它身上还有没有「噬心」: 没了 -> 本目标立刻失效(gp_drop)。
# ============================================================

# ① 「噬心」提前没了 -> 本目标失效
execute unless entity @s[tag=zx.status.shixin] run return run function sweetdream:equipment/staff/gu_poison/gp_drop

# ② 有「噬心」-> 打一发(释放者最大生命 ×0.1)
function sweetdream:equipment/staff/gu_poison/gp_hit

# ③ 表现(中毒)
particle minecraft:witch ~ ~1 ~ 0.35 0.5 0.35 0.02 8 normal
particle minecraft:item_slime ~ ~0.6 ~ 0.3 0.3 0.3 0.03 4 normal

# ④ 倒计时; 到 0 收尾(移除「噬心」+ 摘标记)
scoreboard players remove @s zx.gp_t 1
execute if score @s zx.gp_t matches ..0 run function sweetdream:equipment/staff/gu_poison/gp_end
