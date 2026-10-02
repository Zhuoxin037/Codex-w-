# ============================================================
# sweetdream:equipment/bow/cold_crow/hook_arrow —— 附魔回调: 记下"造成伤害的那支箭"
# ------------------------------------------------------------
# 【谁调它】数据包附魔 sweetdream:cold_crow(「霜矢」)的 post_attack,
#   affected = damaging_entity —— "直接造成这次伤害的实体"。
#   玩家射箭时它就是**那支箭**; 玩家拿弩近战敲人时它是玩家本人。
# 【执行者】damaging_entity(通常就是那支箭)
# 【为什么需要它】原版只在回调里把"受影响的实体"交给函数, victim 那边拿不到
#   箭的引用。用标签 zx.cc_arr 把两边接上, hook_victim 就能按它去读
#   "这一箭自己带的快照"(见 snapshot), 不必再猜是哪支箭。
# 【顺序】它排在效果表的第一条, 所以 hook_victim 跑到时标签已经打好。
#   万一顺序变了 / 这次是近战, hook_victim 里还有"从受害者就近找带快照的箭"兜底。
# 【近战不打标签】damaging_entity 不是箭时这里什么都不做, victim 那边就会
#   退回用"射手最近一发"那份数据(老路径)。
# ============================================================

tag @e[tag=zx.cc_arr] remove zx.cc_arr
execute if entity @s[type=#sweetdream:cc_arrow] run tag @s add zx.cc_arr
