# ============================================================
# sweetdream:equipment/staff/other_shore/heal —— 每消耗一组「渊海」+「噬心」回 5% 最大生命
# ------------------------------------------------------------
# 【谁调用它】skill ⑩   【执行者】施法者(玩家)
# 【入参】#os_pairs = 本轮**双状态者**的个数(= 消耗了几组)
# 【技能原文】"每消耗一组「渊海」和「噬心」，则为自身恢复最大生命值 5% 的生命。"
# 【★ 为什么用 attribute 读上限 ★】lib/heal 内部也用同一个来源算"临时上限",
#   两边同源才不会差出"面板/属性不同步"的那一截(殓丝 on_hurt 同款注释)。
# 【★ 只支持玩家 ★】lib/heal 的路线②依赖 instant_health, 对亡灵是伤害 ——
#   本件施法者一定是玩家, 不涉及那个边界。
# ============================================================

# ① 要恢复的整点数 = 最大生命 × 5% × 组数
execute store result score #heal_pt zx.meta run attribute @s minecraft:max_health get
scoreboard players set #os_pct zx.meta 5
scoreboard players operation #os_pct zx.meta *= #os_pairs zx.meta
scoreboard players operation #heal_pt zx.meta *= #os_pct zx.meta
scoreboard players operation #heal_pt zx.meta /= #100 zx.meta

# ② 交给公共回血原语(跨一拍撤天花板, 见 lib/heal 头部)
function sweetdream:lib/heal

# ③ 表现: 彼岸的水色回涌
execute at @s run particle minecraft:glow ~ ~1 ~ 0.4 0.6 0.4 0.02 12 normal
execute at @s run playsound minecraft:block.conduit.activate player @a ~ ~ ~ 0.5 1.6
