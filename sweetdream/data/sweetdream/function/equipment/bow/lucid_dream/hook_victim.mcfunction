# ============================================================
# sweetdream:equipment/bow/lucid_dream/hook_victim —— 附魔回调: 记下被打中的 + 结算
# ------------------------------------------------------------
# 【谁调它】附魔「清醒梦」的 post_attack, affected = victim
# 【执行者】被打中的那只生物
# 【★ 近战门控(2026-10-05 修) ★】
#   post_attack 对"拿弩近战敲人"也会触发。原来这里"就近找一支带快照的箭"兜底,
#   近战敲人时会拿**上一发**的旧快照(不耗蓝、层数永远是上次那个)。
#   现在改成:**必须有 hook_arrow 标的 zx.ld_arr** 才继续; 近战时 damaging_entity
#   是玩家本人 -> 没标签 -> 收工。并删除"按距离找箭"的兜底。
# ============================================================

# ⓪ 只处理"箭造成的命中": 近战(没被打上 zx.ld_arr)直接收工
execute unless entity @e[tag=zx.ld_arr,limit=1] run return 0

tag @e[tag=zx.ld_v] remove zx.ld_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.ld_v
execute unless entity @e[tag=zx.ld_v,limit=1] run return 0

data modify storage zx:work ld.target set value "@e[tag=zx.ld_v,limit=1]"
data modify storage zx:work ld.shooter set value "@a[tag=zx.ld_pl,limit=1]"
execute unless entity @a[tag=zx.ld_pl,limit=1] run data modify storage zx:work ld.shooter set value "@p"

data modify storage zx:work ld.arrow set value "@e[tag=zx.ld_arr,limit=1]"

function sweetdream:equipment/bow/lucid_dream/apply with storage zx:work ld
