# ============================================================
# sweetdream:equipment/armor/immolate/reclaim —— 脱下焚舟时回收上限
# ------------------------------------------------------------
# 【为什么要有这一份】面板只有一个 max_mana, 没有“加成层”。
#   穿上时 zx.im_mk 记着“我已经加了 240 上限”; 如果脱下来不按这本账减回去,
#   玩家就能靠反复穿脱白嫖上限, 而且这部分上限永远不会消失。
# 【回收顺序】先收烈空账本的上限, 再收套装 buff 的 +100。
# 【烈空清零】脱下时把烈空也归零, 避免“穿回去直接又是满层”的第二轮白嫖。
# ============================================================

# ① 回收烈空给的上限
scoreboard players add @s zx.im_mk 0
execute unless score @s zx.im_mk matches 0 run function sweetdream:equipment/armor/immolate/reclaim_apply

# ② 回收套装 buff 的 +100(如果还在持续)
execute if score @s zx.im_buff_mk matches 1.. run function sweetdream:equipment/armor/immolate/buff_off

# ③ 清状态
scoreboard players set @s zx.lk 0
scoreboard players set @s zx.lk_mode 0
scoreboard players set @s zx.im_buff 0
tag @s remove zx.im_set
