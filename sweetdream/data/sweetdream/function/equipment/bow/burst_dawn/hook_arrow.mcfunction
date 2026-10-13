# ============================================================
# sweetdream:equipment/bow/burst_dawn/hook_arrow —— 附魔回调: 记下"造成伤害的那支箭"
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:burst_dawn 的 post_attack, affected = damaging_entity。
#   玩家射箭时它就是**那支箭**; 拿弩近战敲人时是玩家本人。
# 【★ 两层门控 ★】
#   ① 近战门控: damaging_entity 不是箭时这里不打标签 -> hook_victim 开头那句
#      "必须有 zx.bd_arr" 不成立 -> 近战直接收工, 不会误触发。
#   ② 已付账门控: **不在这一层做**(坑 141) —— 改去 hook_victim 里读**射手身上**
#      的 zx.bd_paid。射击那一刻箭可能还没进世界, 箭上的 zx.bd_ok 打不上。
#      (首发扣不起 799 时 shot 会把 zx.bd_paid 写成 0, 那一发照样什么都不做。)
# 【顺序】它排在效果表的第一条, 所以 hook_victim 跑到时标签已经打好。
# ============================================================

scoreboard players add #bd_dbg0 zx.meta 1
tag @e[tag=zx.bd_arr,distance=0..] remove zx.bd_arr
execute if entity @s[type=#sweetdream:cc_arrow] run tag @s add zx.bd_arr
