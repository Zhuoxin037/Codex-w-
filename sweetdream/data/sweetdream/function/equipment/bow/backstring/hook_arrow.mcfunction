# ============================================================
# sweetdream:equipment/bow/backstring/hook_arrow —— 附魔回调: 记下"造成伤害的那支箭"
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:backstring 的 post_attack, affected = damaging_entity。
#   玩家射箭时它就是**那支箭**; 拿弩近战敲人时是玩家本人。
# 【★ 为什么只判"是不是箭"这一件事 ★】一件判据只干一件事(坑 136 同族):
#   ① 近战门控在这层做(不是箭 -> 不打标签 -> hook_victim 开头那句不成立 -> 收工);
#   ② "这一发付没付钱"**不在这一层做** —— 它改去 hook_victim 里读**射手身上**的
#      zx.bs_paid(坑 141: 射击时箭可能还没进世界, 箭上的标签靠不住)。
# 【顺序】它排在效果表的第一条, 所以 hook_victim 跑到时标签已经打好。
# ============================================================

tag @e[tag=zx.bs_arr,distance=0..] remove zx.bs_arr
execute if entity @s[type=#sweetdream:cc_arrow] run tag @s add zx.bs_arr
