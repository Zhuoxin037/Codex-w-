# ============================================================
# sweetdream:equipment/bow/cold_crow/hook_victim —— 附魔回调: 记下被打中的那只 + 结算
# ------------------------------------------------------------
# 【谁调它】附魔「霜矢」的 post_attack, affected = victim(被打中的生物)
# 【执行者】被打中的那只生物
# 【三件事】
#   ① 把自己标成 zx.cc_v(先清干净再标, 保证只有一个)
#   ② 找射手: 优先用 hook_attacker 标的 zx.cc_pl; 没标上就退回"离受害者最近的玩家"
#   ③ 交给 apply 读"射手这一发的数据"并结算
# 【为什么排除玩家】范围选择器一直排除玩家; 万一原版把玩家也算成 victim, 别把玩家当受害者。
# ============================================================

tag @e[tag=zx.cc_v] remove zx.cc_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.cc_v
execute unless entity @e[tag=zx.cc_v,limit=1] run return 0

data modify storage zx:work cc.target set value "@e[tag=zx.cc_v,limit=1]"
data modify storage zx:work cc.shooter set value "@a[tag=zx.cc_pl,limit=1]"
execute unless entity @a[tag=zx.cc_pl,limit=1] run data modify storage zx:work cc.shooter set value "@p"
function sweetdream:equipment/bow/cold_crow/apply with storage zx:work cc
