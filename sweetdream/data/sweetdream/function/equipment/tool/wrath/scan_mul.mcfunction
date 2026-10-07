# ============================================================
# sweetdream:equipment/tool/wrath/scan_mul —— 面板: 愠怒 +20% 折进「独立乘区」
# ------------------------------------------------------------
# @panel: independent_multiplier
# 【执行者】玩家本人(@s)
# 【出参】仅当"副手拿着「愠怒」 且 血量低于 20%"时, 把 zx:work pl.independent_multiplier
#   (面板「伤害参数」节里那一行「独立乘区」)乘 1.20。
# 【★ 结算不在这里 ★】真正的加伤在 hook_calc 里乘最终 r.damage(挂 damage_calc 事件)。
#   不折进来的话, 玩家压低血量看 stats 那一行还是 1.0, 会以为没生效。
# 【★ 为什么折「独立乘区」而不是「最大魔力值技能倍率」★】
#   文案写的是「(独立乘区)」 —— 独立乘区 = 三条通道相加之后**整体再乘一次**,
#   和"最大魔力值通道 +20%"(加算口径)不是一回事:
#     · 加算 : 并进 max_mana_mul 那条通道  -> 只放大 mm 那一份贡献
#     · 独立 : 乘在求和结果上              -> 连混通道技能的 oth 部分一起放大
#   面板上这两者本来就是两行(「技能倍率」节的 smul_mm  vs 「伤害参数」节的独立乘区),
#   折错行 = 面板说假话(第一原则见 scan 头注释)。
#   ★ 2026-10-06 修: 上一版折进 smul_mm, 玩家看到的是"通道 +20%"的样子(用户反馈)。
# 【判据必须和 hook_calc 逐字一致】(副手拿着 + 血量<20%)。
# 【×100 定点】independent_multiplier 先 ×100 读成整数, 乘 #120 再 ÷100 写回。
# ============================================================

# ① 副手没拿「愠怒」-> 不参与
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["wrath"]}] run return 0

# ② 算血量差(< 0 = 低于 20%), 不低就不参与
function sweetdream:equipment/tool/wrath/low_hp
execute unless score #wr_hp zx.meta matches ..-1 run return 0

# ③ 独立乘区 ×1.20
execute store result score #m zx.meta run data get storage zx:work pl.independent_multiplier 100
scoreboard players operation #m zx.meta *= #120 zx.meta
scoreboard players operation #m zx.meta /= #100 zx.meta
execute store result storage zx:work pl.independent_multiplier double 0.01 run scoreboard players get #m zx.meta
