# ============================================================
# sweetdream:equipment/bow/dragon_tongue/hook_arrow —— 附魔回调: 记下"造成伤害的那支箭"
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:dragon_tongue 的 post_attack, affected = damaging_entity。
#   玩家射箭时它就是**那支箭**; 拿弩近战敲人时是玩家本人。
# 【★ 两层门控 ★】
#   ① 近战门控: damaging_entity 不是箭时这里不打标签 -> hook_victim 开头那句
#      "必须有 zx.dt_arr" 不成立 -> 近战直接收工, 不会误触发。
#   ② 已付钱门控: **不在这一层做** —— 它改去 hook_victim 里读**射手身上**的
#      zx.dt_paid(坑 141: 射击时箭可能还没进世界, 箭上的标签靠不住)。
#      这一层只负责"是不是箭打的"这一件事, 一件判据只干一件事(坑 136 同族)。
# 【顺序】它排在效果表的第一条, 所以 hook_victim 跑到时标签已经打好。
# ============================================================

scoreboard players add #dt_dbg0 zx.meta 1
tag @e[tag=zx.dt_arr,distance=0..] remove zx.dt_arr
execute if entity @s[type=#sweetdream:cc_arrow] run tag @s add zx.dt_arr
