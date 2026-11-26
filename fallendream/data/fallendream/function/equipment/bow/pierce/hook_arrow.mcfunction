# ============================================================
# fallendream:equipment/bow/pierce/hook_arrow —— 附魔回调: 记下造成伤害的那支箭
# ------------------------------------------------------------
# 【谁调它】附魔 fallendream:pierce 的 post_attack, affected = damaging_entity
#   (效果表第一条, 所以 hook_victim 跑到时标签已经打好)
# 【执行者】damaging_entity(玩家射箭时就是那支箭; 近战敲人时是玩家本人)
# 【两层门控】
#   ① 不是箭 -> 不打标签, hook_victim 开头的近战门控直接收工, 不会误触发。
#   ② 只有带 zx.pi_ok 的箭才打 zx.pi_arr —— 没扣蓝/没扣球的那一发什么都不做。
# ============================================================

tag @e[tag=zx.pi_arr] remove zx.pi_arr
execute if entity @s[type=#fallendream:cc_arrow,tag=zx.pi_ok] run tag @s add zx.pi_arr
