# ============================================================
# sweetdream:equipment/bow/bone_erode/hook_victim —— 附魔回调: 记下被打中的 + 结算
# ------------------------------------------------------------
# 【谁调它】附魔「蚀骨」的 post_attack, affected = victim(被打中的生物)
# 【执行者】被打中的那只生物
# 【★ 近战门控(2026-10-05 修) ★】
#   post_attack 对"拿弩近战敲人"也会触发。原来这里有一句"就近找一支带快照的箭"
#   兜底 -> 近战敲人时会拿**上一发**的旧快照来结算(不耗蓝、层数永远是上次那个)。
#   现在改成:**必须有 hook_arrow 标的 zx.be_arr**(= 原版告诉我们 damaging_entity
#   就是箭) 才继续; 近战打在生物身上时 damaging_entity 是玩家本人 -> 没标签 -> 收工。
#   同时删掉了"按距离找箭"的兜底(那正是旧层数串味的来源)。
# 【三件事】① 标自己 ② 找射手(优先 hook_attacker 的 zx.be_pl, 退回最近玩家)
#   ③ 拿 hook_arrow 标好的那支箭 -> 交给 apply
# 【为什么排除玩家】范围选择器一直排除玩家, 万一原版把玩家也算成 victim 别搞错。
# ============================================================

# ⓪ 只处理"箭造成的命中": 近战(没被打上 zx.be_arr)直接收工
execute unless entity @e[tag=zx.be_arr,limit=1] run return 0

tag @e[tag=zx.be_v] remove zx.be_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.be_v
execute unless entity @e[tag=zx.be_v,limit=1] run return 0

data modify storage zx:work be.target set value "@e[tag=zx.be_v,limit=1]"
data modify storage zx:work be.shooter set value "@a[tag=zx.be_pl,limit=1]"
execute unless entity @a[tag=zx.be_pl,limit=1] run data modify storage zx:work be.shooter set value "@p"

data modify storage zx:work be.arrow set value "@e[tag=zx.be_arr,limit=1]"

function sweetdream:equipment/bow/bone_erode/apply with storage zx:work be
