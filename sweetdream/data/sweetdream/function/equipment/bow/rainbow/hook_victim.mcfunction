# ============================================================
# sweetdream:equipment/bow/rainbow/hook_victim —— 附魔回调: 记下被打中的 + 结算
# ------------------------------------------------------------
# 【谁调它】附魔「虹彩」的 post_attack, affected = victim(被打中的生物)
# 【执行者】被打中的那只生物
# 【★ 近战门控(2026-10-05 修) ★】
#   post_attack 对"拿弩近战敲人"也会触发。原来这里"就近找一支带快照的箭"兜底,
#   近战敲人时会拿**上一发**的旧快照给生物上"漫彩"(不耗蓝、层数永远是上次那个)。
#   现在改成:**必须有 hook_arrow 标的 zx.rb_arr** 才继续; 近战时 damaging_entity
#   是玩家本人 -> 没标签 -> 收工。并删除"按距离找箭"的兜底。
# 【三件事】① 标自己 ② 找射手 ③ 拿 hook_arrow 标好的那支箭 -> 交给 apply
# ============================================================

# ⓪ 只处理"箭造成的命中": 近战(没被打上 zx.rb_arr)直接收工
execute unless entity @e[tag=zx.rb_arr,limit=1] run return 0

tag @e[tag=zx.rb_v] remove zx.rb_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.rb_v
execute unless entity @e[tag=zx.rb_v,limit=1] run return 0

data modify storage zx:work rb.target set value "@e[tag=zx.rb_v,limit=1]"
data modify storage zx:work rb.shooter set value "@a[tag=zx.rb_pl,limit=1]"
execute unless entity @a[tag=zx.rb_pl,limit=1] run data modify storage zx:work rb.shooter set value "@p"

data modify storage zx:work rb.arrow set value "@e[tag=zx.rb_arr,limit=1]"

function sweetdream:equipment/bow/rainbow/apply with storage zx:work rb
