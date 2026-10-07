# ============================================================
# sweetdream:equipment/bow/cold_crow/hook_victim —— 附魔回调: 记下被打中的那只 + 结算
# ------------------------------------------------------------
# 【谁调它】附魔「霜矢」的 post_attack, affected = victim(被打中的生物)
# 【执行者】被打中的那只生物
# 【★ 近战门控(2026-10-05 修) ★】
#   post_attack 对"拿弩近战敲人"也会触发。原来这里"就近找一支带快照的箭"兜底 ->
#   近战敲人时会拿**上一发**的旧快照结算: 不耗蓝、冰凌层数永远是上次那个
#   (玩家报告:"拿着弩去近战生物也会触发效果、不消耗魔力, 而且寒鸦是 4 层就一直 4 层")。
#   现在改成:**必须有 hook_arrow 标的 zx.cc_arr**(= 原版告诉我们 damaging_entity
#   就是箭)才继续; 近战时 damaging_entity 是玩家本人 -> 没标签 -> 直接收工。
#   同时删掉"按距离找箭"的兜底(那正是旧层数串味的来源)。
# 【四件事】
#   ① 把自己标成 zx.cc_v(先清干净再标, 保证只有一个)
#   ② 找射手: 优先用 hook_attacker 标的 zx.cc_pl; 没标上就退回"离受害者最近的玩家"
#   ③ 拿 hook_arrow 标好的那支箭
#   ④ 交给 apply 读快照并结算
# 【为什么排除玩家】范围选择器一直排除玩家; 万一原版把玩家也算成 victim, 别把玩家当受害者。
# ============================================================

# ⓪ 只处理"箭造成的命中": 近战(没被打上 zx.cc_arr)直接收工
execute unless entity @e[tag=zx.cc_arr,limit=1] run return 0

tag @e[tag=zx.cc_v] remove zx.cc_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.cc_v
execute unless entity @e[tag=zx.cc_v,limit=1] run return 0

data modify storage zx:work cc.target set value "@e[tag=zx.cc_v,limit=1]"
data modify storage zx:work cc.shooter set value "@a[tag=zx.cc_pl,limit=1]"
execute unless entity @a[tag=zx.cc_pl,limit=1] run data modify storage zx:work cc.shooter set value "@p"

data modify storage zx:work cc.arrow set value "@e[tag=zx.cc_arr,limit=1]"

function sweetdream:equipment/bow/cold_crow/apply with storage zx:work cc
