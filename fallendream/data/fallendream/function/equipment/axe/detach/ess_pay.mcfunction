# ============================================================
# fallendream:equipment/axe/detach/ess_pay —— 脱离·超限：命中附带「本质」的兑现
# ------------------------------------------------------------
# 【宏参数】zx:work detach {u:"<被打生物的 UUID>"}
# 【执行者】玩家（本我者那一侧，尚未切换）
# 【文案（用户 2026-11-20 原稿）】
#   若该次命中的生物附有「本质」则消耗1层，使该段技能伤害 +25% 并为本我者提供
#   最大生命值15%的临时生命值，持续5秒。切换后的8秒内，同生体第一次命中该生物时，
#   为本我者恢复15%最大生命值。
# 【调用点】detach/hit_go/victim_body —— 在**算出 a.num 之前**改 #dto_num。
# 【★ 这里只管"消耗 + 加伤"两件事 ★】
#   15% 临时生命与 8 秒窗口都排在 twin/enter 之后（切换要先重设玩家血线，提前给会被
#   掀掉），见 thp5 / win_set。本函数只留一个 #dto_ess=1 的旗子给它们读。
# 【★「本质」是计分项不是标签 ★】zx.j_ess 挂在生物身上（lib/reg/build 的 layer「本质」），
#   所以用 `scoreboard players remove` 消耗，不走 lib/mark_consume（那条路吃的是标签）。
# ============================================================

$scoreboard players remove $(u) zx.j_ess 1

# 本段技能伤害 +25%（毫点 ×5÷4，先乘后除保持精度）
scoreboard players operation #dto_num zx.meta *= #5 zx.meta
scoreboard players operation #dto_num zx.meta /= #4 zx.meta

# 旗子：本次确实吃到了「本质」
scoreboard players set #dto_ess zx.meta 1
