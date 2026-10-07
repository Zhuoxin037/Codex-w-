# ============================================================
# sweetdream:equipment/bow/sculk_echo/hook_victim —— 附魔回调: 记下被打中的 + 结算
# ------------------------------------------------------------
# 【谁调它】附魔「幽匿残响」的 post_attack, affected = victim(被打中的生物)
# 【执行者】被打中的那只生物
# 【★ 近战门控(2026-10-05 修) ★】
#   post_attack 对"拿弩近战敲人"也会触发。原来这里有一句"就近找一支带快照的箭"
#   兜底 -> 近战敲人时会拿**上一发**的旧快照结算: 不耗蓝、群体伤用的是上一次的
#   悲鸣层数(玩家报告"近战也会触发、不消耗魔力、层数一直是上次那个")。
#   现在改成:**必须有 hook_arrow 标的 zx.se_arr** 才继续; 近战时 damaging_entity
#   是玩家本人 -> 没标签 -> 直接收工。并删除"按距离找箭"的兜底。
# 【三件事】① 标自己 ② 找射手 ③ 拿 hook_arrow 标好的那支箭 -> 交给 apply
# 【★ 顺便掐掉路径每刻伤 ★】命中之后这支箭不该再算"路径周围 2 格", 摘掉 zx.se_live。
# 【为什么排除玩家】范围选择器一直排除玩家, 万一原版把玩家也算成 victim 别搞错。
# ============================================================

# ⓪ 只处理"箭造成的命中": 近战(没被打上 zx.se_arr)直接收工
execute unless entity @e[tag=zx.se_arr,limit=1] run return 0

tag @e[tag=zx.se_v] remove zx.se_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.se_v
execute unless entity @e[tag=zx.se_v,limit=1] run return 0

data modify storage zx:work se.target set value "@e[tag=zx.se_v,limit=1]"
data modify storage zx:work se.shooter set value "@a[tag=zx.se_pl,limit=1]"
execute unless entity @a[tag=zx.se_pl,limit=1] run data modify storage zx:work se.shooter set value "@p"

data modify storage zx:work se.arrow set value "@e[tag=zx.se_arr,limit=1]"
execute as @e[tag=zx.se_arr,limit=1] run tag @s remove zx.se_live

function sweetdream:equipment/bow/sculk_echo/apply with storage zx:work se
