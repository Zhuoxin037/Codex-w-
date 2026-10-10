# ============================================================
# sweetdream:equipment/staff/begonia/vortex_death —— 漩涡增强检测(每刻)
# ------------------------------------------------------------
# 【谁调用它】core/tick: execute as @e[tag=zx.bg_vtx] at @s run ...(执行者 = 漩涡本体)
# 【技能原文(超限·海棠)】"若有生物在漩涡范围内死亡，则对该漩涡进行增强"
# 【怎么判"死亡"】刚死的生物**这一 tick 还在实体列表里**(tick 末才移除),
#   NBT Health = 0.0f —— 与横刀"击杀则重置冷却"同一套判据(dusk_dawn/find_dead 同款)。
#   死亡不限死因(烧死 / 摔死 / 被谁打死都算), 只要在范围内。
# 【范围】6 格 = 超限漩涡的半径(基础漩涡没有"增强"一说, 第一行就退出)。
# 【增强状态】给漩涡本体打 tag zx.bg_emp, **跟随漩涡寿命**(kill 时一起消失),
#   不做时限 —— 文案是"对该漩涡进行增强", 漩涡活着就一直增强。
# 【开销】只有场上有超限漩涡时才会真正执行; 第一行数据判不过就 return,
#   已经增强过的也直接 return(增强是一次性的, 不重复扫描)。
# ============================================================

execute unless data entity @s data.zx.bg{ol:1b} run return 0
execute if entity @s[tag=zx.bg_emp] run return 0
execute if entity @e[type=!#sweetdream:no_damage,distance=..6,nbt={Health:0.0f},limit=1] run tag @s add zx.bg_emp
